//
//  ApproveGamesCell.swift
//  Clansportler
//
//  Created by Luca Kiedrowski on 30.08.17.
//  Copyright © 2017 LucaKiedrowski. All rights reserved.
//

import UIKit

class ApproveGamesCell: BaseCell {
    
    var game: Game? {
        didSet {
            guard let gamename = game?.name else { return }
            gamenameLabel.text = gamename
            
            guard let imageUrl = game?.imageUrl else { return }
            gameImageView.loadImage(urlString: imageUrl)
        }
    }
    
    let gamenameLabel: UILabel = {
        let label = UILabel()
        label.text = "Starcraft 2"
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.numberOfLines = 2
        label.textColor = UIColor.white
        return label
    }()
    
    let gameImageView: CustomImageView = {
        let iv = CustomImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = UIColor.brown
        return iv
    }()
    
    override func setupCell() {
        super.setupCell()
        
        backgroundColor = ColorCodes.clansportlerBlue
        layer.cornerRadius = 5
        clipsToBounds = true
        
        setupViews()
    }
    
    fileprivate func setupViews() {
        
        addSubview(gameImageView)
        addSubview(gamenameLabel)
        
        gameImageView.anchor(top: topAnchor, left: nil, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 117, height: 0)
        
        gamenameLabel.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: gameImageView.leftAnchor, paddingTop: 8, paddingLeft: 8, paddingBottom: 0, paddingRight: 8, width: 0, height: 50)
        
    }
    
}
