//
//  SuggestedGroupsCell.swift
//  Clansportler
//
//  Created by Luca Kiedrowski on 03.09.17.
//  Copyright © 2017 LucaKiedrowski. All rights reserved.
//

import UIKit
import Firebase

class SuggestedGroupsCell: BaseCell, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    let cellId = "cellId"
    
    var currentUser: User? {
        didSet {
            if let gameIds = currentUser?.gameIds {
                
                self.fetchGameWithMostGroups(gameIds: gameIds)
            }
        }
    }
    
    var gameId: String?
    
    var fetchedGroups = [Group]() {
        didSet {
            if fetchedGroups.count > 0 {
                noGroupsLabel.isHidden = true
                groupsImageView.isHidden = true
                openGroupButton.isHidden = true
            } else {
                noGroupsLabel.isHidden = false
                groupsImageView.isHidden = false
                openGroupButton.isHidden = false
            }
            collectionView.reloadData()
        }
    }
    
    var homeController: HomeController?
    
    let headlineLabel: UILabel = {
        let label = UILabel()
        label.text = "Open Groups"
        label.textColor = UIColor.white
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.textAlignment = .center
        return label
    }()
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.dataSource = self
        cv.delegate = self
        return cv
    }()
    
    let noGroupsLabel: UILabel = {
        let label = UILabel()
        label.text = "There are no groups available for your games, sorry amigo :("
        label.numberOfLines = 0
        label.textColor = UIColor.white
        label.textAlignment = .center
        return label
    }()
    
    let groupsImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.image = #imageLiteral(resourceName: "onboarding_groups")
        return iv
    }()
    
    lazy var openGroupButton: ClansportlerRedButton = {
        let button = ClansportlerRedButton(title: "Open a Group")
        button.addTarget(self, action: #selector(handleOpenGroup), for: .touchUpInside)
        return button
    }()
    
    override func setupCell() {
        super.setupCell()
        
        backgroundColor = ColorCodes.clansportlerPurple
        layer.cornerRadius = 5
        
        setupViews()
        
        collectionView.register(GameGroupsCell.self, forCellWithReuseIdentifier: cellId)
        collectionView.backgroundColor = ColorCodes.clansportlerPurple
    }
    
    func setupViews() {
        addSubview(headlineLabel)
        addSubview(collectionView)
        addSubview(noGroupsLabel)
        addSubview(openGroupButton)
        addSubview(groupsImageView)
        
        
        headlineLabel.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 4, paddingLeft: 8, paddingBottom: 0, paddingRight: 8, width: 0, height: 30)
        collectionView.anchor(top: headlineLabel.bottomAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 8, paddingLeft: 0, paddingBottom: 8, paddingRight: 0, width: 0, height: 0)
        noGroupsLabel.anchor(top: collectionView.topAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 8, width: 0, height: 45)
        groupsImageView.anchor(top: noGroupsLabel.bottomAnchor, left: leftAnchor, bottom: openGroupButton.topAnchor, right: rightAnchor, paddingTop: 8, paddingLeft: 8, paddingBottom: 8, paddingRight: 8, width: 0, height: 0)
        openGroupButton.anchor(top: nil, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 8, paddingLeft: 8, paddingBottom: 8, paddingRight: 8, width: 0, height: 50)
        
    }
    
    var sortingTimer: Timer?
    
    var groupForGameCount = [String: Int]() {
        didSet {
            sortingTimer?.invalidate()
            sortingTimer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(self.sortGroupGameCount), userInfo: nil, repeats: false)
        }
    }
    
    func fetchGameWithMostGroups(gameIds: [String]) {
        gameIds.forEach { (gameId) in
            
            let gameGroupRef = Database.database().reference().child("groups").child(Group.gameGroupsDatabase).child(gameId)
            gameGroupRef.observeSingleEvent(of: .value, with: { (snapshot) in
                
                guard let dictionary = snapshot.value as? [String: Any] else { return }
                
                let gameGroupCount = dictionary.keys.count
                self.groupForGameCount[gameId] = gameGroupCount
                
                
            }, withCancel: { (err) in
                print("failed to fetch game groups")
            })
        }
    }
    
    @objc func sortGroupGameCount() {
        var biggestGameId = ""
        var biggestValue = 0
        self.groupForGameCount.forEach({ (key, value) in
            if value > biggestValue {
                biggestValue = value
                biggestGameId = key
            }
        })
        if biggestGameId != "" {
            self.fetchGameGroups(gameId: biggestGameId)
        }
    }
    
    func fetchGameGroups(gameId: String) {
        self.gameId = gameId
        let gameGroupRef = Database.database().reference().child("groups").child(Group.gameGroupsDatabase).child(gameId)
        gameGroupRef.observeSingleEvent(of: .value, with: { (snapshot) in
            
            guard let dictionary = snapshot.value as? [String: Any] else { return }
            dictionary.forEach({ (key, value) in
                Database.fetchAndObserveGroupWithId(id: key, completion: { (group) in
                    guard let currentMemberCount = group.currentGroupMemberCount else { return }
                    if currentMemberCount < group.maxGroupMember {
                        let alreadyInDic =  self.fetchedGroups.contains(where: { (containedGroup) -> Bool in
                            return containedGroup.id == group.id
                        })
                        if !alreadyInDic {
                            self.fetchedGroups.append(group)
                        }
                    }
                })
            })
        }, withCancel: { (err) in
            print("failed to fetch group games", err)
        })
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width: CGFloat = collectionView.frame.width
        let height: CGFloat = 225
        
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! GameGroupsCell
        
        cell.homeController = self.homeController
        cell.cellBackgroundColor = ColorCodes.clansportlerPurple
        cell.backgroundColor = ColorCodes.clansportlerPurple
        cell.collectionView.backgroundColor = ColorCodes.clansportlerPurple
        
        
        cell.gameId = self.gameId
        cell.groups = self.fetchedGroups
        
        return cell
    }
    
    @objc func handleOpenGroup() {
        let createGroupController = CreateGroupController()
        createGroupController.homeController = self.homeController
        let navController = UINavigationController(rootViewController: createGroupController)
        
        homeController?.present(navController, animated: true, completion: { 
            //completion here
        })
    }
    
}















