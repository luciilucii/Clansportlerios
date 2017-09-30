//
//  SuggestedTeamCell.swift
//  Clansportler
//
//  Created by Luca Kiedrowski on 17.08.17.
//  Copyright © 2017 LucaKiedrowski. All rights reserved.
//

import UIKit

class SuggestedTeamCell: BaseCell {
    
    var suggestedClan: SuggestedClan? {
        didSet {
            
            self.teamLabel.text = suggestedClan?.clan.teamname
            
            guard let imageUrl = suggestedClan?.clan.profileImageUrl else { return }
            self.teamImageView.loadImage(urlString: imageUrl)
            
            suggestedClan?.suggestedClanCell = self
            if suggestedClan?.biggestGame?.name != nil {
                
            }
        }
    }
    
    var suggestedClansView: SuggestedClansView?
    
    let teamImageView: CustomImageView = {
        let iv = CustomImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.borderColor = UIColor.white.cgColor
        iv.layer.borderWidth = 1
        iv.layer.cornerRadius = 5
        return iv
    }()
    
    let gamesLabel: UILabel = {
        let label = UILabel()
        label.text = "87% of members play Starcraft II"
        label.textColor = .white
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 10)
        label.numberOfLines = 2
        return label
    }()
    
    let blueView: UIView = {
        let view = UIView()
        view.backgroundColor = ColorCodes.clansportlerBlue
        return view
    }()
    
    let teamLabel: UILabel = {
        let label = UILabel()
        label.text = "teamname"
        label.textColor = .white
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 12)
        return label
    }()
    
    override func setupCell() {
        super.setupCell()
        
        backgroundColor = ColorCodes.clansportlerBlue
        self.layer.cornerRadius = 5
        
        setupViews()
    }
    
    func setupViews() {
        addSubview(teamImageView)
        addSubview(gamesLabel)
        addSubview(blueView)
        addSubview(teamLabel)
        
        teamImageView.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 4, paddingLeft: 4, paddingBottom: 0, paddingRight: 4, width: 0, height: 77)
        gamesLabel.anchor(top: teamImageView.bottomAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 2, paddingBottom: 0, paddingRight: 2, width: 0, height: 0)
        
        blueView.anchor(top: teamImageView.topAnchor, left: teamImageView.leftAnchor, bottom: nil, right: teamImageView.rightAnchor, paddingTop: 35, paddingLeft: 16, paddingBottom: 0, paddingRight: 0, width: 0, height: 20)
        
        teamLabel.anchor(top: blueView.topAnchor, left: blueView.leftAnchor, bottom: blueView.bottomAnchor, right: blueView.rightAnchor, paddingTop: 0, paddingLeft: 2, paddingBottom: 0, paddingRight: 2, width: 0, height: 0)
        
    }
}















