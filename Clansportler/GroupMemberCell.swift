//
//  GroupMemberCell.swift
//  Clansportler
//
//  Created by Luca Kiedrowski on 11.09.17.
//  Copyright © 2017 LucaKiedrowski. All rights reserved.
//

import UIKit

class GroupMemberCell: BaseCell {
    
    var user: User? {
        didSet {
            guard let profileImageUrl = user?.profileImageUrl else { return }
            profileImageView.loadImage(urlString: profileImageUrl)
            
            guard let username = user?.username else { return }
            self.usernameLabel.text = username
            
            guard let gameId = openGroupController?.gameId else { return }
            guard let playername = user?.authentications?[gameId] else { return }
            self.playernameLabel.text = playername
        }
    }
    
    var openGroupController: OpenGroupController?
    
    let profileImageView: CustomImageView = {
        let iv = CustomImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = .brown
        return iv
    }()
    
    let usernameLabel: UILabel = {
        let label = UILabel()
        label.textColor = ColorCodes.clansportlerRed
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.textAlignment = .center
        return label
    }()
    
    let playernameLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        label.textColor = ColorCodes.backgroundGrey
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()
    
    override func setupCell() {
        super.setupCell()
        
        backgroundColor = .white
        layer.cornerRadius = 5
        clipsToBounds = true
        
        setupViews()
    }
    
    func setupViews() {
        addSubview(profileImageView)
        addSubview(usernameLabel)
        addSubview(playernameLabel)
        
        profileImageView.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 65)
        usernameLabel.anchor(top: profileImageView.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 4, paddingBottom: 0, paddingRight: 4, width: 0, height: 25)
        
        playernameLabel.anchor(top: usernameLabel.bottomAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 4, paddingLeft: 4, paddingBottom: 4, paddingRight: 4, width: 0, height: 0)
    }
    
}
