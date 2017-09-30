//
//  GroupsController.swift
//  Clansportler
//
//  Created by Luca Kiedrowski on 30.08.17.
//  Copyright © 2017 LucaKiedrowski. All rights reserved.
//

import UIKit
import Firebase

class GroupsController: UICollectionViewController, UICollectionViewDelegateFlowLayout, GameGroupsCellDelegate {
    
    var gameIds = [String]()
    var groups = [Group]()
    
    var gameGroupDictionary = [String: [Group]]() {
        didSet {
            collectionView?.reloadData()
        }
    }
    
    var currentUser: User? {
        didSet {
            fetchGameGroupDictionary()
        }
    }
    
    let headerId = "headerId"
    let cellId = "cellId"
    
    lazy var createGroupButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Open", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.backgroundColor = ColorCodes.clansportlerRed
        button.setTitleColor(UIColor.white, for: .normal)
        button.layer.cornerRadius = 5
        button.addTarget(self, action: #selector(handleCreateGroup), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupWhiteTitle(title: "Groups")
        navigationController?.navigationBar.tintColor = UIColor.white
        
        setupCollectionView()
        setupViews()
        
        observeForChildUpdate()
        navigationController?.navigationBar.isTranslucent = false
        
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
        Database.fetchUserWithUID(uid: currentUserId) { (fetchedUser) in
            self.currentUser = fetchedUser
        }
    }
    
    func observeForChildUpdate() {
        
        let gameGroupRef = Database.database().reference().child("groups").child(Group.gameGroupsDatabase).queryLimited(toFirst: 7)
        gameGroupRef.observe(.childChanged, with: { (snapshot) in
            
            self.fetchGameGroupDictionary()
            
        }) { (err) in
            print("failed to update data")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        fetchGameGroupDictionary()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
    }
    
    func setupCollectionView() {
        collectionView?.register(GroupHeader.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: headerId)
        collectionView?.register(GameGroupsCell.self, forCellWithReuseIdentifier: cellId)
        collectionView?.backgroundColor = ColorCodes.clansportlerBlue
        collectionView?.alwaysBounceVertical = true
        collectionView?.contentInset = UIEdgeInsetsMake(8, 0, 58, 0)
    }
    
    func fetchGameGroupDictionary() {
        let gameIds = currentUser?.gameIds
        
        let groupGamesRef = Database.database().reference().child("groups").child(Group.gameGroupsDatabase)
        groupGamesRef.observeSingleEvent(of: .value, with: { (snapshot) in
            
            guard let dictionary = snapshot.value as? [String: Any] else { return }
            dictionary.forEach({ (key, value) in
                
                let isContained = gameIds?.contains(where: { (gameId) -> Bool in
                    return key == gameId
                })
                if isContained == true {
                    self.appendToGameDictionary(key: key, value: value)
                }
            })
        }) { (err) in
            print("Failed to fetch game groups", err)
        }
    }
    
    func appendToGameDictionary(key: String, value: Any) {
        self.gameGroupDictionary[key] = [Group]()
        
        guard let gameDictionary = value as? [String: Any] else { return }
        gameDictionary.forEach({ (groupKey, groupValue) in
            Database.fetchAndObserveGroupWithId(id: groupKey, completion: { (group) in
                guard let currentMemberCount = group.currentGroupMemberCount else { return }
                
                if currentMemberCount < group.maxGroupMember {
                    guard let gameGroupDicArray = self.gameGroupDictionary[key] else { return }
                    
                    let alreadyInDic =  gameGroupDicArray.contains(where: { (containedGroup) -> Bool in
                        return containedGroup.id == group.id
                    })
                    if !alreadyInDic {
                        self.gameGroupDictionary[key]?.append(group)
                    }
                }
            })
        })
        self.collectionView?.reloadData()
    }
    
    func setupViews() {
        
        view.addSubview(createGroupButton)
        
        createGroupButton.anchor(top: nil, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 8, paddingBottom: 8, paddingRight: 8, width: 0, height: 50)
        
    }
    
    @objc func handleCreateGroup() {
        
        let createGroupController = CreateGroupController()
        createGroupController.groupsController = self
        let navController = UINavigationController(rootViewController: createGroupController)
        present(navController, animated: true) { 
            //completion here
        }
        
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return gameGroupDictionary.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! GameGroupsCell
        
        cell.groupsController = self
        cell.delegate = self

        cell.gameId = Array(gameGroupDictionary)[indexPath.item].key
        
        let groups = Array(gameGroupDictionary)[indexPath.item].value
        
        cell.groups = groups.sorted { (g1, g2) -> Bool in
            return g1.lastUpdate.compare(g2.lastUpdate) == .orderedAscending
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width: CGFloat = view.frame.width
        let height: CGFloat = 225
        
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let width: CGFloat = view.frame.width - 16
        let height: CGFloat = 150
        
        return CGSize(width: width, height: height)
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerId, for: indexPath) as! GroupHeader
        
        return header
    }
    
    func didTapSeeAll(game: Game) {
        let layout = UICollectionViewFlowLayout()
        let allGroupsForGameController = AllGroupsForGameController(collectionViewLayout: layout)
        
        guard let groups = gameGroupDictionary[game.id] else { return }
        allGroupsForGameController.game = game
        
        navigationController?.pushViewController(allGroupsForGameController, animated: true)
    }
    
}















