//
//  TeamController.swift
//  Clansportler
//
//  Created by Luca Kiedrowski on 09.08.17.
//  Copyright © 2017 LucaKiedrowski. All rights reserved.
//

import UIKit
import Firebase

enum TopButtonType {
    case askToJoin
    case invitation
    case alreadyInTeam
}

class TeamController: ScrollController {
    
    var teamInvitation: Bool? {
        didSet {
            if teamInvitation == true {
                topButtonType = .invitation
            }
        }
    }
    
    var team: Team? {
        didSet {
            checkIfUserIsInTeam {
                _ = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(self.handleSetupAskToJoin), userInfo: nil, repeats: false)
            }
            
            setupMemberView()
            
            guard let teamname = team?.teamname else { return }
            navigationItem.title = teamname
            teamnameLabel.text = teamname
            
            guard let imageUrl = team?.profileImageUrl else { return }
            teamImageView.loadImage(urlString: imageUrl)
        }
    }
    
    @objc func handleSetupAskToJoin() {
        if self.topButtonType == nil {
            self.topButtonType = .askToJoin
        }
    }
    
    var currentUserId: String?
    
    var currentUser: User? {
        didSet {
            
        }
    }
    
    var topButtonType: TopButtonType? {
        didSet {
            guard let type = topButtonType else { return }
            switch type {
            case .alreadyInTeam:
                self.setupAlreadyInTeamButton()
            case .invitation:
                self.setupInvitationButton()
            case .askToJoin:
                self.setupAskToJoinButton()
            }
        }
    }
    
    var isUserInTeam = false {
        didSet {
            if isUserInTeam == true {
                topButtonType = .alreadyInTeam
            }
        }
    }
    
    private func checkIfUserIsInTeam(completion: @escaping() -> ()) {
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
        
        self.currentUserId = currentUserId
        
        Database.fetchUserWithUID(uid: currentUserId) { (user) in
            self.currentUser = user
            if user.team != nil {
                self.isUserInTeam = true
            }
        }
        
        completion()
    }
    
    
    func setupAlreadyInTeamButton() {
        joinButton.layer.borderColor = UIColor.white.cgColor
        joinButton.layer.borderWidth = 1
        joinButton.backgroundColor = .clear
        
        joinButton.setTitle("Already in a Clan", for: .normal)
        joinButton.isEnabled = false
        
        joinButton.isHidden = false
    }
    
    func setupAlreadyAskedToJoinButton() {
        joinButton.layer.borderColor = UIColor.white.cgColor
        joinButton.layer.borderWidth = 1
        joinButton.backgroundColor = .clear
        
        joinButton.setTitle("Already asked to join", for: .normal)
        joinButton.isEnabled = false
        
        joinButton.isHidden = false
    }
    
    func setupAskToJoinButton() {
        
        joinButton.setTitle("Ask to join", for: .normal)
        joinButton.addTarget(self, action: #selector(handleAskToJoin), for: .touchUpInside)
        joinButton.isEnabled = true
        joinButton.isHidden = false
        joinButton.backgroundColor = ColorCodes.clansportlerRed
        joinButton.tintColor = UIColor.white
        
    }
    
    func setupInvitationButton() {
        joinButton.backgroundColor = ColorCodes.clansportlerRed
        joinButton.setTitle("Join Clan", for: .normal)
        joinButton.tintColor = UIColor.white
        joinButton.addTarget(self, action: #selector(handleJoinTeam), for: .touchUpInside)
        joinButton.isHidden = false
    }
    
        
    let teamImageView: CustomImageView = {
        let iv = CustomImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        return iv
    }()
    
    let joinButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = ColorCodes.clansportlerRed
        button.layer.cornerRadius = 5
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.tintColor = UIColor.white
        button.isHidden = true
        return button
    }()
    
    let labelBlueView: UIView = {
        let view = UIView()
        view.backgroundColor = ColorCodes.clansportlerBlue
        view.layer.cornerRadius = 5
        return view
    }()
    
    let teamnameLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.white
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 20)
        return label
    }()
    
    lazy var gamesView: GamesView = {
        let gamesView = GamesView()
        gamesView.teamController = self
        return gamesView
    }()
    
    lazy var memberView: TeamMemberView = {
        let mV = TeamMemberView()
        mV.teamController = self
        return mV
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        super.setupScrollView(height: 742)
        
        super.setupController()
        
        setupBarButtonItems()
        
        navigationController?.navigationBar.tintColor = UIColor.white
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        navigationItem.title = " "
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard let teamname = team?.teamname else { return }
        navigationItem.title = teamname
    }
    
    func setupBarButtonItems() {
        
        let moreButton = UIBarButtonItem(image: #imageLiteral(resourceName: "nav_more_icon").withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(handleMore))
        
        navigationItem.rightBarButtonItem = moreButton
        
    }
    
    override func setupViews() {
        super.setupViews()
        
        scrollContainerView.addSubview(teamImageView)
        scrollContainerView.addSubview(joinButton)
        
        scrollContainerView.addSubview(labelBlueView)
        labelBlueView.addSubview(teamnameLabel)
        
        scrollContainerView.addSubview(gamesView)
        scrollContainerView.addSubview(memberView)
        
        teamImageView.anchor(top: view.topAnchor, left: scrollContainerView.leftAnchor, bottom: scrollContainerView.topAnchor, right: scrollContainerView.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: -175, paddingRight: 0, width: 0, height: 0)
        
        labelBlueView.anchor(top: scrollContainerView.topAnchor, left: scrollContainerView.leftAnchor, bottom: nil, right: scrollContainerView.rightAnchor, paddingTop: 110, paddingLeft: 32, paddingBottom: 0, paddingRight: -5, width: 0, height: 45)
        
        teamnameLabel.anchor(top: labelBlueView.topAnchor, left: labelBlueView.leftAnchor, bottom: labelBlueView.bottomAnchor, right: labelBlueView.rightAnchor, paddingTop: 0, paddingLeft: 4, paddingBottom: 0, paddingRight: 4, width: 0, height: 0)
        
        joinButton.anchor(top: scrollContainerView.topAnchor, left: scrollContainerView.leftAnchor, bottom: nil, right: scrollContainerView.rightAnchor, paddingTop: 8 + 175, paddingLeft: 8, paddingBottom: 0, paddingRight: 8, width: 0, height: 44)
        
        gamesView.anchor(top: joinButton.bottomAnchor, left: scrollContainerView.leftAnchor, bottom: nil, right: scrollContainerView.rightAnchor, paddingTop: 8, paddingLeft: 8, paddingBottom: 0, paddingRight: 8, width: 0, height: 186)
        
        memberView.anchor(top: gamesView.bottomAnchor, left: scrollContainerView.leftAnchor, bottom: nil, right: scrollContainerView.rightAnchor, paddingTop: 8, paddingLeft: 8, paddingBottom: 0, paddingRight: 8, width: 0, height: 0)
    }
    
    @objc func handleJoinTeam() {
        
        guard let teamId = team?.id else { return }
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
        let teamMemberRef = Database.database().reference().child("teams").child(teamId).child("member")
        teamMemberRef.updateChildValues([currentUserId: 1]) { (err, _) in
            if let err = err {
                print("failed to post user to team db: ", err)
            }
        }
        
        let userRef = Database.database().reference().child("users").child(currentUserId)
        userRef.updateChildValues(["team": teamId]) { (err, _) in
            if let err = err {
                print("failed to post team to user db:", err)
            }
        }
        
        guard let team = self.team else { return }
        guard let teamGroups = team.groupchats else { return }
        
        teamGroups.forEach { (groupchatIds) in
            Database.uploadUserGroupChats(currentUserId: currentUserId, groupchatId: groupchatIds)
        }
        
        guard let username = self.currentUser?.username else { return }
        guard let currentUserImageUrl = self.currentUser?.profileImageUrl else { return }
        
        self.saveJoinedTeamUpdateToId(teamId: teamId, fromId: currentUserId, fromname: username, imageUrl: currentUserImageUrl)
        self.setupAlreadyInTeamButton()
    }
    
    func saveJoinedTeamUpdateToId(teamId: String, fromId: String, fromname: String, imageUrl: String) {
        
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
        }
    }
    
    @objc func handleAskToJoin() {
        
        guard let currentUserId = self.currentUserId else { return }
        guard let teamname = self.team?.teamname else { return }
        guard let teamId = self.team?.id else { return }
        guard let adminId = self.team?.adminId else { return }
        
        guard let imageUrl = self.currentUser?.profileImageUrl else { return }
        
        let timestamp = Date().timeIntervalSince1970
        
        let updateId = UUID().uuidString
        
        let values: [String: Any] = ["fromId": currentUserId, "teamname": teamname, "timestamp": timestamp, "toId": adminId, "teamId": teamId, "hasSeen": false, "imageUrl": imageUrl]
        
        let updateRef = Database.database().reference().child("updates").child(Update.databaseTeamRequests).child(updateId)
        updateRef.updateChildValues(values) { (err, _) in
            
            if let err = err {
                print("failed to upload request into firebase", err)
            }
        }
        let userValues: [String: Any] = [updateId: 1]
        
        let userRef = Database.database().reference().child("users").child(currentUserId).child("updates").child(Update.databaseTeamRequests)
        userRef.updateChildValues(userValues) { (err, _) in
            if let err = err {
                print("failed to post Request into User db", err)
            }
        }
        
        let adminRef = Database.database().reference().child("users").child(adminId).child("updates").child(Update.databaseTeamRequests)
        adminRef.updateChildValues(userValues) { (err, _) in
            if let err = err {
                print("failed to post request into admin db", err)
            }
        }
        self.setupAlreadyAskedToJoinButton()
    }
    
    func setupMemberView() {
        
        memberView.heightAnchor.constraint(equalToConstant: 190).isActive = true
    }
    
    @objc func handleMore() {
        let alertController = UIAlertController(title: nil, message: "In this section you can add members or leave the clan. If you're currently not in the clan, you can ask to join the clan.", preferredStyle: .actionSheet)
        
        if topButtonType == .alreadyInTeam {
            
            alertController.addAction(UIAlertAction(title: "Add Member", style: .default, handler: { (_) in
                
                let selectUserController = SelectUserController()
                selectUserController.teamController = self
                let navController = UINavigationController(rootViewController: selectUserController)
                self.present(navController, animated: true, completion: {
                    //completion here
                })
                
            }))
            
            alertController.addAction(UIAlertAction(title: "Leave Clan", style: .destructive, handler: { (_) in
                
                self.handleLeaveTeam()
                
            }))
            
        } else {
            
        }
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(alertController, animated: true, completion: nil)
        
    }
    
    
    //MARK: Leave Team + Groupchats
    
    func handleLeaveTeam() {
        
        let alertController = UIAlertController(title: "Leave Clan", message: "Do you really want to leave the clan?", preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { (action) in
            
            alertController.dismiss(animated: true, completion: nil)
            
        }))
        
        alertController.addAction(UIAlertAction(title: "Leave", style: .destructive, handler: { (action) in
            
            self.handleLeaveTeamFromDatabase()
            
        }))
        
        self.present(alertController, animated: true, completion: nil)
        
    }
    
    func handleLeaveTeamFromDatabase() {
        
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
        guard let currentTeamId = team?.id else { return }
        checkIfUserIsAdmin(currentUserId: currentUserId, teamId: currentTeamId)
        
        let userRef = Database.database().reference().child("users").child(currentUserId).child("team")
        userRef.removeValue()
        
        let teamMemberRef = Database.database().reference().child("teams").child(currentTeamId).child("member").child(currentUserId)
        teamMemberRef.removeValue()
        
        NotificationCenter.default.post(name: MainTabBarController.updateControllerNotification, object: nil)
        
        handleRemoveGroupchats(teamId: currentTeamId, currentUserId: currentUserId)
        
    }
    
    func checkIfUserIsAdmin(currentUserId: String, teamId: String) {
        let clanRef = Database.database().reference().child("teams").child(teamId)
        if team?.adminId == currentUserId {
            if let newAdminId = team?.member?.first, let otherAdminId = team?.member?.last {
                if newAdminId != currentUserId {
                    let newAdminValues: [String: Any] = ["adminId": newAdminId]
                    clanRef.updateChildValues(newAdminValues, withCompletionBlock: { (err, _) in
                        if let err = err {
                            print("failed to update admin in clan", err)
                        }
                    })
                } else if otherAdminId != currentUserId {
                    let newAdminValues: [String: Any] = ["adminId": otherAdminId]
                    
                    clanRef.updateChildValues(newAdminValues, withCompletionBlock: { (err, _) in
                        if let err = err {
                            print("failed to update admin in clan", err)
                        }
                    })
                } else {
                    clanRef.removeValue(completionBlock: { (err, _) in
                        if let err = err {
                            print("failed to close clan", err)
                        }
                    })
                }
            }
        }
    }
    
    func handleRemoveGroupchats(teamId: String, currentUserId: String) {
        
        let teamRef = Database.database().reference().child("teams").child(teamId).child("groupchats")
        
        teamRef.observeSingleEvent(of: .value, with: { (snapshot) in
            
            guard let dictionary = snapshot.value as? [String: Any] else { return }
            dictionary.forEach({ (key, value) in
                
                let groupchatId = key
                
                self.deleteGroupchatsWith(groupchatId: groupchatId, currentUserId: currentUserId)
                
            })
            
        }) { (err) in
            print("failed to fetch groupchat Id", err)
        }
    }
    
    func deleteGroupchatsWith(groupchatId: String, currentUserId: String) {
        
        let groupchatRef = Database.database().reference().child("groupchats").child(groupchatId).child("users").child(currentUserId)
        
        groupchatRef.removeValue()
        
        
        let userRef = Database.database().reference().child("users").child(currentUserId).child("groupchats").child(groupchatId)
        
        userRef.removeValue()
        
        
        
    }
    
}














