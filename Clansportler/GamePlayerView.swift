//
//  GamePlayerView.swift
//  Clansportler
//
//  Created by Luca Kiedrowski on 28.09.17.
//  Copyright © 2017 LucaKiedrowski. All rights reserved.
//

import UIKit
import Firebase

class GamePlayerView: CustomView, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    let cellId = "cellId"
    
    var game: Game? {
        didSet {
            if let gamePlayerCount = game?.playerCount {
                if gamePlayerCount < 10 {
                    for i in 0...(gamePlayerCount - 1) {
                        guard let playerId = game?.playerIds?[i] else { return }
                        Database.fetchUserWithUID(uid: playerId, completion: { (user) in
                            self.gamePlayer.append(user)
                            self.collectionView.reloadData()
                        })
                    }
                } else {
                    for i in 0...9 {
                        guard let playerId = game?.playerIds?[i] else { return }
                        Database.fetchUserWithUID(uid: playerId, completion: { (user) in
                            self.gamePlayer.append(user)
                            self.collectionView.reloadData()
                        })
                    }
                }
            }
        }
    }
    
    var gamePlayer = [User]()
    
    var gameController: GameController?
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Player"
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
        cv.backgroundColor = UIColor.white
        cv.showsHorizontalScrollIndicator = false
        cv.alwaysBounceHorizontal = true
        return cv
    }()
    
    lazy var seeAllButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("See All >>", for: .normal)
        button.setTitleColor(ColorCodes.clansportlerBlue, for: .normal)
        button.addTarget(self, action: #selector(handleShowAll), for: .touchUpInside)
        return button
    }()
        
    override func setupCustomView() {
        super.setupCustomView()
        
        self.backgroundColor = UIColor.white
        self.layer.cornerRadius = 5
        self.clipsToBounds = true
        
        collectionView.register(MemberCell.self, forCellWithReuseIdentifier: cellId)
        collectionView.contentInset = UIEdgeInsetsMake(0, 8, 0, 8)
        
        setupViews()
    }
    
    @objc func handleShowAll() {
        let layout = UICollectionViewFlowLayout()
        let memberController = MemberController(collectionViewLayout: layout)
        memberController.type = .game
        memberController.playerIds = game?.playerIds
        self.gameController?.show(memberController, sender: gameController)
    }
    
    func setupViews() {
        addSubview(titleLabel)
        addSubview(seeAllButton)
        addSubview(collectionView)
        
        titleLabel.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 8, paddingLeft: 8, paddingBottom: 0, paddingRight: 100, width: 0, height: 25)
        
        seeAllButton.anchor(top: topAnchor, left: titleLabel.rightAnchor, bottom: nil, right: rightAnchor, paddingTop: 4, paddingLeft: 8, paddingBottom: 0, paddingRight: 8, width: 0, height: 33)
        
        collectionView.anchor(top: titleLabel.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 8, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 125)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width: CGFloat = 100
        let height: CGFloat = 125
        
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return gamePlayer.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! MemberCell
        
        cell.user = gamePlayer[indexPath.item]
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let user = gamePlayer[indexPath.item]
        let userProfileController = UserProfileController()
        userProfileController.user = user
        self.gameController?.show(userProfileController, sender: gameController)
    }
    
}













