//
//  SuggestedClansView.swift
//  Clansportler
//
//  Created by Luca Kiedrowski on 13.09.17.
//  Copyright © 2017 LucaKiedrowski. All rights reserved.
//

import UIKit
import Firebase

class SuggestedClansView: CustomView, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    let cellId = "cellId"
    
    var userId: String? {
        didSet {
            if user == nil {
                guard let userId = userId else { return }
                Database.fetchUserWithUID(uid: userId, completion: { (fetchedUser) in
                    self.user = fetchedUser
                })
            }
        }
    }
    
    var user: User? {
        didSet {
            guard let currentUserId = Auth.auth().currentUser?.uid else { return }
            
            Database.fetchUserWithUID(uid: currentUserId) { (currentUser) in
                self.currentUser = currentUser
                if self.user?.id == currentUser.id {
                    self.fetchTeams()
                } else if currentUser.team == nil {
                    self.bothNoClanLabel.isHidden = false
                    self.createClanButton.isHidden = false
                } else {
                    guard let username = self.user?.username else { return }
                    self.bothNoClanLabel.text = "\(username) has no clan, do you want to invite her/him to your clan?"
                    
                    self.bothNoClanLabel.isHidden = false
                    self.inviteToCurrentUserClanButton.isHidden = false
                }
            }
        }
    }
    
    var clans = [SuggestedClan]() {
        didSet {
            self.collectionView.reloadData()
        }
    }
    
    var currentUser: User?
    
    var profileController: UserProfileController?
    
    let suggestedClansTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Suggested Clans"
        label.textColor = ColorCodes.clansportlerBlue
        label.font = UIFont.boldSystemFont(ofSize: 16)
        return label
    }()
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.dataSource = self
        cv.delegate = self
        cv.alwaysBounceHorizontal = true
        cv.showsHorizontalScrollIndicator = false
        return cv
    }()
    
    let bothNoClanLabel: UILabel = {
        let label = UILabel()
        label.text = "You have no clan, she/he has no clan, do you want to create one?"
        label.textColor = ColorCodes.clansportlerBlue
        label.isHidden = true
        label.numberOfLines = 0
        return label
    }()
    
    lazy var createClanButton: ClansportlerRedButton = {
        let button = ClansportlerRedButton(title: "Create a clan")
        button.isHidden = true
        button.addTarget(self, action: #selector(handleCreateClan), for: .touchUpInside)
        return button
    }()
    
    lazy var inviteToCurrentUserClanButton: ClansportlerRedButton = {
        let button = ClansportlerRedButton(title: "Invite to your clan")
        button.isHidden = true
        button.addTarget(self, action: #selector(handleInviteToClan), for: .touchUpInside)
        return button
    }()
    
    override func setupCustomView() {
        super.setupCustomView()
        
        setupCollectionView()
        
        setupViews()
        
        self.layer.cornerRadius = 5
        self.backgroundColor = UIColor.white
        self.clipsToBounds = true
    }
    
    func fetchTeams() {
        let clanMemberRef = Database.database().reference().child("teams")
        clanMemberRef.queryLimited(toFirst: 15).observeSingleEvent(of: .value, with: { (snapshot) in
            
            guard let dictionaries = snapshot.value as? [String: Any] else { return }
            self.clans.removeAll()
            dictionaries.forEach({ (key, value) in
                guard let dictionary = value as? [String: Any] else { return }
                
                let team = Team(uid: key, values: dictionary)
                
                guard let currentUser = self.user else { return }
                let suggestedClan = SuggestedClan(clan: team, currentUser: currentUser)
                
                self.clans.append(suggestedClan)
            })
        }) { (err) in
            print("failed to fetch 30 teams", err)
        }
    }
    
    fileprivate func setupCollectionView() {
        collectionView.register(SuggestedTeamCell.self, forCellWithReuseIdentifier: cellId)
        collectionView.backgroundColor = UIColor.white
        collectionView.contentInset = UIEdgeInsetsMake(0, 8, 0, 8)
    }
    
    fileprivate func setupViews() {
        
        addSubview(suggestedClansTitleLabel)
        addSubview(collectionView)
        
        addSubview(bothNoClanLabel)
        addSubview(createClanButton)
        addSubview(inviteToCurrentUserClanButton)
        
        suggestedClansTitleLabel.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 8, paddingLeft: 8, paddingBottom: 0, paddingRight: 8, width: 0, height: 25)
        collectionView.anchor(top: suggestedClansTitleLabel.bottomAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 8, paddingLeft: 0, paddingBottom: 8, paddingRight: 0, width: 0, height: 0)
        
        bothNoClanLabel.anchor(top: collectionView.topAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 8, width: 0, height: 45)
        
        createClanButton.anchor(top: nil, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 8, paddingBottom: 8, paddingRight: 8, width: 0, height: 50)
        inviteToCurrentUserClanButton.anchor(top: nil, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 8, paddingBottom: 8, paddingRight: 8, width: 0, height: 50)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if clans.count < 5 {
            return clans.count
        } else {
            return 5
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! SuggestedTeamCell
        
        let suggestedClan = clans[indexPath.item]
        cell.suggestedClan = suggestedClan
        
        cell.suggestedClansView = self
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width: CGFloat = 150
        let height: CGFloat = 120
        
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let suggestedClan = clans[indexPath.item]
        let clan = suggestedClan.clan
        
        let teamController = TeamController()
        teamController.team = clan
        
        profileController?.navigationController?.pushViewController(teamController, animated: true)
    }
    
    @objc func handleCreateClan() {
        
        guard let selectedUser = self.user else { return }
        let createTeamController = CreateTeamController()
        createTeamController.selectedMembers.append(selectedUser)
        
        let navController = UINavigationController(rootViewController: createTeamController)
        profileController?.present(navController, animated: true, completion: { 
            //completion here
        })
    }
    
    @objc func handleInviteToClan() {
        self.inviteToCurrentUserClanButton.isEnabled = false
        self.inviteToCurrentUserClanButton.setTitle("Invited", for: .normal)
        self.inviteToCurrentUserClanButton.backgroundColor = ColorCodes.disabledRed
        
        
        guard let userId = user?.id else { return }
        guard let clanId = currentUser?.team else { return }
        
        TeamInvitationUpdate.sendClanInvitationUpdate(toUserId: userId, clanId: clanId)
    }
    
}











