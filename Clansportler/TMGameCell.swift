//
//  TMGameCell.swift
//  Clansportler
//
//  Created by Luca Kiedrowski on 20.08.17.
//  Copyright © 2017 LucaKiedrowski. All rights reserved.
//

import UIKit
import Firebase

class TMGameCell: BaseCell {
    
    var gameId: String? {
        didSet {
            guard let gameId = gameId else { return }
            fetchGame(withId: gameId)
        }
    }
    
    var game: Game? {
        didSet {
            guard let gamename = game?.name else { return }
            gameLabel.text = gamename
            
            guard let imageUrl = game?.imageUrl else { return }
            imageView.loadImage(urlString: imageUrl)
            
            guard let playerCount = game?.playerCount else { return }
            playerLabel.text = "\(playerCount) registered player"
        }
    }
    
    let imageView: CustomImageView = {
        let iv = CustomImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        return iv
    }()
    
    let gameLabel: UILabel = {
        let label = UILabel()
        label.textColor = ColorCodes.darkestGrey
        label.font = UIFont.boldSystemFont(ofSize: 16)
        return label
    }()
    
    let playerLabel: UILabel = {
        let label = UILabel()
        label.textColor = ColorCodes.darkestGrey
        label.font = UIFont.systemFont(ofSize: 12)
        return label
    }()
    
    override func setupCell() {
        super.setupCell()
        
        self.clipsToBounds = true
        self.layer.cornerRadius = 5
        
        self.backgroundColor = .white
        
        addSubview(imageView)
        addSubview(gameLabel)
        addSubview(playerLabel)
        
        imageView.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 70, height: 0)
        gameLabel.anchor(top: topAnchor, left: imageView.rightAnchor, bottom: nil, right: rightAnchor, paddingTop: 6, paddingLeft: 8, paddingBottom: 0, paddingRight: 8, width: 0, height: 20)
        playerLabel.anchor(top: gameLabel.bottomAnchor, left: imageView.rightAnchor, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 8, width: 0, height: 20)
        
        
    }
    
    func fetchGame(withId: String) {
        let gameRef = Database.database().reference().child("games").child(withId)
        gameRef.observeSingleEvent(of: .value, with: { (snapshot) in
            
            guard let dictionary = snapshot.value as? [String: Any] else { return }
            let game = Game(id: withId, dictionary: dictionary)
            self.game = game
            
        }) { (err) in
            print("failed to fetch game", err)
        }
    }
    
}











