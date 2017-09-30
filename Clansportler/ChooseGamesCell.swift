//
//  ChooseGamesCell.swift
//  Clansportler
//
//  Created by Luca Kiedrowski on 12.08.17.
//  Copyright © 2017 LucaKiedrowski. All rights reserved.
//

import UIKit

protocol ChooseGamesCellDelegate {
    func didTapCancel(game: Game)
}

class ChooseGamesCell: BaseCell {
    
    var game: Game? {
        didSet {
            guard let imageUrl = game?.imageUrl else { return }
            
            gameImageView.loadImage(urlString: imageUrl)
            
            guard let gamename = game?.name else { return }
            gameTitleLabel.text = gamename
        }
    }
    
    var delegate: ChooseGamesCellDelegate?
    
    let gameImageView: CustomImageView = {
        let iv = CustomImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 5
        iv.layer.borderColor = UIColor.white.cgColor
        iv.layer.borderWidth = 1
        return iv
    }()
    
    let gameTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Starcraft 2"
        label.textColor = UIColor.white
        label.textAlignment = .center
        label.numberOfLines = 2
        label.font = UIFont.boldSystemFont(ofSize: 18)
        return label
    }()
    
    override func setupCell() {
        super.setupCell()
        
        self.layer.cornerRadius = 5
        
        backgroundColor = ColorCodes.clansportlerBlue
        setupViews()
    }
    
    func setupViews() {
        addSubview(gameImageView)
        addSubview(gameTitleLabel)
        
        gameImageView.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 4, paddingLeft: 4, paddingBottom: 0, paddingRight: 4, width: 0, height: 75)
        
        gameTitleLabel.anchor(top: gameImageView.bottomAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 4, paddingLeft: 4, paddingBottom: 4, paddingRight: 4, width: 0, height: 0)
        
        
    }
    
    func handleDeleteCell() {
        guard let game = self.game else { return }
        delegate?.didTapCancel(game: game)
    }
    
}
