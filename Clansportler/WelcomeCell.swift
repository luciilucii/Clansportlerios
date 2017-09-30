//
//  WelcomeCell.swift
//  Clansportler
//
//  Created by Luca Kiedrowski on 11.08.17.
//  Copyright © 2017 LucaKiedrowski. All rights reserved.
//

import UIKit

class WelcomeCell: BaseCell {
    
    var user: User? {
        didSet {
            guard let username = user?.username else { return }
            guard let userProfileUrl = user?.profileImageUrl else { return }
            
            usernameLabel.text = "Hi \(username)!"
            profileImageView.loadImage(urlString: userProfileUrl)
        }
    }
    
    let backgroundImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.image = #imageLiteral(resourceName: "home welcome")
        return iv
    }()
    
    let profileImageView: CustomImageView = {
        let iv = CustomImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.alpha = 0
        return iv
    }()
    
    let usernameLabel: UILabel = {
        let label = UILabel()
        label.textColor = ColorCodes.clansportlerBlue
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.textAlignment = .center
        return label
    }()
    
    let subTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Awesome to see you back!"
        label.textAlignment = .center
        label.textColor = ColorCodes.clansportlerRed
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.numberOfLines = 2
        return label
    }()
    
    var profileImageTopAnchor: NSLayoutConstraint?
    
    override func setupCell() {
        super.setupCell()
        
        layer.cornerRadius = 5
        backgroundColor = UIColor.white
        
        addSubview(backgroundImageView)
        addSubview(profileImageView)
        addSubview(usernameLabel)
        addSubview(subTitleLabel)
        
        _ = Timer.scheduledTimer(timeInterval: 1.3, target: self, selector: #selector(animateProfileImage), userInfo: nil, repeats: false)
        
        backgroundImageView.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 8, paddingLeft: 8, paddingBottom: 50, paddingRight: 8, width: 0, height: 0)
        
        profileImageView.anchor(top: nil, left: nil, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 65, height: 65)
        
        profileImageTopAnchor = profileImageView.topAnchor.constraint(equalTo: topAnchor, constant: 90)
        profileImageTopAnchor?.isActive = true
        
        profileImageView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        profileImageView.layer.cornerRadius = 65 / 2
        
        usernameLabel.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 98, paddingLeft: 8, paddingBottom: 0, paddingRight: 8, width: 0, height: 30)
        
        subTitleLabel.anchor(top: usernameLabel.bottomAnchor, left: nil, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 170, height: 48)
        subTitleLabel.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        
    }
    
    
    @objc func animateProfileImage() {
        profileImageTopAnchor?.constant = 25
        UIView.animate(withDuration: 1.3, delay: 0, usingSpringWithDamping: 2, initialSpringVelocity: 2, options: .curveEaseOut, animations: {
            self.profileImageView.alpha = 1
            self.layoutIfNeeded()
        }, completion: nil)
        
    }
    
}













