//
//  OpenGroupController.swift
//  Clansportler
//
//  Created by Luca Kiedrowski on 01.09.17.
//  Copyright © 2017 LucaKiedrowski. All rights reserved.
//

import UIKit
import Firebase

class OpenGroupController: ScrollController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIViewControllerTransitioningDelegate, JoinGroupModalControllerDelegate, GamenameModalControllerDelegate {
    
    let cellId = "cellId"
    
    var groupId: String? {
        didSet {
            guard let groupId = groupId else { return }
            Database.fetchAndObserveGroupWithId(id: groupId) { (currentGroup) in
                self.group = currentGroup
            }
        }
    }
    
    var group: Group? {
        didSet {
            observeGroup()
            didSetGroup()
        }
    }
    
    var members = [User]()
    
    var gameId: String? {
        didSet {
            guard let gameId = gameId else { return }
            Database.fetchGameWithId(id: gameId) { (currentGame) in
                self.game = currentGame
            }
        }
    }
    
    var game: Game? {
        didSet {
            guard let imageUrl = game?.imageUrl else { return }
            gameImageView.loadImage(urlString: imageUrl)
            guard let gamename = game?.name else { return }
            setupWhiteTitle(title: gamename)
        }
    }
    
    var currentUser: User?
    
    var groupchat: Groupchat?
    
    var chatController: ChatLogController?
    
    var joiningUpdates = [GroupJoiningUpdate]()
    
    var newestGroupJoining: GroupJoiningUpdate? {
        didSet {
            print("new group joining update")
            guard let userId = newestGroupJoining?.fromId else { return }
            Database.fetchUserWithUID(uid: userId) { (newUser) in
                
                self.setupUpdateView(username: newUser.username)
            }
        }
    }
    
    let gameImageView: CustomImageView = {
        let iv = CustomImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        return iv
    }()
    
    let currentMemberLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.white
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 36)
        return label
    }()
    
    let descriptionLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.white
        label.textAlignment = .center
        label.numberOfLines = 2
        return label
    }()
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.dataSource = self
        cv.delegate = self
        return cv
    }()
    
    lazy var addButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Add", for: .normal)
        button.backgroundColor = .clear
        button.layer.borderColor = UIColor.white.cgColor
        button.layer.borderWidth = 1
        button.layer.cornerRadius = 5
        button.setTitleColor(UIColor.white, for: .normal)
        button.addTarget(self, action: #selector(handleAdd), for: .touchUpInside)
        return button
    }()
    
    lazy var leaveButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Leave", for: .normal)
        button.backgroundColor = ColorCodes.clansportlerRed
        button.setTitleColor(UIColor.white, for: .normal)
        button.layer.cornerRadius = 5
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.addTarget(self, action: #selector(handleLeave), for: .touchUpInside)
        return button
    }()
    
    let pageControl: UIPageControl = {
        let pc = UIPageControl()
        pc.pageIndicatorTintColor = UIColor(white: 1, alpha: 0.5)
        pc.currentPageIndicatorTintColor = UIColor.white
        pc.numberOfPages = 2
        pc.currentPage = 0
        return pc
    }()
    
    let updateView: UIView = {
        let view = UIView()
        view.backgroundColor = ColorCodes.backgroundGrey
        return view
    }()
    
    let updateLabel: UILabel = {
        let label = UILabel()
        label.text = "username has joined your group"
        label.textColor = UIColor.white
        label.textAlignment = .center
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        super.setupScrollView(height: view.frame.height + 175)
        
        hideKeyboardWhenTappedAround(views: [view, scrollContainerView])
        
        collectionView.register(GroupMemberCell.self, forCellWithReuseIdentifier: cellId)
        collectionView.backgroundColor = ColorCodes.clansportlerBlue
        collectionView.alwaysBounceHorizontal = true
        collectionView.contentInset = UIEdgeInsetsMake(0, 8, 0, 8)
        
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
        Database.fetchUserWithUID(uid: currentUserId) { (currentUser) in
            self.currentUser = currentUser
        }
        
        setupController()
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeLeft))
        swipeLeft.direction = .left
        self.view.addGestureRecognizer(swipeLeft)
        
        scrollView.alwaysBounceVertical = false
        
        observeGroup()
        
    }
    
    @objc func handleSwipeLeft() {
        
        if let currentChatLogController = self.chatController {
            navigationController?.pushViewController(currentChatLogController, animated: true)
        } else {
            let layout = UICollectionViewFlowLayout()
            let newChatLogController = ChatLogController(collectionViewLayout: layout)
            newChatLogController.group = self.groupchat
            
            self.chatController = newChatLogController
            
            navigationController?.pushViewController(newChatLogController, animated: true)
        }
    }
    
    override func setupController() {
        navigationController?.navigationBar.isTranslucent = false
        
        setupViews()
        
        view.backgroundColor = ColorCodes.clansportlerBlue
        
        NotificationCenter.default.addObserver(self, selector: #selector(reloadGroup), name: Group.updateGroupNotification, object: nil)
    }
    
    func observeGroup() {
        guard let groupId = self.group?.id else { return }
        let groupRef = Database.database().reference().child("groups").child(Group.groupDataDB).child(groupId).child("memberIds")
        groupRef.observe(.childChanged, with: { (snapshot) in
            
            NotificationCenter.default.post(name: Group.updateGroupNotification, object: nil)
            
        }) { (err) in
            print("failed to observe group")
        }
    }
    
    @objc func reloadGroup() {
        guard let groupId = self.group?.id else { return }
        Database.fetchAndObserveGroupWithId(id: groupId) { (group) in
            self.group = group
            
            if self.gameId == nil {
                self.gameId = group.gameId
            }
        }
    }
    
    func didSetGroup() {
        guard let unwrappedGroup = self.group else { return }
        self.fetchMembers(group: unwrappedGroup)
        
        guard let maxNumber = group?.maxGroupMember else { return }
        guard let currentCount = group?.memberIds?.count else { return }
        guard let wildcardCount = group?.wildcardCount else { return }
        
        currentMemberLabel.text = "\(currentCount + wildcardCount)/\(maxNumber)"
        
        guard let groupchatId = group?.groupchatId else { return }
        Database.fetchGroupchat(withId: groupchatId) { (groupchat) in
            self.groupchat = groupchat
        }
        
        if let groupTextDescription = unwrappedGroup.description {
            descriptionLabel.text = groupTextDescription
        }
        var helperCount = wildcardCount
        while helperCount > 0 {
            self.setupWildcardUser()
            helperCount -= 1
        }
        watchForNewUpdates(groupId: unwrappedGroup.id)
    }
    
    fileprivate func watchForNewUpdates(groupId: String) {
        let groupJoiningUpdatesRef = Database.database().reference().child("groups").child(Group.groupDataDB).child(groupId).child("updates").child(GroupJoiningUpdate.joiningGroupDatabase)
        groupJoiningUpdatesRef.observeSingleEvent(of: .value, with: { (snapshot) in
            
            guard let dictionary = snapshot.value as? [String: Any] else { return }
            dictionary.forEach({ (key, value) in
                
                GroupJoiningUpdate.fetchJoiningUpdate(updateId: key, completion: { (joiningUpdate) in
                    
                    let updateContained = self.joiningUpdates.contains(where: { (joiningUpdate) -> Bool in
                        return joiningUpdate.id == key
                    })
                    if !updateContained {
                        GroupJoiningUpdate.fetchJoiningUpdate(updateId: key, completion: { (groupJoiningUpdate) in
                            self.joiningUpdates.append(groupJoiningUpdate)
                            self.showNewMember(groupJoiningUpdate: groupJoiningUpdate)
                        })
                    }
                })
            })
        }) { (err) in
            print("failed to fetch groupJoiningUpdates")
        }
    }
    
    func showNewMember(groupJoiningUpdate: GroupJoiningUpdate) {
        guard let updateTimestamp = groupJoiningUpdate.timestamp else { return }
        let updateTimeInterval = updateTimestamp.timeIntervalSince1970
        let currentTimestamp = Date().timeIntervalSince1970
        
        if Int(currentTimestamp) - Int(updateTimeInterval) <= 6 {
            self.newestGroupJoining = groupJoiningUpdate
        }
    }
    
    fileprivate func fetchMembers(group: Group) {
        members.removeAll()
        guard let memberIds = group.memberIds else { return }
        for memberId in memberIds {
            Database.fetchUserWithUID(uid: memberId, completion: { (member) in
                self.members.append(member)
                self.collectionView.reloadData()
            })
        }
    }
    
    override func setupViews() {
        //nthn
        
        scrollContainerView.addSubview(gameImageView)
        
        scrollContainerView.addSubview(currentMemberLabel)
        scrollContainerView.addSubview(descriptionLabel)
        
        scrollContainerView.addSubview(collectionView)
        scrollContainerView.addSubview(addButton)
        scrollContainerView.addSubview(leaveButton)
        
        scrollContainerView.addSubview(pageControl)
        
        gameImageView.anchor(top: view.topAnchor, left: scrollContainerView.leftAnchor, bottom: scrollContainerView.topAnchor, right: scrollContainerView.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: -175, paddingRight: 0, width: 0, height: 0)
        
        currentMemberLabel.anchor(top: gameImageView.bottomAnchor, left: scrollContainerView.leftAnchor, bottom: nil, right: scrollContainerView.rightAnchor, paddingTop: 8, paddingLeft: 8, paddingBottom: 0, paddingRight: 8, width: 0, height: 50)
        
        pageControl.anchor(top: scrollContainerView.topAnchor, left: nil, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 100, height: 32)
        pageControl.centerXAnchor.constraint(equalTo: scrollContainerView.centerXAnchor).isActive = true
        
        descriptionLabel.anchor(top: currentMemberLabel.bottomAnchor, left: scrollContainerView.leftAnchor, bottom: nil, right: scrollContainerView.rightAnchor, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 8, width: 0, height: 50)
        
        collectionView.anchor(top: descriptionLabel.bottomAnchor, left: scrollContainerView.leftAnchor, bottom: nil, right: scrollContainerView.rightAnchor, paddingTop: 8, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 150)
        
        addButton.anchor(top: collectionView.bottomAnchor, left: scrollContainerView.leftAnchor, bottom: nil, right: scrollContainerView.rightAnchor, paddingTop: 8, paddingLeft: 8, paddingBottom: 0, paddingRight: 8, width: 0, height: 50)
        
        if #available(iOS 11.0, *) {
            leaveButton.anchor(top: nil, left: scrollContainerView.leftAnchor, bottom: scrollContainerView.safeAreaLayoutGuide.bottomAnchor, right: scrollContainerView.rightAnchor, paddingTop: 0, paddingLeft: 8, paddingBottom: 73, paddingRight: 8, width: 0, height: 50)
        } else {
            // Fallback on earlier versions
            leaveButton.anchor(top: nil, left: scrollContainerView.leftAnchor, bottom: scrollContainerView.bottomAnchor, right: scrollContainerView.rightAnchor, paddingTop: 0, paddingLeft: 8, paddingBottom: 73, paddingRight: 8, width: 0, height: 50)
        }
        
        setupUpdateView()
    }
    
    var updateViewTopAnchor: NSLayoutConstraint?
    
    func setupUpdateView() {
        view.addSubview(updateView)
        
        updateViewTopAnchor = updateView.topAnchor.constraint(equalTo: view.topAnchor, constant: -50)
        updateViewTopAnchor?.isActive = true
        updateView.anchor(top: nil, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 50)
        
        
        updateView.addSubview(updateLabel)
        updateLabel.anchor(top: updateView.topAnchor, left: updateView.leftAnchor, bottom: updateView.bottomAnchor, right: updateView.rightAnchor, paddingTop: 4, paddingLeft: 4, paddingBottom: 4, paddingRight: 4, width: 0, height: 0)
    }
    
    fileprivate func setupUpdateView(username: String) {
        guard let text = self.newestGroupJoining?.text else { return }
        
        let attributedText = NSMutableAttributedString(string: username, attributes: [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 16), NSAttributedStringKey.foregroundColor: ColorCodes.clansportlerPurple])
        
        attributedText.append(NSAttributedString(string: " \(text) ", attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 16), NSAttributedStringKey.foregroundColor: UIColor.white]))
        
        self.updateLabel.attributedText = attributedText
        
        self.updateViewTopAnchor?.constant = 0
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.view.layoutIfNeeded()
        }, completion: { (completed) in
            
            self.updateViewTopAnchor?.constant = -50
            UIView.animate(withDuration: 0.3, delay: 2.5, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                self.view.layoutIfNeeded()
            }, completion: { (completed) in
                //here completion
            })
        })
    }
    
    @objc func handleAdd() {
        let layout = UICollectionViewFlowLayout()
        let selectUserController = SelectUserCollectionViewController(collectionViewLayout: layout)
        
        navigationController?.pushViewController(selectUserController, animated: true)
        
        selectUserController.openGroupController = self
    }
    
    @objc func handleLeave() {
        let alertController = UIAlertController(title: "Leave Group", message: "Do you really want to leave the group?", preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { (action) in
            alertController.dismiss(animated: true, completion: nil)
        }))
        alertController.addAction(UIAlertAction(title: "Leave", style: .destructive, handler: { (action) in
            
            self.leaveGroup()
            
        }))
        self.present(alertController, animated: true, completion: nil)
    }
    
    func leaveGroup() {
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
        guard let groupId = self.group?.id else { return }
        
        GroupLeavingUpdate.uploadGroupLeavingUpdateToDatabase(groupId: groupId, userId: currentUserId)
        
        let userRef = Database.database().reference().child("users").child(currentUserId).child(Group.currentGroupDatabase)
        userRef.removeValue { (err, _) in
            if let err = err {
                print("failed to delete current Group from user", err)
            }
        }
        let groupMemberRef = Database.database().reference().child("groups").child(Group.groupDataDB).child(groupId).child("memberIds").child(currentUserId)
        groupMemberRef.removeValue { (err, _) in
            if let err = err {
                print("Failed to delete user from group", err)
            }
        }
        
        if self.group?.adminId == currentUserId {
            self.updateAdmin(groupId: groupId)
        }
        
        if group?.currentGroupMemberCount == group?.maxGroupMember {
            self.reloadToOpenGroups(groupId)
        }
        
        
        DispatchQueue.main.async {
            _ = Timer.scheduledTimer(timeInterval: 2.0, target: self, selector: #selector(self.handleDismiss), userInfo: nil, repeats: false)
        }
    }
    
    @objc func handleDismiss() {
        self.dismiss(animated: true) { 
            // completion here
        }
    }
    
    func reloadToOpenGroups(_ groupId: String) {
        guard let gameId = group?.gameId else { return }
        
        let groupValues: [String: Any] = [groupId: 1]
        
        let openGroupRef = Database.database().reference().child("groups").child(Group.gameGroupsDatabase).child(gameId)
        openGroupRef.updateChildValues(groupValues) { (err, _) in
            if let err = err {
                print("Failed to upload to open games", err)
            }
        }
        
        let values: [String: Any] = ["isOpen": true]
        let groupRef = Database.database().reference().child("groups").child(Group.groupDataDB).child(groupId)
        groupRef.updateChildValues(values) { (err, _) in
            if let err = err {
                print("failed to upload isOpen to group ref", err)
            }
        }
    }
    
    func updateAdmin(groupId: String) {
        Database.fetchAndObserveGroupWithId(id: groupId) { (group) in
            self.group = group
            
            if let memberIds = group.memberIds {
                guard let nextAdminId = memberIds.first else { return }
                
                let values: [String: Any] = ["adminId": nextAdminId]
                
                let groupRef = Database.database().reference().child("groups").child(Group.groupDataDB).child(groupId)
                groupRef.updateChildValues(values) { (err, _) in
                    if let err = err {
                        print("failed to upload new admin", err)
                    }
                }
            } else {
                Group.closeGroup(group: group)
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return members.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! GroupMemberCell
        cell.openGroupController = self
        let user = members[indexPath.item]
        cell.user = user
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width: CGFloat = 125
        let height: CGFloat = 150
        
        return CGSize(width: width, height: height)
    }
    
    lazy var joinGroupModalController: JoinGroupModalController = {
        let joinGroupModalController = JoinGroupModalController()
        joinGroupModalController.modalPresentationStyle = .overCurrentContext
        joinGroupModalController.modalTransitionStyle = .crossDissolve
        joinGroupModalController.delegate = self
        return joinGroupModalController
    }()
    
    func didTapJoin(joinGroupModalController: JoinGroupModalController) {
        self.joinGroup()
        joinGroupModalController.dismiss(animated: true) {
            //completion here
        }
    }
    
    func didTapCancel(joinGroupModalController: JoinGroupModalController) {
        joinGroupModalController.dismiss(animated: true, completion: nil)
        self.dismiss(animated: true) {
            //completion here
        }
    }
    
    lazy var gamenameModalController: GamenameModalController = {
        let controller = GamenameModalController()
        controller.delegate = self
        controller.modalTransitionStyle = .crossDissolve
        controller.modalPresentationStyle = .overCurrentContext
        return controller
    }()
    
    func didTapContinue(gamenameModalController: GamenameModalController, playername: String) {
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
        
        guard let gameId = self.gameId else { return }
        self.uploadPlayerGamename(userId: currentUserId, gameId: gameId, playername: playername)
        
        gamenameModalController.dismiss(animated: true) {
            
            self.present(self.joinGroupModalController, animated: true, completion: {
                //completion here
            })
        }
    }
    
    func uploadPlayerGamename(userId: String, gameId: String, playername: String) {
        let nameValues: [String: Any] = [gameId: playername]
        let userRef = Database.database().reference().child("users").child(userId).child("authentications")
        userRef.updateChildValues(nameValues) { (err, _) in
            if let err = err {
                print("failed to upload game name", err)
            }
        }
    }
    
    func didTapCancel(gamenameModalController: GamenameModalController) {
        gamenameModalController.dismiss(animated: true, completion: nil)
        self.dismiss(animated: true) { 
            //completion here
        }
    }
    
    func showJoiningAlertController() {
        guard let gameId = gameId else { return }
        guard let groupIsOpen = group?.isOpen else { return }
        
        if groupIsOpen {
            if currentUser?.authentications?[gameId] != nil {
                
                self.present(self.joinGroupModalController, animated: true, completion: {
                    //completion here
                })
                
            } else {
                self.gamenameModalController.game = self.game
                self.present(gamenameModalController, animated: true) {
                    //completion ere
                }
            }
        } else {
            let notOpenController = GroupNotOpenModalController()
            notOpenController.openGroupController = self
            notOpenController.modalTransitionStyle = .crossDissolve
            notOpenController.modalPresentationStyle = .overCurrentContext
            
            self.present(notOpenController, animated: true, completion: { 
                //completion here
            })
        }
    }
    
    func joinGroup() {
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
        guard let groupId = self.group?.id else { return }
        guard let groupchatId = self.group?.groupchatId else { return }
        
        let userValues: [String: Any] = [Group.currentGroupDatabase: groupId]
        
        let userRef = Database.database().reference().child("users").child(currentUserId)
        userRef.updateChildValues(userValues) { (err, _) in
            if let err = err {
                print("Failed to update current Group status", err)
            }
        }
        
        let groupValues: [String: Any] = [currentUserId: 1]
        
        let groupRef = Database.database().reference().child("groups").child(Group.groupDataDB).child(groupId).child("memberIds")
        groupRef.updateChildValues(groupValues) { (err, _) in
            if let err = err {
                print("failed to update memberIds in groupRef", err)
            }
        }
        
        Database.uploadUserGroupChats(currentUserId: currentUserId, groupchatId: groupchatId)
        
        Database.fetchAndObserveGroupWithId(id: groupId) { (currentGroup) in
            self.group = currentGroup
            
            if currentGroup.currentGroupMemberCount == currentGroup.maxGroupMember {
                Group.closeGroup(group: currentGroup)
            }
        }
        GroupJoiningUpdate.uploadGroupJoiningUpdate(groupId: groupId, userId: currentUserId)
    }
    
    fileprivate func setupWildcardUser() {
        let uid = UUID().uuidString
        let dictionary: [String: Any] = ["profileImageUrl": "https://firebasestorage.googleapis.com/v0/b/clansportler.appspot.com/o/clansportler_pictures%2FAvatar.png?alt=media&token=6e860c19-3d9f-41b9-b2c3-7549670a7f25", "username": "wildcard"]
        let user = User(uid: uid, dictionary: dictionary)
        
        self.members.append(user)
        self.collectionView.reloadData()
    }
    
    func sendGroupInvitation(userId: String) {
        guard let game = self.game else { return }
        guard let groupId = self.group?.id else { return }
        
        Database.sendGroupInvitation(groupId: groupId, toId: userId, game: game)
    }
    
}















