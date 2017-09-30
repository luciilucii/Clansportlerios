//
//  GroupVerticalCell.swift
//  Clansportler
//
//  Created by Luca Kiedrowski on 02.09.17.
//  Copyright © 2017 LucaKiedrowski. All rights reserved.
//

import UIKit
import Firebase

class GroupVerticalCell: BaseCell {
    
    var game: Game? {
        didSet {
            guard let imageUrl = game?.imageUrl else { return }
            gameImageView.loadImage(urlString: imageUrl)
        }
    }
    
    var group: Group? {
        didSet {
            self.memberLabel.text = nil
            self.descriptionLabel.text = nil
            self.usernameLabel.text = nil
            self.timestampLabel.text = nil
            
            guard let maxNumber = group?.maxGroupMember else { return }
            guard let currentCount = group?.memberIds?.count else { return }
            guard let wildcardCount = group?.wildcardCount else { return }
            
            memberLabel.text = "\(currentCount + wildcardCount)/\(maxNumber)"
            
            guard let descriptionText = group?.description else { return }
            descriptionLabel.text = descriptionText
            
            guard let adminId = group?.adminId else { return }
            Database.fetchUserWithUID(uid: adminId) { (admin) in
                self.usernameLabel.text = admin.username
            }
            
            guard let timestamp = group?.createdAt else { return }
            self.timestampLabel.text = timestamp.timeAgoDisplay()
            
        }
    }
    
    let backgroundWhiteView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        view.layer.cornerRadius = 5
        view.clipsToBounds = true
        return view
    }()
    
    let redView: UIView = {
        let view = UIView()
        view.backgroundColor = ColorCodes.clansportlerRed
        return view
    }()
    
    let memberLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.white
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.textAlignment = .center
        return label
    }()
    
    let gameImageView: CustomImageView = {
        let iv = CustomImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        return iv
    }()
    
    let descriptionLabel: UILabel = {
        let label = UILabel()
        label.textColor = ColorCodes.darkestGrey
        label.textAlignment = .left
        label.numberOfLines = 3
        label.textColor = ColorCodes.middleGrey
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()
    
    let usernameLabel: UILabel = {
        let label = UILabel()
        label.textColor = ColorCodes.clansportlerPurple
        label.font = UIFont.boldSystemFont(ofSize: 11)
        return label
    }()
    
    let timestampLabel: UILabel = {
        let label = UILabel()
        label.textColor = ColorCodes.middleGrey
        label.textAlignment = .right
        label.font = UIFont.systemFont(ofSize: 9)
        return label
    }()
    
    override func setupCell() {
        super.setupCell()
        
        backgroundColor = ColorCodes.clansportlerBlue
        setupViews()
    }
    
    fileprivate func setupViews() {
        addSubview(backgroundWhiteView)
        addSubview(redView)
        
        backgroundWhiteView.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 5, paddingLeft: 5, paddingBottom: 5, paddingRight: 5, width: 0, height: 0)
        
        redView.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 100, height: 30)
        
        redView.addSubview(memberLabel)
        memberLabel.anchor(top: redView.topAnchor, left: redView.leftAnchor, bottom: redView.bottomAnchor, right: redView.rightAnchor, paddingTop: 0, paddingLeft: 2, paddingBottom: 0, paddingRight: 2, width: 0, height: 0)
        
        setupWhiteView()
    }
    
    fileprivate func setupWhiteView() {
        backgroundWhiteView.addSubview(gameImageView)
        backgroundWhiteView.addSubview(descriptionLabel)
        backgroundWhiteView.addSubview(usernameLabel)
        backgroundWhiteView.addSubview(timestampLabel)
        
        gameImageView.anchor(top: backgroundWhiteView.topAnchor, left: backgroundWhiteView.leftAnchor, bottom: nil, right: backgroundWhiteView.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 84)
        
        descriptionLabel.anchor(top: gameImageView.bottomAnchor, left: backgroundWhiteView.leftAnchor, bottom: nil, right: backgroundWhiteView.rightAnchor, paddingTop: 0, paddingLeft: 4, paddingBottom: 0, paddingRight: 4, width: 0, height: 75)
        
        usernameLabel.anchor(top: nil, left: leftAnchor, bottom: bottomAnchor, right: centerXAnchor, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 4, width: 0, height: 25)
        
        timestampLabel.anchor(top: nil, left: centerXAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 8, width: 0, height: 25)
        
    }
    
}
















