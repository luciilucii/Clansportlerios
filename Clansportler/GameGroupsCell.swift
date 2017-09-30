//
//  GameGroupsCell.swift
//  Clansportler
//
//  Created by Luca Kiedrowski on 02.09.17.
//  Copyright © 2017 LucaKiedrowski. All rights reserved.
//

import UIKit
import Firebase

protocol GameGroupsCellDelegate {
    func didTapSeeAll(game: Game)
}

class GameGroupsCell: BaseCell, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UICollectionViewDelegate {
    
    let cellId = "cellId"
    
    var delegate: GameGroupsCellDelegate?
    var timer: Timer?
    
    var gameId: String? {
        didSet {
//            timer?.invalidate()
//            timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(reloadGameId), userInfo: nil, repeats: false)
            guard let gameId = gameId else { return }
            Database.fetchGameWithId(id: gameId) { (game) in
                self.game = game
            }
        }
    }
    
    var game: Game? {
        didSet {
            collectionView.reloadData()
            guard let gamename = game?.name else { return }
            gamenameLabel.text = gamename
        }
    }
    
    var groups = [Group]() {
        didSet {
            
            if groups.count > 0 {
                seeAllButton.isHidden = false
            } else {
                seeAllButton.isHidden = true
            }
            collectionView.reloadData()
        }
    }
    
    var groupsController: GroupsController?
    var homeController: HomeController?
    
    var cellBackgroundColor: UIColor?
    
    let gamenameLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.white
        label.font = UIFont.boldSystemFont(ofSize: 16)
        return label
    }()
    
    lazy var seeAllButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("See All >>", for: .normal)
        button.setTitleColor(UIColor.white, for: .normal)
        button.addTarget(self, action: #selector(handleSeeAll), for: .touchUpInside)
        button.isHidden = true
        return button
    }()
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.dataSource = self
        cv.delegate = self
        return cv
    }()
    
    override func setupCell() {
        super.setupCell()
        
        backgroundColor = ColorCodes.clansportlerBlue
        
        setupCollectionView()
        setupViews()
    }
    
    fileprivate func setupCollectionView() {
        collectionView.register(GroupVerticalCell.self, forCellWithReuseIdentifier: cellId)
        collectionView.backgroundColor = ColorCodes.clansportlerBlue
        collectionView.alwaysBounceHorizontal = true
        collectionView.contentInset = UIEdgeInsetsMake(0, 8, 0, 8)
    }
    
    fileprivate func setupViews() {
        
        addSubview(seeAllButton)
        addSubview(gamenameLabel)
        
        addSubview(collectionView)
        
        seeAllButton.anchor(top: topAnchor, left: nil, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 8, width: 100, height: 35)
        
        gamenameLabel.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: seeAllButton.leftAnchor, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 8, width: 0, height: 35)
        
        collectionView.anchor(top: gamenameLabel.bottomAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
    }
    
    @objc func handleSeeAll() {
        guard let game = self.game else { return }
        delegate?.didTapSeeAll(game: game)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return groups.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! GroupVerticalCell
        
        let group = groups[indexPath.item]
        
        if let cellBackgroundColor = self.cellBackgroundColor {
            cell.backgroundColor = cellBackgroundColor
        }
        
        cell.group = group
        cell.game = self.game
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
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
            
            if let groupsController = self.groupsController {
                groupsController.present(navController, animated: true, completion: {
                    //completion here
                    openGroupController.showJoiningAlertController()
                })
            }
            if let homeController = self.homeController {
                homeController.present(navController, animated: true, completion: {
                    //completion here
                    openGroupController.showJoiningAlertController()
                })
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let height = collectionView.frame.height
        let width: CGFloat = 160
        
        return CGSize(width: width, height: height)
    }
    
}














