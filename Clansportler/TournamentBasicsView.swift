//
//  TournamentBasicsView.swift
//  Clansportler
//
//  Created by Luca Kiedrowski on 30.09.17.
//  Copyright © 2017 LucaKiedrowski. All rights reserved.
//

import UIKit
import Firebase

class TournamentBasicsView: CustomView {
    
    var tournament: Tournament? {
        didSet {
            //do sth here
            guard let gameId = tournament?.gameId else { return }
            Database.fetchGameWithId(id: gameId) { (game) in
                self.game = game
            }
            guard let tournamentName = tournament?.fullName else { return }
            self.tournamentTitleLabel.text = tournamentName
            
            guard let teamSize = tournament?.teamSize else { return }
            self.teamSizeLabel.text = "\(teamSize)v\(teamSize)"
        }
    }
    
    var game: Game? {
        didSet {
            guard let gamename = game?.name else { return }
            self.gamenameLabel.text = gamename
        }
    }
    
    lazy var gamenameLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.white
        label.text = "Game Title"
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.textAlignment = .center
        return label
    }()
    
    lazy var teamSizeLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.white
        label.text = "1v1"
        label.font = UIFont.boldSystemFont(ofSize: 48)
        label.textAlignment = .center
        return label
    }()
    
    lazy var tournamentTitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.white
        label.text = "Tournament Title with the Full name of the Tournamnet"
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.textAlignment = .center
        label.numberOfLines = 2
        return label
    }()
    
    override func setupCustomView() {
        super.setupCustomView()
        
        self.backgroundColor = ColorCodes.clansportlerBlue
        self.clipsToBounds = true
        self.layer.cornerRadius = 5
        
        setupViews()
    }
    
    fileprivate func setupViews() {
        //Size should be 166 px
            
        addSubview(gamenameLabel)
        addSubview(teamSizeLabel)
        addSubview(tournamentTitleLabel)
        
        gamenameLabel.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 8, paddingLeft: 8, paddingBottom: 0, paddingRight: 8, width: 0, height: 50)
        
        teamSizeLabel.anchor(top: gamenameLabel.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 8, width: 0, height: 0)
        
        tournamentTitleLabel.anchor(top: nil, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 8, paddingBottom: 8, paddingRight: 8, width: 0, height: 50)
        
        
    }
    
}
