//
//  AllGroupsForGameController.swift
//  Clansportler
//
//  Created by Luca Kiedrowski on 22.09.17.
//  Copyright © 2017 LucaKiedrowski. All rights reserved.
//

import UIKit
import Firebase

class AllGroupsForGameController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    let cellId = "cellId"
    
    var groups = [Group]() {
        didSet {
            collectionView?.reloadData()
        }
    }
    
    var game: Game? {
        didSet {
            guard let gameId = game?.id else { return }
            fetchGroupsForGame(gameId: gameId)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupWhiteTitle(title: "Open Groups")
        
        setupCollectionView()
        setupViews()
    }
    
    fileprivate func setupViews() {
        
    }
    
    fileprivate func setupCollectionView() {
        collectionView?.backgroundColor = ColorCodes.clansportlerBlue
        collectionView?.register(GroupHorizontalCell.self, forCellWithReuseIdentifier: cellId)
        collectionView?.alwaysBounceVertical = true
        collectionView?.contentInset = UIEdgeInsetsMake(8, 0, 8, 0)
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let group = groups[indexPath.item]
        showOpenGroupController(forGroup: group)
    }
    
    func showOpenGroupController(forGroup: Group) {
        let groupId = forGroup.id
        let openGroupController = OpenGroupController()
        Database.fetchAndObserveGroupWithId(id: groupId) { (fetchedGroup) in
            openGroupController.group = fetchedGroup
            openGroupController.gameId = forGroup.gameId
            
            let navController = UINavigationController(rootViewController: openGroupController)
            
            self.present(navController, animated: true, completion: {
                openGroupController.showJoiningAlertController()
            })
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return groups.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! GroupHorizontalCell
        
        cell.group = groups[indexPath.item]
        cell.game = self.game
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let height: CGFloat = 75
        let width: CGFloat = view.frame.width - 16
        
        return CGSize(width: width, height: height)
    }
    
    func fetchGroupsForGame(gameId: String) {
        let gameGroupsRef = Database.database().reference().child("groups").child(Group.gameGroupsDatabase).child(gameId)
        gameGroupsRef.observeSingleEvent(of: .value, with: { (snapshot) in
            
            guard let dictionary = snapshot.value as? [String: Any] else { return }
            
            dictionary.forEach({ (key, value) in
                
                Database.fetchAndObserveGroupWithId(id: key, completion: { (fetchedGroup) in
                    let isContained = self.groups.contains(where: { (containedGroup) -> Bool in
                        return containedGroup.id == fetchedGroup.id
                    })
                    if !isContained {
                        self.groups.append(fetchedGroup)
                        self.collectionView?.reloadData()
                    }
                })
            })
        }) { (err) in
            print("failed to fetch group", err)
        }
    }
}







