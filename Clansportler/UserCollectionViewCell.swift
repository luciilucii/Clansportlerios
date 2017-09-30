//
//  UserCollectionViewCell.swift
//  Clansportler
//
//  Created by Luca Kiedrowski on 25.08.17.
//  Copyright © 2017 LucaKiedrowski. All rights reserved.
//

import UIKit

class UserCollectionViewCell: BaseCell {
    
    var user: User? {
        didSet {
            if let profileImageUrl = user?.profileImageUrl {
                profileImageView.loadImage(urlString: profileImageUrl)
            }
            
            guard let username = user?.username else { return }
            textLabel.text = username
            
        }
    }
    
    var team: Team? {
        didSet {
            print("team set bra, it's lit!")
        }
    }
    
    var selectUserController: SelectUserCollectionViewController? {
        didSet {
            
        }
    }
    
    let textLabel: UILabel = {
        let label = UILabel()
        label.textColor = ColorCodes.clansportlerBlue
        label.font = UIFont.systemFont(ofSize: 18)
        label.text = "username"
        return label
    }()
    
    let checkmarkImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = #imageLiteral(resourceName: "Checkmark_blue")
        iv.contentMode = .scaleToFill
        iv.clipsToBounds = true
        iv.isHidden = true
        return iv
    }()
    
    let profileImageView: CustomImageView = {
        let imageView = CustomImageView()
        imageView.layer.cornerRadius = 24
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    override func setupCell() {
        super.setupCell()
        
        backgroundColor = UIColor.white
        
        addSubview(profileImageView)
        addSubview(textLabel)
        addSubview(checkmarkImageView)
        
        //ios 9 constraint anchors
        //x,y,width, height anchors
        profileImageView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 8).isActive = true
        profileImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        
        profileImageView.widthAnchor.constraint(equalToConstant: 48).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 48).isActive = true
        
        textLabel.anchor(top: topAnchor, left: profileImageView.rightAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 8, width: 0, height: 0)
        
        checkmarkImageView.anchor(top: nil, left: nil, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 12, width: 35, height: 35)
        checkmarkImageView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
    }
    
}
