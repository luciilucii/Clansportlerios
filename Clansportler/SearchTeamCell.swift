//
//  SearchTeamCell.swift
//  Clansportler
//
//  Created by Luca Kiedrowski on 19.08.17.
//  Copyright © 2017 LucaKiedrowski. All rights reserved.
//

import UIKit

class SearchTeamCell: BaseCell {
    
    var team: Team? {
        didSet {
            guard let imageUrl = team?.profileImageUrl else { return }
            teamImageView.loadImage(urlString: imageUrl)
            
            guard let teamname = team?.teamname else { return }
            teamnameLabel.text = teamname
            
            guard let member = team?.member else { return }
            memberLabel.text = "\(member.count) member"
            
        }
    }
    
    let teamImageView: CustomImageView = {
        let iv = CustomImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        return iv
    }()
    
    let teamnameLabel: UILabel = {
        let label = UILabel()
        label.text = "teamname"
        label.textColor = ColorCodes.darkestGrey
        label.font = UIFont.boldSystemFont(ofSize: 16)
        return label
    }()
    
    let memberLabel: UILabel = {
        let label = UILabel()
        label.text = "member count"
        label.textColor = ColorCodes.darkestGrey
        label.font = UIFont.systemFont(ofSize: 13)
        return label
    }()
    
    let seperatorView: UIView = {
        let view = UIView()
        view.backgroundColor = ColorCodes.inActiveElementsGrey
        return view
    }()
    
    override func setupCell() {
        super.setupCell()
        
        self.backgroundColor = UIColor.white
        
        setupViews()
    }
    
    func setupViews() {
        
        addSubview(teamImageView)
        addSubview(teamnameLabel)
        addSubview(memberLabel)
        addSubview(seperatorView)
        
        teamImageView.anchor(top: nil, left: leftAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 50, height: 50)
        teamImageView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        teamImageView.layer.cornerRadius = 50 / 2
        
        teamnameLabel.anchor(top: topAnchor, left: teamImageView.rightAnchor, bottom: nil, right: rightAnchor, paddingTop: 8, paddingLeft: 8, paddingBottom: 0, paddingRight: 8, width: 0, height: 25)
        
        memberLabel.anchor(top: teamnameLabel.bottomAnchor, left: teamnameLabel.leftAnchor, bottom: bottomAnchor, right: teamnameLabel.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 8, paddingRight: 0, width: 0, height: 0)
        
        seperatorView.anchor(top: nil, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0.5)
        
    }
    
}
