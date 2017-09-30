//
//  ChooseGamesHeader.swift
//  Clansportler
//
//  Created by Luca Kiedrowski on 23.09.17.
//  Copyright © 2017 LucaKiedrowski. All rights reserved.
//

import UIKit
import Firebase

class ChooseGamesHeader: BaseCell, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, MyGamesCellDelegate {
    
    let cellId = "cellId"
    
    var tabbedGames = [Game]() {
        didSet {
            self.collectionView.reloadData()
        }
    }
    
    let chooseGamesLabel: UILabel = {
        let label = UILabel()
        label.text = "Choose your games"
        label.textColor = UIColor.white
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 16)
        return label
    }()
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.dataSource = self
        cv.delegate = self
        return cv
    }()
    
    var chooseGamesController: ChooseGamesController?
    
    override func setupCell() {
        super.setupCell()
        
        setupCollectionView()
        setupViews()
    }
    
    fileprivate func setupCollectionView() {
        collectionView.backgroundColor = ColorCodes.backgroundGrey
        collectionView.contentInset = UIEdgeInsetsMake(0, 8, 0, 8)
        collectionView.alwaysBounceHorizontal = true
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.register(MyGamesCell.self, forCellWithReuseIdentifier: cellId)
    }
    
    fileprivate func setupViews() {
        addSubview(chooseGamesLabel)
        addSubview(collectionView)
        
        chooseGamesLabel.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 8, width: 0, height: 30)
        
        collectionView.anchor(top: chooseGamesLabel.bottomAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: -8, paddingBottom: 0, paddingRight: -8, width: 0, height: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width: CGFloat = 168
        let height: CGFloat = 95
        
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tabbedGames.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! MyGamesCell
        
        let game = tabbedGames[indexPath.item]
        
        cell.delegate = self
        cell.game = game
        cell.cancelButton.isEnabled = true
        cell.cancelButton.isHidden = false
        
        return cell
    }
    
    func didTapCancel(game: Game) {
        let index = tabbedGames.index { (tGame) -> Bool in
            return game.id == tGame.id
        }
        if let gameIndex = index {
            tabbedGames.remove(at: gameIndex)
            
            chooseGamesController?.tabbedGames = tabbedGames
        }
        collectionView.reloadData()
    }
    
}




















