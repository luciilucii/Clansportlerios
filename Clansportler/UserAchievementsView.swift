//
//  UserAchievementsView.swift
//  Clansportler
//
//  Created by Luca Kiedrowski on 20.09.17.
//  Copyright © 2017 LucaKiedrowski. All rights reserved.
//

import UIKit
import Firebase

class UserAchievementsView: CustomView {
    
    var currentUser: User?
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Achievements"
        label.textColor = UIColor.white
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 16)
        return label
    }()
    
    let descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "Achievements coming soon."
        label.textColor = UIColor.white
        label.textAlignment = .center
        return label
    }()
    
    let spiderImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.image = #imageLiteral(resourceName: "spider")
        return iv
    }()
    
    override func setupCustomView() {
        super.setupCustomView()
        
        self.backgroundColor = ColorCodes.clansportlerRed
        self.layer.cornerRadius = 5
        
        setupViews()
    }
    
    fileprivate func setupViews() {
        
        addSubview(titleLabel)
        addSubview(descriptionLabel)
        addSubview(spiderImageView)
        
        titleLabel.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 8, paddingLeft: 8, paddingBottom: 0, paddingRight: 8, width: 0, height: 20)
        descriptionLabel.anchor(top: titleLabel.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 8, paddingLeft: 8, paddingBottom: 0, paddingRight: 8, width: 0, height: 20)
        
        spiderImageView.anchor(top: descriptionLabel.bottomAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 8, paddingLeft: 8, paddingBottom: 8, paddingRight: 8, width: 0, height: 0)
        
    }
    
    
}











