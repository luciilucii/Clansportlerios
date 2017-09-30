//
//  OnlineCell.swift
//  Clansportler
//
//  Created by Luca Kiedrowski on 11.08.17.
//  Copyright © 2017 LucaKiedrowski. All rights reserved.
//

import UIKit
import Firebase

protocol OnlineCellDelegate {
    func isOnline()
    func isOffline()
}

class OnlineCell: BaseCell, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    let cellId = "cellId"
    
    let isOnlineDatabaseName = "isOnline"
    let onlineStatusSinceDBName = "onlineStatusSinceTimestamp"
    
    //NOTE: Height is 110 + 143 = 253
    
    var delegate: OnlineCellDelegate?
    
    var homeController: HomeController?
    var currentUser: User? {
        didSet {
            guard let user = currentUser else { return }
            
            if let currentUserOnlineStatus = user.isOnline {
                if currentUserOnlineStatus {
                    onlineSwitch.isOn = true
                } else {
                    onlineSwitch.isOn = false
                }
            }
            
            if user.team != nil {
                self.onOffImageView.isHidden = false
                self.membersOnlineLabel.isHidden = false
                self.onlineCollectionView.isHidden = false
                
                self.createTeamButton.isHidden = true
                self.searchTeamButton.isHidden = true
                self.joinClanInfoLabel.isHidden = true
                
                if onlineUsers.count == 0 {
                    spiderImageView.isHidden = false
                } else {
                    spiderImageView.isHidden = true
                }
                
                fetchOnlineUser(user: user)
            } else {
                self.createTeamButton.isHidden = false
                self.searchTeamButton.isHidden = false
                self.joinClanInfoLabel.isHidden = false
                
                spiderImageView.isHidden = true
                
                self.onOffImageView.isHidden = true
                self.membersOnlineLabel.isHidden = true
                self.onlineCollectionView.isHidden = true
            }
        }
    }
    
    var onlineUsers = [User]() {
        didSet {
            self.membersOnlineLabel.text = "\(onlineUsers.count) clan members are currently playing"
            
            if onlineUsers.count == 0 {
                spiderImageView.isHidden = false
            } else {
                spiderImageView.isHidden = true
            }
        }
    }
    
    let currentUserOnlineLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.textAlignment = .center
        label.text = "Are you playing right now?"
        return label
    }()
    
    lazy var onlineSwitch: UISwitch = {
        let switchView = UISwitch()
        switchView.isOn = false
        switchView.translatesAutoresizingMaskIntoConstraints = false
        switchView.onTintColor = ColorCodes.clansportlerPurple
        switchView.addTarget(self, action: #selector(onlineSwitchValueChanged), for: .valueChanged)
        return switchView
    }()
    
    let onOffImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.clipsToBounds = true
        iv.image = #imageLiteral(resourceName: "OnOffIcon").withRenderingMode(.alwaysTemplate)
        iv.tintColor = UIColor.white
        iv.isHidden = true
        return iv
    }()
    
    let membersOnlineLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 17)
        label.numberOfLines = 2
        label.isHidden = true
        label.text = "Nobody of your clan is playing right now"
        return label
    }()
    
    lazy var onlineCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.delegate = self
        cv.dataSource = self
        cv.backgroundColor = ColorCodes.clansportlerBlue
        cv.isHidden = true
        return cv
    }()
    
    let spiderImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.image = #imageLiteral(resourceName: "windy")
        return iv
    }()
    
    let joinClanInfoLabel: UILabel = {
        let label = UILabel()
        label.text = "If you are in a clan, you can see here, if one of your friends is currently playing. You can join a Clan or you can create your own ;) "
        label.numberOfLines = 3
        label.textColor = UIColor.white
        label.textAlignment = .center
        label.isHidden = true
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()
    
    lazy var createTeamButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = ColorCodes.clansportlerRed
        button.setTitle("Create a Clan", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.addTarget(self, action: #selector(handleCreateTeam), for: .touchUpInside)
        button.tintColor = UIColor.white
        button.isHidden = true
        button.layer.cornerRadius = 5
        return button
    }()
    
    lazy var searchTeamButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = ColorCodes.clansportlerBlue
        button.setTitle("Search a Clan", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.tintColor = UIColor.white
        button.layer.borderWidth = 2
        button.layer.borderColor = UIColor.white.cgColor
        button.addTarget(self, action: #selector(handleSearchTeam), for: .touchUpInside)
        button.isHidden = true
        button.layer.cornerRadius = 5
        return button
    }()
    
    override func setupCell() {
        super.setupCell()
        
        layer.cornerRadius = 5
        backgroundColor = ColorCodes.clansportlerBlue
        
        setupViews()
        
        onlineCollectionView.contentInset = UIEdgeInsetsMake(0, 8, 0, 8)
        onlineCollectionView.alwaysBounceHorizontal = true
        onlineCollectionView.register(MemberCell.self, forCellWithReuseIdentifier: cellId)
    }
    
    func setupViews() {
        addSubview(onlineSwitch)
        addSubview(currentUserOnlineLabel)
        addSubview(onOffImageView)
        addSubview(membersOnlineLabel)
        addSubview(onlineCollectionView)
        addSubview(spiderImageView)
        
        onlineSwitch.anchor(top: currentUserOnlineLabel.topAnchor, left: nil, bottom: currentUserOnlineLabel.bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 8, width: 50, height: 0)
        currentUserOnlineLabel.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: onlineSwitch.leftAnchor, paddingTop: 4, paddingLeft: 8, paddingBottom: 0, paddingRight: 4, width: 0, height: 32)
        
        onOffImageView.anchor(top: currentUserOnlineLabel.bottomAnchor, left: leftAnchor, bottom: nil, right: nil, paddingTop: 8, paddingLeft: 16, paddingBottom: 0, paddingRight: 0, width: 45, height: 58)
        
        membersOnlineLabel.anchor(top: nil, left: onOffImageView.rightAnchor, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 16, paddingBottom: 0, paddingRight: 16, width: 0, height: 42)
        membersOnlineLabel.centerYAnchor.constraint(equalTo: onOffImageView.centerYAnchor).isActive = true
        
        onlineCollectionView.anchor(top: onOffImageView.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 4, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 130)
        
        spiderImageView.anchor(top: onOffImageView.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 4, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 130)
        
        setupNoClanViews()
    }
    
    func setupNoClanViews() {
        addSubview(createTeamButton)
        addSubview(searchTeamButton)
        addSubview(joinClanInfoLabel)
        
        
        createTeamButton.anchor(top: nil, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 8, paddingBottom: 8, paddingRight: 8, width: 0, height: 50)
        
        searchTeamButton.anchor(top: nil, left: leftAnchor, bottom: createTeamButton.topAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 8, paddingBottom: 8, paddingRight: 8, width: 0, height: 50)
        
        joinClanInfoLabel.anchor(top: currentUserOnlineLabel.bottomAnchor, left: leftAnchor, bottom: searchTeamButton.topAnchor, right: rightAnchor, paddingTop: 8, paddingLeft: 8, paddingBottom: 8, paddingRight: 8, width: 0, height: 0)
        
    }
    
    
    @objc func handleCreateTeam() {
        let createTeamController = CreateTeamController()
        createTeamController.homeController = homeController
        let navigationController = UINavigationController(rootViewController: createTeamController)
        homeController?.present(navigationController, animated: true, completion: nil)
    }
    
    @objc func handleSearchTeam() {
        let layout = UICollectionViewFlowLayout()
        let searchTeamController = SearchTeamController(collectionViewLayout: layout)
        let navController = UINavigationController(rootViewController: searchTeamController)
        homeController?.present(navController, animated: true) {
            //completion here
        }
    }
    
    func fetchOnlineUser(user: User) {
        guard let teamId = user.team else { return }
        
        Database.fetchTeamWithId(uid: teamId) { (team) in
            guard let teamMember = team.member else { return }
            for memberId in teamMember {
                Database.fetchUserWithUID(uid: memberId, completion: { (user) in
                    
                    if user.id != self.currentUser?.id {
                        guard let isUserOnline = user.isOnline else { return }
                        if isUserOnline {
                            self.onlineUsers.append(user)
                            self.onlineCollectionView.reloadData()
                        }
                    }
                })
            }
        }
    }
    
    func checkIfUserIsOnline() {
        guard let currentUserId = currentUser?.id else { return }
        
        let userRef = Database.database().reference().child("users").child(currentUserId)
        userRef.observe(.childChanged, with: { (snapshot) in
            
            guard let dictionary = snapshot.value as? [String: Any] else { return }
            guard let userIsOnline = dictionary[self.isOnlineDatabaseName] as? Bool else { return }
            if userIsOnline == true {
                self.onlineSwitch.isOn = true
            } else {
                self.onlineSwitch.isOn = false
            }
            
            
        }) { (err) in
            print("failed to observe user", err)
        }
        
    }
    
    @objc func onlineSwitchValueChanged() {
        let timestamp = Date().timeIntervalSince1970
        
        if onlineSwitch.isOn {
            delegate?.isOnline()
            
            let values: [String: Any] = [self.isOnlineDatabaseName: true, self.onlineStatusSinceDBName: timestamp]
            homeController?.uploadOnlineStatusToDatabase(values: values)
            
        } else {
            delegate?.isOffline()
            
            let values: [String: Any] = [self.isOnlineDatabaseName: false, self.onlineStatusSinceDBName: timestamp]
            homeController?.uploadOnlineStatusToDatabase(values: values)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! MemberCell
        
        cell.user = onlineUsers[indexPath.item]
        
        cell.profileImageView.layer.borderColor = ColorCodes.clansportlerPurple.cgColor
        cell.usernameLabel.textColor = UIColor.white
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return onlineUsers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width: CGFloat = 100
        let height: CGFloat = 125
        
        return CGSize(width: width, height: height)
    }
    
}













