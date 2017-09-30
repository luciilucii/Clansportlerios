//
//  MyGamesCell.swift
//  Clansportler
//
//  Created by Luca Kiedrowski on 16.08.17.
//  Copyright © 2017 LucaKiedrowski. All rights reserved.
//

import UIKit
import Firebase

protocol MyGamesCellDelegate {
    func didTapCancel(game: Game)
}

class MyGamesCell: BaseCell {
    
    var game: Game? {
        didSet {
            guard let imageUrl = game?.imageUrl else { return }
            gameImageView.loadImage(urlString: imageUrl)
        }
    }
    
    var gameId: String? {
        didSet {
            guard let id = gameId else { return }
            self.gameImageView.image = nil
            
            Database.fetchGameWithId(id: id) { (game) in
                self.game = game
            }
        }
    }
    
    var delegate: MyGamesCellDelegate?
    
    let gameImageView: CustomImageView = {
        let iv = CustomImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        return iv
    }()
    
    lazy var cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "cancel").withRenderingMode(.alwaysTemplate), for: .normal)
        button.layer.borderColor = UIColor.white.cgColor
        button.layer.borderWidth = 2
        button.tintColor = UIColor.white
        button.addTarget(self, action: #selector(handleDeleteCell), for: .touchUpInside)
        button.layer.cornerRadius = 30/2
        button.isHidden = true
        button.isEnabled = false
        return button
    }()
    
    override func setupCell() {
        super.setupCell()
        
        self.layer.cornerRadius = 5
        
        self.layer.borderColor = UIColor.white.cgColor
        self.layer.borderWidth = 1
        
        self.clipsToBounds = true
        
        setupViews()
    }
    
    func setupViews() {
        addSubview(gameImageView)
        
        gameImageView.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        
        
        addSubview(cancelButton)
        cancelButton.anchor(top: topAnchor, left: nil, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 30, height: 30)
    }
    
    @objc func handleDeleteCell() {
        guard let game = self.game else { return }
        delegate?.didTapCancel(game: game)
    }
    
}







