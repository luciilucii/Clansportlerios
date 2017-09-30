//
//  UserProfileController.swift
//  Clansportler
//
//  Created by Luca Kiedrowski on 07.08.17.
//  Copyright © 2017 LucaKiedrowski. All rights reserved.
//

import UIKit
import Firebase
import FirebaseMessaging

class UserProfileController: ScrollController {
    
    static let updateGamesViewNotification = Notification.Name("UpdateGamesViewNotification")
    
    let cellId = "cellId"
    
    var userId: String?
    
    var user: User? {
        didSet {
            guard let username = user?.username else { return }
            setupWhiteTitle(title: username)
            
            guard let uid = user?.id else { return }
            setupFollowButton(uid)
            
            guard let imageUrlString = user?.profileImageUrl else { return }
            profileImageBackgroundView.loadAndConvertToGray(urlString: imageUrlString)
            
            profileImageView.loadImage(urlString: imageUrlString)
            
            checkIfUserHasChoosenGames()
            
            myTeamView.user = user
            suggestedClansView.user = user
            myGamesView.user = user
            
            if let teamId = user?.team {
                Database.fetchTeamWithId(uid: teamId, completion: { (fetchedTeam) in
                    self.team = fetchedTeam
                })
            } else {
                setupStackView(followers: 0, clanname: "No Clan", tournaments: 5)
            }
        }
    }
    
    var isJoiningRequest: Bool?
    
    var team: Team? {
        didSet {
            guard let teamname = team?.teamname else { return }
            
            setupStackView(followers: 0, clanname: teamname, tournaments: 4)
            
            myTeamView.team = team
            
            suggestedClansView.isHidden = true
            myTeamView.isHidden = false
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollContainerView.backgroundColor = ColorCodes.backgroundGrey
        
        super.setupScrollView(height: 867)
        
        super.setupController()
        
        navigationController?.navigationBar.tintColor = .white
        
        setupViews()
        fetchUser()
    }
    
    fileprivate func fetchUser() {
        if user == nil {
            let uid = Auth.auth().currentUser?.uid ?? ""
            
            Database.fetchUserWithUID(uid: uid) { (user) in
                self.user = user
                self.editButton.isHidden = false
                
                self.setupLogOutButton()
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard let username = user?.username else { return }
        setupWhiteTitle(title: username)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        navigationItem.title = " "
    }
    
    let profileImageBackgroundView: CustomImageView = {
        let iv = CustomImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        return iv
    }()
    
    let blackEffectView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black
        view.alpha = 0.75
        return view
    }()
    
    let profileImageView: CustomImageView = {
        let iv = CustomImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        return iv
    }()
    
    lazy var editButton: UIButton = {
        let button = UIButton(type: .system)
        button.layer.borderColor = UIColor.white.cgColor
        button.layer.borderWidth = 1
        button.layer.cornerRadius = 5
        button.setTitle("Settings", for: .normal)
        button.tintColor = UIColor.white
        button.isHidden = true
        button.addTarget(self, action: #selector(handleSettings), for: .touchUpInside)
        return button
    }()
    
    lazy var followButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = ColorCodes.clansportlerRed
        button.setTitle("Follow", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.tintColor = UIColor.white
        button.isHidden = true
        button.layer.cornerRadius = 5
        return button
    }()
    
    lazy var acceptButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = ColorCodes.clansportlerRed
        button.setTitle("Accept", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.tintColor = UIColor.white
        button.isHidden = true
        button.addTarget(self, action: #selector(handleAcceptToTeam), for: .touchUpInside)
        button.layer.cornerRadius = 5
        return button
    }()
    
    lazy var myGamesView: UserProfileGamesView = {
        let view = UserProfileGamesView()
        view.userProfileController = self
        return view
    }()
    
    lazy var myTeamView: MyTeamView = {
        let tv = MyTeamView()
        tv.isHidden = true
        tv.userProfileController = self
        return tv
    }()
    
    lazy var suggestedClansView: SuggestedClansView = {
        let suggestedClansView = SuggestedClansView()
        suggestedClansView.profileController = self
        suggestedClansView.isHidden = false
        return suggestedClansView
    }()
    
    lazy var userAchievementsView: UserAchievementsView = {
        let uAV = UserAchievementsView()
        return uAV
    }()
    
    override func setupViews() {
        scrollContainerView.addSubview(profileImageBackgroundView)
        scrollContainerView.addSubview(blackEffectView)
        
        profileImageBackgroundView.anchor(top: view.topAnchor, left: scrollContainerView.leftAnchor, bottom: scrollContainerView.topAnchor, right: scrollContainerView.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: -175, paddingRight: 0, width: 0, height: 0)
        
        blackEffectView.anchor(top: profileImageBackgroundView.topAnchor, left: profileImageBackgroundView.leftAnchor, bottom: profileImageBackgroundView.bottomAnchor, right: profileImageBackgroundView.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        
        scrollContainerView.addSubview(profileImageView)
        profileImageView.anchor(top: scrollContainerView.topAnchor, left: nil, bottom: nil, right: nil, paddingTop: 15, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 100, height: 100)
        profileImageView.centerXAnchor.constraint(equalTo: scrollContainerView.centerXAnchor).isActive = true
        profileImageView.layer.cornerRadius = 100 / 2
        
        scrollContainerView.addSubview(editButton)
        scrollContainerView.addSubview(followButton)
        scrollContainerView.addSubview(acceptButton)
        
        
        editButton.anchor(top: scrollContainerView.topAnchor, left: scrollContainerView.leftAnchor, bottom: nil, right: scrollContainerView.rightAnchor, paddingTop: 8 + 175, paddingLeft: 8, paddingBottom: 0, paddingRight: 8, width: 0, height: 44)
        
        followButton.anchor(top: scrollContainerView.topAnchor, left: scrollContainerView.leftAnchor, bottom: nil, right: scrollContainerView.rightAnchor, paddingTop: 8 + 175, paddingLeft: 8, paddingBottom: 0, paddingRight: 8, width: 0, height: 44)
        
        acceptButton.anchor(top: scrollContainerView.topAnchor, left: scrollContainerView.leftAnchor, bottom: nil, right: scrollContainerView.rightAnchor, paddingTop: 8 + 175, paddingLeft: 8, paddingBottom: 0, paddingRight: 8, width: 0, height: 44)
        
        scrollContainerView.addSubview(myGamesView)
        
        scrollContainerView.addSubview(myTeamView)
        scrollContainerView.addSubview(suggestedClansView)
        scrollContainerView.addSubview(userAchievementsView)
        
        myGamesView.anchor(top: editButton.bottomAnchor, left: scrollContainerView.leftAnchor, bottom: nil, right: scrollContainerView.rightAnchor, paddingTop: 8, paddingLeft: 8, paddingBottom: 0, paddingRight: 8, width: 0, height: 134)
        
        myTeamView.anchor(top: myGamesView.bottomAnchor, left: scrollContainerView.leftAnchor, bottom: nil, right: scrollContainerView.rightAnchor, paddingTop: 8, paddingLeft: 8, paddingBottom: 0, paddingRight: 8, width: 0, height: 169)
        
        suggestedClansView.anchor(top: myGamesView.bottomAnchor, left: scrollContainerView.leftAnchor, bottom: nil, right: scrollContainerView.rightAnchor, paddingTop: 8, paddingLeft: 8, paddingBottom: 0, paddingRight: 8, width: 0, height: 169)
        
        userAchievementsView.anchor(top: myTeamView.bottomAnchor, left: scrollContainerView.leftAnchor, bottom: nil, right: scrollContainerView.rightAnchor, paddingTop: 8, paddingLeft: 8, paddingBottom: 0, paddingRight: 8, width: 0, height: 194)
        
        ////752 px
        
    }
    
    fileprivate func setupSingleMenuView(font: UIFont, title: String, categoryName: String, tapGestureRecognizer: UITapGestureRecognizer?) -> UIView {
        
        let view = UIView()
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.white.cgColor
        view.backgroundColor = .clear
        
        
        if let gestureRecognizer = tapGestureRecognizer {
            view.isUserInteractionEnabled = true
            view.addGestureRecognizer(gestureRecognizer)
        }
        
        let titleLabel = UILabel()
        titleLabel.font = font
        titleLabel.text = title
        titleLabel.textAlignment = .center
        titleLabel.textColor = .white
        
        let descriptionLabel = UILabel()
        descriptionLabel.text = categoryName
        descriptionLabel.font = UIFont.systemFont(ofSize: 14)
        descriptionLabel.textAlignment = .center
        descriptionLabel.textColor = UIColor.white
        
        view.addSubview(titleLabel)
        
        titleLabel.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 30)
        
        view.addSubview(descriptionLabel)
        descriptionLabel.anchor(top: titleLabel.bottomAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        
        return view
        
    }
    
    func setupStackView(followers: Int, clanname: String, tournaments: Int) {
        
        let followersMenuView = setupSingleMenuView(font: UIFont.systemFont(ofSize: 24), title: "\(followers)", categoryName: "Followers", tapGestureRecognizer: nil)
        let teamMenuView = setupSingleMenuView(font: UIFont.boldSystemFont(ofSize: 14), title: clanname, categoryName: "Clan", tapGestureRecognizer: nil)
        let tournamentsMenuView = setupSingleMenuView(font: UIFont.systemFont(ofSize: 14), title: "coming soon", categoryName: "Tournaments", tapGestureRecognizer: nil)
        
        let dataStackView = UIStackView(arrangedSubviews: [followersMenuView, teamMenuView, tournamentsMenuView])
        
        dataStackView.distribution = .fillEqually
        dataStackView.layer.zPosition = 4
        
        scrollContainerView.addSubview(dataStackView)
        dataStackView.anchor(top: nil, left: scrollContainerView.leftAnchor, bottom: scrollContainerView.topAnchor, right: scrollContainerView.rightAnchor, paddingTop: 0, paddingLeft: -1, paddingBottom: -175, paddingRight: -1, width: 0, height: 50)
    }
    
    @objc func handleSettings() {
        
        let layout = UICollectionViewFlowLayout()
        let settingsController = SettingsController(collectionViewLayout: layout)
        show(settingsController, sender: self)
        
    }
    
    func setupFollowButton(_ uid: String) {
        if uid != Auth.auth().currentUser?.uid {
            if isJoiningRequest == true {
                self.acceptButton.isHidden = false
            } else {
                self.followButton.isHidden = false
            }
        }
    }
    
    func checkIfUserHasChoosenGames() {
        if user?.gameIds == nil {
            self.handleAddGames()
        }
    }
    
    @objc func handleAcceptToTeam() {
        if user?.team == nil {
            
            saveNewMemberToDB()
            
            guard let username = user?.username else { return }
            let alertController = UIAlertController(title: "New Team Member", message: "\(username) is now a member in your Team", preferredStyle: .alert)
            
            alertController.addAction(UIAlertAction(title: "Okay", style: .cancel, handler: { (_) in
                //completion here
                self.acceptButton.isHidden = true
                self.followButton.isHidden = false
            }))
            
            present(alertController, animated: true, completion: { 
                //completion here
            })
        } else {
            print("User is already in a Team")
            
            guard let username = user?.username else { return }
            let alertController = UIAlertController(title: "User can't join", message: "\(username) already is in a team", preferredStyle: .alert)
            
            alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            
            present(alertController, animated: true, completion: { 
                //completion here
            })
        }
    }
    
    func saveNewMemberToDB() {
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
        
        Database.fetchUserWithUID(uid: currentUserId) { (currentUser) in
            
            guard let teamId = currentUser.team else { return }
            let teamRef = Database.database().reference().child("teams").child(teamId).child("member")
            
            guard let newMemberId = self.user?.id else { return }
            let values = [newMemberId: 1]
            
            teamRef.updateChildValues(values, withCompletionBlock: { (err, _) in
                if let err = err {
                    print("failed to save new Member to db", err)
                }
            })
            
            let userValues: [String: Any] = ["team": teamId]
            let userRef = Database.database().reference().child("users").child(newMemberId)
            userRef.updateChildValues(userValues, withCompletionBlock: { (err, _) in
                if let err = err {
                    print("failed to save team to new member db", err)
                }
            })
            
            guard let userImageUrl = self.user?.profileImageUrl else { return }
            self.saveJoinedTeamUpdateToId(teamId: teamId, fromId: newMemberId, imageUrl: userImageUrl)
        }
        
    }
    
    func saveJoinedTeamUpdateToId(teamId: String, fromId: String, imageUrl: String) {
        let updateId = UUID().uuidString
        let timestamp = Date().timeIntervalSince1970
        
        Database.fetchTeamWithId(uid: teamId) { (team) in
            let teamname = team.teamname
            let values: [String: Any] = ["fromId": fromId, "hasSeen": false, "imageUrl": imageUrl, "teamId": teamId, "teamname": teamname, "timestamp": timestamp, "toId": teamId]
            
            let updateRef = Database.database().reference().child("updates").child(Update.databaseJoinedTeam).child(updateId)
            updateRef.updateChildValues(values, withCompletionBlock: { (err, _) in
                if let err = err {
                    print("failed to save update to db", err)
                }
            })
            
            guard let teamMemberIds = team.member else { return }
            
            let memberValues: [String: Any] = [updateId: 1]
            
            for memberId in teamMemberIds {
                let userRef = Database.database().reference().child("users").child(memberId).child("updates").child(Update.databaseJoinedTeam)
                userRef.updateChildValues(memberValues, withCompletionBlock: { (err, _) in
                    if let err = err {
                        print("failed to post update to user db", err)
                    }
                })
            }
            
            guard let groupIds = team.groupchats else { return }
            for groupId in groupIds {
                self.uploadUserGroupChats(currentUserId: fromId, groupId: groupId)
            }
        }
    }
    
    func uploadUserGroupChats(currentUserId: String, groupId: String) {
        
        let groupValues: [String: Any] = [currentUserId: 1]
        
        let groupRef = Database.database().reference().child("groupchats").child(groupId).child("users")
        groupRef.updateChildValues(groupValues) { (err, _) in
            if let err = err {
                print("failed to post user into group db:", err)
            }
        }
        
        let userValues: [String: Any] = [groupId: 1]
        let userGroupsRef = Database.database().reference().child("users").child(currentUserId).child("groupchats")
        userGroupsRef.updateChildValues(userValues) { (err, _) in
            if let err = err {
                print("failed to post group into user db:", err)
            }
        }
        
    }
    
    @objc func handleAddGames() {
        let layout = UICollectionViewFlowLayout()
        let chooseGamesController = ChooseGamesController(collectionViewLayout: layout)
        chooseGamesController.user = self.user
        if let gameIds = self.user?.gameIds {
            chooseGamesController.gameIds = gameIds
        }
        chooseGamesController.userProfileController = self
        let navController = UINavigationController(rootViewController: chooseGamesController)
        present(navController, animated: true) {
            //Completion here
        }
    }
    
    fileprivate func setupLogOutButton() {
        let gearButton = UIBarButtonItem(image: #imageLiteral(resourceName: "gear").withRenderingMode(.alwaysTemplate), style: .plain, target: self, action: #selector(handleLogout))
        gearButton.tintColor = UIColor.white
        navigationItem.rightBarButtonItem = gearButton
    }
    
    @objc func handleLogout() {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        alertController.addAction(UIAlertAction(title: "Log Out", style: .destructive, handler: { (_) in
            
            self.logoutAndRemoveToken()
            
        }))
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
    
    func logoutAndRemoveToken() {
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
        guard let token = Messaging.messaging().fcmToken else { return }
        
        let tokenRef = Database.database().reference().child("firebaseHelpers").child("fcmToken").child(currentUserId).child(token)
        tokenRef.removeValue { (err, _) in
            if let err = err {
                print("failed to remove token", err)
            }
        }
        do {
            try Auth.auth().signOut()
            
            let layout = UICollectionViewFlowLayout()
            let loginController = LoginController(collectionViewLayout: layout)
            self.present(loginController, animated: true, completion: nil)
            
        } catch let signOutErr {
            print("Failed to sign out:", signOutErr)
        }
    }
    
    func convertToGrayScale(image: UIImage) -> UIImage {
        let imageRect: CGRect = CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height)
        let colorSpace = CGColorSpaceCreateDeviceGray()
        let width = image.size.width
        let height = image.size.height
        
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.none.rawValue)
        let context = CGContext(data: nil, width: Int(width), height: Int(height), bitsPerComponent: 8, bytesPerRow: 0, space: colorSpace, bitmapInfo: bitmapInfo.rawValue)
        
        context?.draw(image.cgImage!, in: imageRect)
        let imageRef = context!.makeImage()
        let newImage = UIImage(cgImage: imageRef!)
        
        return newImage
    }
    
}
