//
//  UserSearchCell.swift
//  Clansportler
//
//  Created by Luca Kiedrowski on 15.09.17.
//  Copyright © 2017 LucaKiedrowski. All rights reserved.
//

import UIKit

class UserSearchCell: BaseCell {
    
    var user: User? {
        didSet {
            
            guard let imageUrl = user?.profileImageUrl else { return }
            profileImageView.loadImage(urlString: imageUrl)
            
            guard let username = user?.username else { return }
            titleLabel.text = username
        }
    }
    
    var clan: Team? {
        didSet {
            guard let imageUrl = clan?.profileImageUrl else { return }
            profileImageView.loadImage(urlString: imageUrl)
            
            guard let clanname = clan?.teamname else { return }
            titleLabel.text = clanname
        }
    }
    
    let profileImageView: CustomImageView = {
        let iv = CustomImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        return iv
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "username"
        label.textColor = UIColor.white
        label.font = UIFont.boldSystemFont(ofSize: 16)
        return label
    }()
    
    let seperatorView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        return view
    }()
    
    override func setupCell() {
        super.setupCell()
        
        setupViews()
    }
    
    func setupViews() {
        
        backgroundColor = ColorCodes.backgroundGrey
        addSubview(profileImageView)
        addSubview(titleLabel)
        addSubview(seperatorView)
        
        profileImageView.anchor(top: nil, left: leftAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 48, height: 48)
        profileImageView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        profileImageView.layer.cornerRadius = 24
        
        titleLabel.anchor(top: nil, left: profileImageView.rightAnchor, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 8, width: 0, height: 30)
        titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
        seperatorView.anchor(top: nil, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0.5)
        
    }
    
    
    
    
    
    
}
















