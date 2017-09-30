//
//  MemberCollectionView.swift
//  Clansportler
//
//  Created by Luca Kiedrowski on 18.08.17.
//  Copyright © 2017 LucaKiedrowski. All rights reserved.
//

import UIKit
import Firebase

enum MemberControllerType {
    case clan
    case game
}

class MemberController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    let cellId = "cellId"
    
    var type: MemberControllerType? {
        didSet {
            if type == .clan {
                setupWhiteTitle(title: "Player")
            } else if type == .game {
                setupWhiteTitle(title: "Member")
            }
        }
    }
    
    var playerIds: [String]? {
        didSet {
            fetchGamePlayer()
        }
    }
    
    var member = [User]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCollectionView()
//        fetchMember()
        
//        setupNavBarButtons()
//        navigationItem.title = "Member"
    }
    
    func fetchGamePlayer() {
        playerIds?.forEach({ (playerId) in
            Database.fetchUserWithUID(uid: playerId, completion: { (player) in
                self.member.append(player)
                self.collectionView?.reloadData()
            })
        })
    }
    
    func setupNavBarButtons() {
        let plusButton = UIBarButtonItem(image: #imageLiteral(resourceName: "plus_icon").withRenderingMode(.alwaysTemplate), landscapeImagePhone: nil, style: .plain, target: self, action: #selector(handleAddMembers))
        
        plusButton.tintColor = UIColor.white
        
        navigationItem.rightBarButtonItem = plusButton
    }
    
    @objc func handleAddMembers() {
        
        let selectUserController = SelectUserController()
        selectUserController.memberController = self
        
        
        let navController = UINavigationController(rootViewController: selectUserController)
        
        present(navController, animated: true, completion: nil)
        
    }
    
    func fetchMember() {
        //TODO: Fetch Member
    }
    
    func setupCollectionView() {
        collectionView?.backgroundColor = ColorCodes.clansportlerBlue
        
        collectionView?.register(MemberCell.self, forCellWithReuseIdentifier: cellId)
        
        collectionView?.contentInset = UIEdgeInsetsMake(5, 28, 0, 28)
        collectionView?.alwaysBounceVertical = true
        
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return member.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! MemberCell
        
        cell.user = member[indexPath.item]
        
        cell.usernameLabel.textColor = UIColor.white
        cell.profileImageView.layer.borderColor = UIColor.white.cgColor
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width: CGFloat = 100
        let height: CGFloat = 125
        
        return CGSize(width: width, height: height)
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let user = member[indexPath.item]
        let userProfileController = UserProfileController()
        userProfileController.user = user
        
        self.show(userProfileController, sender: self)
    }
    
}









