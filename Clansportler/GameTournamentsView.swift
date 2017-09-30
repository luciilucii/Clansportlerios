//
//  GameTournamentsView.swift
//  Clansportler
//
//  Created by Luca Kiedrowski on 28.09.17.
//  Copyright © 2017 LucaKiedrowski. All rights reserved.
//

import UIKit
import Firebase

class GameTournamentsView: CustomView/*, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout*/ {
    
    var gameController: GameController?
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Upcoming Tournaments"
        label.textColor = UIColor.white
        label.font = UIFont.boldSystemFont(ofSize: 16)
        return label
    }()
    
//    lazy var collectionView: UICollectionView = {
//        let layout = UICollectionViewFlowLayout()
//        layout.scrollDirection = .horizontal
//        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
//        cv.dataSource = self
//        cv.delegate = self
//        cv.backgroundColor = UIColor.white
//        cv.showsHorizontalScrollIndicator = false
//        cv.alwaysBounceHorizontal = true
//        return cv
//    }()
    
    override func setupCustomView() {
        super.setupCustomView()
        
        self.backgroundColor = ColorCodes.clansportlerPurple
        self.clipsToBounds = true
        self.layer.cornerRadius = 5
        
        setupViews()
    }
    
    fileprivate func setupViews() {
        addSubview(titleLabel)
        
        titleLabel.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 8, paddingLeft: 8, paddingBottom: 0, paddingRight: 8, width: 0, height: 25)
    }
    
}











