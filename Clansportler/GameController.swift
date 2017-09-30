//
//  GameController.swift
//  Clansportler
//
//  Created by Luca Kiedrowski on 27.09.17.
//  Copyright © 2017 LucaKiedrowski. All rights reserved.
//

import UIKit
import Firebase

class GameController: ScrollController {
    
    var game: Game? {
        didSet {
            gamePlayerView.game = game
            
            guard let imageUrl = game?.imageUrl else { return }
            gameImageView.loadImage(urlString: imageUrl)
            
            guard let gamename = game?.name else { return }
            setupWhiteTitle(title: gamename)
        }
    }
    
    let gameImageView: CustomImageView = {
        let iv = CustomImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = .blue //please remove this
        return iv
    }()
    
    lazy var gamePlayerView: GamePlayerView = {
        let view = GamePlayerView()
        view.gameController = self
        return view
    }()
    
    lazy var gameTournamentsView: GameTournamentsView = {
        let view = GameTournamentsView()
        view.gameController = self
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollContainerView.backgroundColor = ColorCodes.backgroundGrey
        
        super.setupScrollView(height: 697)
        
        super.setupController()
        
        navigationController?.navigationBar.tintColor = .white
        
        setupViews()
    }
    
    internal override func setupViews() {
        scrollContainerView.addSubview(gameImageView)
        scrollContainerView.addSubview(gamePlayerView)
        scrollContainerView.addSubview(gameTournamentsView)
        
        gameImageView.anchor(top: view.topAnchor, left: scrollContainerView.leftAnchor, bottom: scrollContainerView.topAnchor, right: scrollContainerView.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: -175, paddingRight: 0, width: 0, height: 0)
        
        gamePlayerView.anchor(top: scrollContainerView.topAnchor, left: scrollContainerView.leftAnchor, bottom: nil, right: scrollContainerView.rightAnchor, paddingTop: 183, paddingLeft: 8, paddingBottom: 0, paddingRight: 8, width: 0, height: 174)
        
        gameTournamentsView.anchor(top: gamePlayerView.bottomAnchor, left: scrollContainerView.leftAnchor, bottom: nil, right: scrollContainerView.rightAnchor, paddingTop: 8, paddingLeft: 8, paddingBottom: 0, paddingRight: 8, width: 0, height: 200)
        
    }
    
}













