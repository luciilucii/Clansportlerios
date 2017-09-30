//
//  CreateGroupController.swift
//  Clansportler
//
//  Created by Luca Kiedrowski on 31.08.17.
//  Copyright © 2017 LucaKiedrowski. All rights reserved.
//

import UIKit
import Firebase
import Social

class CreateGroupController: ScrollController, UIPickerViewDelegate, UIPickerViewDataSource, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, GamenameModalControllerDelegate {
    
    let cellId = "cellId"
    
    var games = [Game]()
    var pickerView = UIPickerView()
    
    var groupsController: GroupsController?
    var homeController: HomeController?
    
    var choosenGame: Game?
    
    var selectedMembers = [User]() {
        didSet {
            if selectedMembers.count == 0 {
                membersCollectionView.isHidden = true
                friendLabel.isHidden = false
                chooseMembersButton.isHidden = false
            } else {
                membersCollectionView.isHidden = false
                friendLabel.isHidden = true
                chooseMembersButton.isHidden = true
            }
            membersCollectionView.reloadData()
        }
    }
    
    var currentUser: User? {
        didSet {
            fetchGames()
        }
    }
    
    let chooseGamesTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Choose the Game"
        label.textColor = UIColor.white
        label.font = UIFont.boldSystemFont(ofSize: 16)
        return label
    }()
    
    lazy var gameTextField: UITextField = {
        let tf = UITextField()
        tf.textColor = UIColor.white
        tf.backgroundColor = .clear
        tf.layer.borderColor = UIColor.white.cgColor
        tf.layer.borderWidth = 1
        tf.placeholder = "Game"
        tf.tintColor = UIColor.white
        tf.layer.cornerRadius = 5
        tf.setLeftPaddingPoints(5)
        tf.setRightPaddingPoints(5)
        tf.addTarget(self, action: #selector(handleInputChange), for: .editingChanged)
        return tf
    }()
    
    let infoTextTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "What do you search for?"
        label.textColor = UIColor.white
        label.font = UIFont.boldSystemFont(ofSize: 16)
        return label
    }()
    
    lazy var infoTextField: UITextField = {
        let tf = UITextField()
        tf.textColor = UIColor.white
        tf.backgroundColor = .clear
        tf.layer.borderColor = UIColor.white.cgColor
        tf.layer.borderWidth = 1
        tf.placeholder = "Description"
        tf.tintColor = UIColor.white
        tf.autocorrectionType = .no
        tf.layer.cornerRadius = 5
        tf.setLeftPaddingPoints(5)
        tf.setRightPaddingPoints(5)
        tf.addTarget(self, action: #selector(handleInputChange), for: .editingChanged)
        return tf
    }()
    
    let currentPlayerTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "How many Wildcards are in the Group?"
        label.textColor = UIColor.white
        label.font = UIFont.boldSystemFont(ofSize: 16)
        return label
    }()
    
    let selectWildcardsLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.white
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 14)
        label.text = "How many wildcards should we add to your group? These are user that you currently play with, but aren’t in this clansportler group."
        label.numberOfLines = 0
        return label
    }()
    
    let memberPlayerPickerView: PlayerPickerView = {
        let pv = PlayerPickerView()
        pv.currentNumber = 0
        pv.bottomLimit = 0
        return pv
    }()
    
    let friendLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.white
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 14)
        label.text = "Add your Friends to the Group so they can join the Chat and recieve achievements."
        label.numberOfLines = 3
        return label
    }()
    
    lazy var chooseMembersButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = ColorCodes.clansportlerBlue
        button.setTitle("Add Members", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.tintColor = UIColor.white
        button.layer.borderWidth = 2
        button.layer.borderColor = UIColor.white.cgColor
        button.layer.cornerRadius = 5
        button.addTarget(self, action: #selector(handleChooseMembers), for: .touchUpInside)
        return button
    }()
    
    let inviteLabel: UILabel = {
        let label = UILabel()
        label.text = "Invite your friends to join"
        label.textColor = UIColor.white
        label.font = UIFont.boldSystemFont(ofSize: 16)
        return label
    }()
    
    lazy var inviteButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = UIColor.white
        button.setTitle("Invite", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.tintColor = ColorCodes.clansportlerBlue
        button.layer.cornerRadius = 5
        button.addTarget(self, action: #selector(handleShare), for: .touchUpInside)
        return button
    }()
    
    let searchPlayerLabel: UILabel = {
        let label = UILabel()
        label.text = "How many players to you search?"
        label.textColor = UIColor.white
        label.font = UIFont.boldSystemFont(ofSize: 16)
        return label
    }()
    
    let searchPlayerPickerView: PlayerPickerView = {
        let pv = PlayerPickerView()
        pv.currentNumber = 2
        return pv
    }()
    
    lazy var openGroupButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = ColorCodes.disabledRed
        button.isEnabled = false
        button.setTitle("Open", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.tintColor = UIColor.white
        button.layer.cornerRadius = 5
        button.addTarget(self, action: #selector(checkIfUserHasPlayername), for: .touchUpInside)
        return button
    }()
    
    lazy var membersCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.dataSource = self
        cv.delegate = self
        cv.backgroundColor = ColorCodes.clansportlerBlue
        cv.isHidden = true
        cv.alwaysBounceHorizontal = true
        return cv
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        super.setupScrollView(height: 894)
        
        hideKeyboardWhenTappedAround(views: [view, scrollContainerView])
        
        setupController()
        
        setupWhiteTitle(title: "Open a Group")
        setupBarCancelButton()
        
        fetchCurrentUser()
        
    }
    
    func fetchCurrentUser() {
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
        
        Database.fetchUserWithUID(uid: currentUserId) { (user) in
            self.currentUser = user
        }
        
    }
    
    override func setupController() {
        navigationController?.navigationBar.isTranslucent = false
        setupViews()
        
        view.backgroundColor = ColorCodes.clansportlerBlue
        
        membersCollectionView.register(MemberCell.self, forCellWithReuseIdentifier: cellId)
        membersCollectionView.alwaysBounceHorizontal = false
    }
    
    override func setupViews() {
        
        pickerView.dataSource = self
        pickerView.delegate = self
        
        gameTextField.inputView = pickerView
        
        scrollContainerView.addSubview(chooseGamesTitleLabel)
        scrollContainerView.addSubview(gameTextField)
        scrollContainerView.addSubview(infoTextTitleLabel)
        scrollContainerView.addSubview(infoTextField)
        scrollContainerView.addSubview(currentPlayerTitleLabel)
        scrollContainerView.addSubview(selectWildcardsLabel)
        scrollContainerView.addSubview(memberPlayerPickerView)
        
        scrollContainerView.addSubview(friendLabel)
        scrollContainerView.addSubview(chooseMembersButton)
        
        scrollContainerView.addSubview(membersCollectionView)
        
        scrollContainerView.addSubview(inviteLabel)
        scrollContainerView.addSubview(inviteButton)
        
        scrollContainerView.addSubview(searchPlayerLabel)
        scrollContainerView.addSubview(searchPlayerPickerView)
        scrollContainerView.addSubview(openGroupButton)
        
        chooseGamesTitleLabel.anchor(top: scrollContainerView.topAnchor, left: scrollContainerView.leftAnchor, bottom: nil, right: scrollContainerView.rightAnchor, paddingTop: 8, paddingLeft: 8, paddingBottom: 0, paddingRight: 8, width: 0, height: 25)
        
        gameTextField.anchor(top: chooseGamesTitleLabel.bottomAnchor, left: scrollContainerView.leftAnchor, bottom: nil, right: scrollContainerView.rightAnchor, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 8, width: 0, height: 35)
        
        infoTextTitleLabel.anchor(top: gameTextField.bottomAnchor, left: scrollContainerView.leftAnchor, bottom: nil, right: scrollContainerView.rightAnchor, paddingTop: 8, paddingLeft: 8, paddingBottom: 0, paddingRight: 8, width: 0, height: 25)
        infoTextField.anchor(top: infoTextTitleLabel.bottomAnchor, left: scrollContainerView.leftAnchor, bottom: nil, right: scrollContainerView.rightAnchor, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 8, width: 0, height: 35)
        
        currentPlayerTitleLabel.anchor(top: infoTextField.bottomAnchor, left: scrollContainerView.leftAnchor, bottom: nil, right: scrollContainerView.rightAnchor, paddingTop: 8, paddingLeft: 8, paddingBottom: 0, paddingRight: 8, width: 0, height: 25)
        
        selectWildcardsLabel.anchor(top: currentPlayerTitleLabel.bottomAnchor, left: scrollContainerView.leftAnchor, bottom: nil, right: scrollContainerView.rightAnchor, paddingTop: 8, paddingLeft: 8, paddingBottom: 0, paddingRight: 8, width: 0, height: 65)
        
        memberPlayerPickerView.anchor(top: selectWildcardsLabel.bottomAnchor, left: scrollContainerView.leftAnchor, bottom: nil, right: scrollContainerView.rightAnchor, paddingTop: 8, paddingLeft: 8, paddingBottom: 0, paddingRight: 8, width: 0, height: 124)
        
        friendLabel.anchor(top: memberPlayerPickerView.bottomAnchor, left: scrollContainerView.leftAnchor, bottom: nil, right: scrollContainerView.rightAnchor, paddingTop: 8, paddingLeft: 8, paddingBottom: 0, paddingRight: 8, width: 0, height: 67)
        
        chooseMembersButton.anchor(top: friendLabel.bottomAnchor, left: scrollContainerView.leftAnchor, bottom: nil, right: scrollContainerView.rightAnchor, paddingTop: 8, paddingLeft: 8, paddingBottom: 0, paddingRight: 8, width: 0, height: 50)
        
        
        membersCollectionView.anchor(top: memberPlayerPickerView.bottomAnchor, left: scrollContainerView.leftAnchor, bottom: nil, right: scrollContainerView.rightAnchor, paddingTop: 8, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 125)
        
        
        
        inviteLabel.anchor(top: chooseMembersButton.bottomAnchor, left: scrollContainerView.leftAnchor, bottom: nil, right: scrollContainerView.rightAnchor, paddingTop: 8, paddingLeft: 8, paddingBottom: 0, paddingRight: 8, width: 0, height: 25)
        
        inviteButton.anchor(top: inviteLabel.bottomAnchor, left: scrollContainerView.leftAnchor, bottom: nil, right: scrollContainerView.rightAnchor, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 8, width: 0, height: 50)
        
        searchPlayerLabel.anchor(top: inviteButton.bottomAnchor, left: scrollContainerView.leftAnchor, bottom: nil, right: scrollContainerView.rightAnchor, paddingTop: 8, paddingLeft: 8, paddingBottom: 0, paddingRight: 8, width: 0, height: 25)
        
        searchPlayerPickerView.anchor(top: searchPlayerLabel.bottomAnchor, left: scrollContainerView.leftAnchor, bottom: nil, right: scrollContainerView.rightAnchor, paddingTop: 8, paddingLeft: 8, paddingBottom: 0, paddingRight: 8, width: 0, height: 124)
        
        openGroupButton.anchor(top: searchPlayerPickerView.bottomAnchor, left: scrollContainerView.leftAnchor, bottom: nil, right: scrollContainerView.rightAnchor, paddingTop: 16, paddingLeft: 8, paddingBottom: 0, paddingRight: 8, width: 0, height: 50)
        
    }
    
    fileprivate func fetchGames() {
        
        guard let gameIds = currentUser?.gameIds else {
            
            //maybe show ChoosegamesController?
            return
        }
        
        gameIds.forEach { (gameId) in
            Database.fetchGameWithId(id: gameId, completion: { (game) in
                self.games.append(game)
                self.pickerView.reloadAllComponents()
            })
        }
//
//        let approveGamesRef = Database.database().reference().child("games").child("approvedGames")
//        approveGamesRef.observeSingleEvent(of: .value, with: { (snapshot) in
//
//            guard let dictionary = snapshot.value as? [String: Any] else { return }
//            dictionary.forEach({ (key, value) in
//                Database.fetchGameWithId(id: key, completion: { (game) in
//                    self.games.append(game)
//                    self.pickerView.reloadAllComponents()
//                })
//            })
//        }) { (err) in
//            print("failed to fetch approved Games", err)
//        }
    }
    
    fileprivate func enableOpenButton() {
        openGroupButton.isEnabled = true
        openGroupButton.setTitle("Open", for: .normal)
        openGroupButton.backgroundColor = ColorCodes.clansportlerRed
    }
    
    @objc func checkIfUserHasPlayername() {
        guard let choosenGameId = choosenGame?.id else { return }
        
        if currentUser?.authentications?[choosenGameId] != nil {
            handleUploadGroupToDatabase()
        } else {
            let gamenameModalController = GamenameModalController()
            gamenameModalController.delegate = self
            gamenameModalController.game = choosenGame
            
            gamenameModalController.modalPresentationStyle = .overCurrentContext
            gamenameModalController.modalTransitionStyle = .crossDissolve
            
            present(gamenameModalController, animated: true, completion: { 
                //Completion here
            })
        }
    }
    
    func didTapCancel(gamenameModalController: GamenameModalController) {
        gamenameModalController.dismiss(animated: true) { 
            //completion here
        }
    }
    
    func didTapContinue(gamenameModalController: GamenameModalController, playername: String) {
        guard let currentUserId = currentUser?.id else { return }
        
        guard let gameId = choosenGame?.id else { return }
        self.uploadPlayerGamename(userId: currentUserId, gameId: gameId, playername: playername)
        
        userCache[currentUserId] = nil
        
        gamenameModalController.dismiss(animated: true) {
            self.handleUploadGroupToDatabase()
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
    
    func handleUploadGroupToDatabase() {
        openGroupButton.isEnabled = false
        openGroupButton.setTitle("Loading...", for: .normal)
        openGroupButton.backgroundColor = ColorCodes.disabledRed
        
        let groupId = UUID().uuidString
        
        guard let game = self.choosenGame else {
            self.enableOpenButton()
            return
        }
        let gameId = game.id
        
        let wildcardCount = memberPlayerPickerView.currentNumber
        let searchMemberInt = searchPlayerPickerView.currentNumber
        
        let alreadyInGroupInt = 1
        
        let groupSize = alreadyInGroupInt + searchMemberInt + wildcardCount
        
        guard let groupDescription = infoTextField.text else { return }
        let createdAt = Date().timeIntervalSince1970
        let lastUpdate = Date().timeIntervalSince1970
        
        guard let currentUserId = currentUser?.id else { return }
        
        let memberDictionary: [String: Any] = [currentUserId: 1]
        for member in self.selectedMembers {
            Database.sendGroupInvitation(groupId: groupId, toId: member.id, game: game)
        }
        
        var groupValues: [String: Any] = [Group.maxGroupMemberDatabase: groupSize, "description": groupDescription, "createdAt": createdAt, "isOpen": true, "adminId": currentUserId, "memberIds": memberDictionary, "gameId": gameId, Group.lastUpdateDatabase: lastUpdate]
        
        if wildcardCount > 0 {
            groupValues["wildcardCount"] = wildcardCount
        }
        
        let gameGroupValues: [String: Any] = [groupId: 1]
        
        let groupRef = Database.database().reference().child("groups").child(Group.gameGroupsDatabase).child(gameId)
        groupRef.updateChildValues(gameGroupValues) { (err, _) in
            if let err = err {
                print("failed to upload group", err)
                self.enableOpenButton()
            }
        }
        
        let groupDataRef = Database.database().reference().child("groups").child(Group.groupDataDB).child(groupId)
        groupDataRef.updateChildValues(groupValues) { (err, _) in
            if let err = err {
                print("failed to upload group", err)
                self.enableOpenButton()
            }
        }
        
        uploadGroupchat(gameId: gameId, groupId: groupId, memberDictionary: memberDictionary)
    }
    
    func uploadGroupchat(gameId: String, groupId: String, memberDictionary: [String: Any]) {
        let groupchatId = UUID().uuidString
        
        let groupValues: [String: Any] = ["groupchat": groupchatId]
        
        let groupRef = Database.database().reference().child("groups").child(Group.groupDataDB).child(groupId)
        groupRef.updateChildValues(groupValues) { (err, _) in
            if let err = err {
                print("failed to upload groupchat into group ref", err)
            }
        }
        
        let groupchatValues: [String: Any] = ["name": "groupchat", "users": memberDictionary]
        
        let groupchatRef = Database.database().reference().child("groupchats").child(groupchatId)
        groupchatRef.updateChildValues(groupchatValues) { (err, _) in
            if let err = err {
                print("failed to upload group chat into db", err)
            }
        }
        
        self.showOpenGroupController(groupId: groupId, gameId: gameId)
        self.uploadCurrentGroupForUser(groupId: groupId)
    }
    
    func uploadCurrentGroupForUser(groupId: String) {
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
        
        let userValues: [String: Any] = [Group.currentGroupDatabase: groupId]
        
        let userRef = Database.database().reference().child("users").child(currentUserId)
        userRef.updateChildValues(userValues) { (err, _) in
            if let err = err {
                print("failed to upload current Group to user", err)
            }
        }
        
        GroupJoiningUpdate.uploadGroupJoiningUpdate(groupId: groupId, userId: currentUserId)
    }
    
    func showOpenGroupController(groupId: String, gameId: String) {
        let openGroupController = OpenGroupController()
        
        openGroupController.groupId = groupId
        openGroupController.game = choosenGame
        
        let navController = UINavigationController(rootViewController: openGroupController)
        
        dismiss(animated: true) {
            //completion here
            
            if let homeController = self.homeController {
                homeController.present(navController, animated: true, completion: {
                    //completion here
                })
            }
            
            if let groupsController = self.groupsController {
                groupsController.present(navController, animated: true, completion: {
                    //completion here
                })
            }
        }
    }
    
    @objc func handleChooseMembers() {
        let layout = UICollectionViewFlowLayout()
        let selectUserController = SelectUserCollectionViewController(collectionViewLayout: layout)
        
        navigationController?.pushViewController(selectUserController, animated: true)
        
        selectUserController.createGroupController = self
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = 100
        let height = 125
        
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! MemberCell
        
        let user = selectedMembers[indexPath.item]
        cell.user = user
        
        cell.profileImageView.layer.borderColor = UIColor.white.cgColor
        cell.usernameLabel.textColor = UIColor.white
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return selectedMembers.count
    }
    
    //MARK: Picker View
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        if row == 0 {
            return "No Selection"
        }
        
        let game = games[row - 1]
        guard let gamename = game.name else { return "" }
        
        return gamename
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return games.count + 1
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        if row == 0 {
            gameTextField.text = ""
            return
        }
        let game = games[row - 1]
        
        self.choosenGame = game
        guard let gamename = game.name else { return }
        
        gameTextField.text = gamename
    }
    
    @objc func handleInputChange() {
        
        if gameTextField.text?.characters.count ?? 0 > 0 && infoTextField.text?.characters.count ?? 0 > 0 {
            openGroupButton.isEnabled = true
            openGroupButton.backgroundColor = ColorCodes.clansportlerRed
        } else {
            openGroupButton.isEnabled = false
            openGroupButton.backgroundColor = ColorCodes.disabledRed
        }
        
        
    }
    
    @objc func handleShare() {
        let eventLink = "https://www.clansportler.com"
        let eventShareText = "Hey, lets play some games together with Clansportler! You can download it here: \n"
        
        let activityVC = UIActivityViewController(activityItems: ["\(eventShareText)\(eventLink)"], applicationActivities: nil)
        activityVC.popoverPresentationController?.sourceView = self.view
        
        self.present(activityVC, animated: true, completion: nil)
        
    }
    
}



















