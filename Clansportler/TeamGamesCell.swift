//
//  TeamGamesCell.swift
//  Clansportler
//
//  Created by Luca Kiedrowski on 17.08.17.
//  Copyright © 2017 LucaKiedrowski. All rights reserved.
//

import UIKit
import Firebase

class TeamGamesCell: BaseCell {
    
    var gameId: String? {
        didSet {
            self.gameImageView.image = nil
            self.gameLabel.text = nil
            
            guard let id = gameId else { return }
            Database.fetchGameWithId(id: id) { (game) in
                
                guard let imageUrl = game.imageUrl else { return }
                self.gameImageView.loadImage(urlString: imageUrl)
                
                guard let gamename = game.name else { return }
                self.gameLabel.text = gamename
            }
        }
    }
    
    var playerCount: Int? {
        didSet {
            guard let count = playerCount else { return }
            setupPercentage(playerCount: count)
        }
    }
    
    var teamMemberCount: Int? 
    
    let gameImageView: CustomImageView = {
        let iv = CustomImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 5
        iv.layer.borderColor = UIColor.white.cgColor
        iv.layer.borderWidth = 1
        return iv
    }()
    
    let gameLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.white
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 16)
        return label
    }()
    
    let percentageLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.white
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 12)
        return label
    }()
    
    override func setupCell() {
        super.setupCell()
        
        self.gameId = nil
        
        backgroundColor = ColorCodes.clansportlerBlue
        self.layer.cornerRadius = 5
        
        setupViews()
        
    }
    
    func setupViews() {
        addSubview(gameImageView)
        addSubview(gameLabel)
        addSubview(percentageLabel)
        
        gameImageView.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 4, paddingLeft: 4, paddingBottom: 0, paddingRight: 4, width: 0, height: 80)
        
        gameLabel.anchor(top: gameImageView.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 4, paddingBottom: 0, paddingRight: 4 , width: 0, height: 25)
        
        percentageLabel.anchor(top: gameLabel.bottomAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 4, paddingBottom: 2, paddingRight: 4, width: 0, height: 0)
        
    }
    
    func setupPercentage(playerCount: Int) {
        
        guard let memberCount = self.teamMemberCount, let playerCount = self.playerCount else { return }
        let percentage = playerCount * 100 / memberCount
        percentageLabel.text = "\(percentage)% of Members"
        
    }
    
}






