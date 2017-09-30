//
//  MemberCell.swift
//  Clansportler
//
//  Created by Luca Kiedrowski on 07.08.17.
//  Copyright © 2017 LucaKiedrowski. All rights reserved.
//

import UIKit

protocol MemberCellDelegate {
    func didTapCancel(user: User)
}

class MemberCell: BaseCell {
    
    var delegate: MemberCellDelegate?
    
    var user: User? {
        didSet {
            guard let profileImageUrl = user?.profileImageUrl else { return }
            profileImageView.loadImage(urlString: profileImageUrl)
            
            guard let username = user?.username else { return }
            usernameLabel.text = username.lowercased()
        }
    }
    
    lazy var profileImageView: CustomImageView = {
        let iv = CustomImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.borderColor = ColorCodes.clansportlerDarkBlue.cgColor
        iv.layer.borderWidth = 2
        return iv
    }()
    
    let usernameLabel: UILabel = {
        let label = UILabel()
        label.text = "username"
        label.textAlignment = .center
        label.textColor = ColorCodes.darkestGrey
        label.font = UIFont.systemFont(ofSize: 12)
        return label
    }()
    
    let checkmarkImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = #imageLiteral(resourceName: "Checkmark_blue")
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.isHidden = true
        return iv
    }()
    
    lazy var cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "cancel"), for: .normal)
        button.layer.borderColor = ColorCodes.darkestGrey.cgColor
        button.layer.borderWidth = 2
        button.tintColor = ColorCodes.darkestGrey
        button.addTarget(self, action: #selector(handleDeleteCell), for: .touchUpInside)
        button.layer.cornerRadius = 25/2
        button.isHidden = true
        button.isEnabled = false
        return button
    }()
    
    @objc func handleDeleteCell() {
        guard let user = user else { return }
        delegate?.didTapCancel(user: user)
    }
    
    override func setupCell() {
        super.setupCell()
        
        addSubview(profileImageView)
        profileImageView.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 100)
        profileImageView.layer.cornerRadius = 100 / 2
        
        addSubview(usernameLabel)
        usernameLabel.anchor(top: profileImageView.bottomAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        
        addSubview(checkmarkImageView)
        checkmarkImageView.anchor(top: topAnchor, left: nil, bottom: nil, right: rightAnchor, paddingTop: 70, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 35, height: 35)
        
        addSubview(cancelButton)
        cancelButton.anchor(top: topAnchor, left: nil, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 25, height: 25)
        
    }
    
}
