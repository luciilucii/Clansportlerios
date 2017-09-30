//
//  MessageCell.swift
//  Clansportler
//
//  Created by Luca Kiedrowski on 31.07.17.
//  Copyright © 2017 LucaKiedrowski. All rights reserved.
//

import UIKit

class MessageCell: UITableViewCell {
    
    var messagesCell: MessagesCell?
    
    var newMessagesCount = 0
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupCell()
    }
    
    var user: User? {
        didSet {
            guard let username = user?.username else { return }
            usernameLabel.text = username.lowercased()
        }
    }
    
    var groupchat: Groupchat? {
        didSet {
            guard let groupname = groupchat?.name else { return }
            usernameLabel.text = groupname.lowercased()
        }
    }
        
    let blueView: UIView = {
        let view = UIView()
        view.backgroundColor = ColorCodes.darkestGrey
        return view
    }()
    
    let usernameLabel: UILabel = {
        let label = UILabel()
        label.text = "#username"
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 18)
        return label
    }()
    
    let badgeLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.textAlignment = .center
        label.text = "new"
        label.layer.masksToBounds = true
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.backgroundColor = ColorCodes.clansportlerRed
        label.isHidden = true
        return label
    }()
    
    func setupCell() {
        
        backgroundColor = ColorCodes.darkestGrey
        
        addSubview(blueView)
        
        blueView.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 2, paddingLeft: 8, paddingBottom: 2, paddingRight: 8, width: 0, height: 0)
        
        blueView.layer.cornerRadius = 7
        
        blueView.addSubview(usernameLabel)
        blueView.addSubview(badgeLabel)
        
        usernameLabel.anchor(top: blueView.topAnchor, left: blueView.leftAnchor, bottom: blueView.bottomAnchor, right: blueView.rightAnchor, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 8, width: 0, height: 0)
        
        badgeLabel.anchor(top: topAnchor, left: nil, bottom: bottomAnchor, right: rightAnchor, paddingTop: 10, paddingLeft: 0, paddingBottom: 10, paddingRight: 8, width: 40, height: 0)
        badgeLabel.layer.cornerRadius = 10
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        if isSelected {
            blueView.backgroundColor = ColorCodes.clansportlerBlue
            usernameLabel.font = UIFont.boldSystemFont(ofSize: 16)
        } else {
            blueView.backgroundColor = ColorCodes.darkestGrey
            usernameLabel.font = UIFont.systemFont(ofSize: 16)
        }
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
