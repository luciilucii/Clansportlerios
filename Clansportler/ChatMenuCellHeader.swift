//
//  ChatMenuCellHeader.swift
//  Clansportler
//
//  Created by Luca Kiedrowski on 30.07.17.
//  Copyright © 2017 LucaKiedrowski. All rights reserved.
//

import UIKit
import Firebase

class ChatMenuCellHeader: BaseCell {
    
    var team: Team? {
        didSet {
            guard let teamname = team?.teamname else { return }
            
            self.teamnameLabel.text = teamname
        }
    }
    
    let profileImageView: CustomImageView = {
        let iv = CustomImageView()
        iv.backgroundColor = .blue
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.borderWidth = 2
        iv.layer.borderColor = UIColor.white.cgColor
        return iv
    }()
    
    let usernameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont.boldSystemFont(ofSize: 20)
        return label
    }()
    
    let teamnameLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(white: 1, alpha: 0.8)
        label.font = UIFont.boldSystemFont(ofSize: 20)
        return label
    }()
    
    let seperatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    
    override func setupCell() {
        super.setupCell()
        
        backgroundColor = ColorCodes.darkestGrey
        
        addSubview(profileImageView)
        addSubview(usernameLabel)
        addSubview(teamnameLabel)
        addSubview(seperatorView)
        
        profileImageView.anchor(top: nil, left: leftAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 16, paddingBottom: 0, paddingRight: 0, width: 75, height: 75)
        profileImageView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        profileImageView.layer.cornerRadius = 75 / 2
        
        usernameLabel.anchor(top: nil, left: profileImageView.rightAnchor, bottom: profileImageView.centerYAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 8, width: 0, height: 22)
        
        teamnameLabel.anchor(top: profileImageView.centerYAnchor, left: usernameLabel.leftAnchor, bottom: nil, right: usernameLabel.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 22)
        
        seperatorView.anchor(top: nil, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 0, height: 0.5)
        
       loadProfile()
    }
    
    func loadProfile() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        let userRef = Database.database().reference().child("users").child(userId)
        userRef.observeSingleEvent(of: .value, with: { (snapshot) in
            
            guard let dictionary = snapshot.value as? [String: Any] else { return }
            
            let user = User(uid: userId, dictionary: dictionary)
            
            self.usernameLabel.text = user.username
            self.profileImageView.loadImage(urlString: user.profileImageUrl)
            
            if let teamId = user.team {
                self.loadTeam(teamId: teamId)
            } else {
                self.teamnameLabel.text = "No Clan yet"
            }
            
        }) { (err) in
            print("failed to fetch profile Image: ", err)
        }
    }
    
    func loadTeam(teamId: String) {
        
        let teamRef = Database.database().reference().child("teams").child(teamId)
        teamRef.observeSingleEvent(of: .value, with: { (snapshot) in
            
            guard let dictionary = snapshot.value as? [String: Any] else { return }
            self.team = Team(uid: teamId, values: dictionary)
            
        }) { (err) in
            print("failed to fetch Team", err)
        }
        
    }
    
}


