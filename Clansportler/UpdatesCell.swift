//
//  UpdatesCell.swift
//  Clansportler
//
//  Created by Luca Kiedrowski on 07.08.17.
//  Copyright © 2017 LucaKiedrowski. All rights reserved.
//

import UIKit

class UpdatesCell: BaseCell {
    
    var update: Update? {
        didSet {
            guard let imageUrl = update?.imageUrl else { return }
            imageView.loadImage(urlString: imageUrl)
            
            if let update = update as? TeamInvitationUpdate {
                setupAttributedTextForTeamInvitationUpdate(update: update)
            } else if let update = update as? JoinTeamRequestUpdate {
                setupAttributedTextForJoinTeamRequests(update: update)
            } else if let update = update as? JoinedTeamUpdate {
                setupAttributedTextForJoinedTeamUpdate(update: update)
            } else if let update = update as? GroupInvitationUpdate {
                setupAttributedTextForGroupInvitationUpdate(update: update)
            }
        }
    }
    
    private func setupAttributedTextForTeamInvitationUpdate(update: TeamInvitationUpdate) {
//        guard let update = self.update else { return }
        guard let text = update.text else { return }
        guard let fromName = update.fromName else { return }
        guard let teamname = update.teamname else { return }
        guard let timestamp = update.timestamp else { return }
        
        let attributedText = NSMutableAttributedString(string: fromName, attributes: [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 16), NSAttributedStringKey.foregroundColor: UIColor.white])
        
        attributedText.append(NSAttributedString(string: " \(text) ", attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 16), NSAttributedStringKey.foregroundColor: UIColor.white]))

        attributedText.append(NSAttributedString(string: teamname, attributes: [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 16), NSAttributedStringKey.foregroundColor: ColorCodes.clansportlerPurple]))
        
        self.typeLabel.text = "Clan Invitation"
        self.titleLabel.attributedText = attributedText
        self.timestampLabel.text = timestamp.timeAgoDisplay()
    }
    
    private func setupAttributedTextForJoinTeamRequests(update: JoinTeamRequestUpdate) {
        
        guard let text = update.text else { return }
        guard let fromName = update.fromName else { return }
        guard let teamname = update.teamname else { return }
        guard let timestamp = update.timestamp else { return }
        
        let attributedText = NSMutableAttributedString(string: fromName, attributes: [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 16), NSAttributedStringKey.foregroundColor: UIColor.white])
        
        attributedText.append(NSAttributedString(string: " \(text) ", attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 16), NSAttributedStringKey.foregroundColor: UIColor.white]))
        
        attributedText.append(NSAttributedString(string: teamname, attributes: [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 16), NSAttributedStringKey.foregroundColor: ColorCodes.clansportlerPurple]))
        
        self.typeLabel.text = "Joining Request"
        self.titleLabel.attributedText = attributedText
        self.timestampLabel.text = timestamp.timeAgoDisplay()
    }
    
    private func setupAttributedTextForJoinedTeamUpdate(update: JoinedTeamUpdate) {
//        guard let update = self.update else { return }
        guard let text = update.text else { return }
        guard let fromName = update.fromName else { return }
        guard let teamname = update.teamname else { return }
        guard let timestamp = update.timestamp else { return }
        
        let attributedText = NSMutableAttributedString(string: fromName, attributes: [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 16), NSAttributedStringKey.foregroundColor: UIColor.white])
        
        attributedText.append(NSAttributedString(string: " \(text) ", attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 16), NSAttributedStringKey.foregroundColor: UIColor.white]))
        
        attributedText.append(NSAttributedString(string: teamname, attributes: [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 16), NSAttributedStringKey.foregroundColor: ColorCodes.clansportlerPurple]))
        
        self.typeLabel.text = "New Clan Member"
        self.titleLabel.attributedText = attributedText
        self.timestampLabel.text = timestamp.timeAgoDisplay()
    }
    
    private func setupAttributedTextForGroupInvitationUpdate(update: GroupInvitationUpdate) {
//        guard let update = self.update else { return }
        guard let text = update.text else { return }
        guard let fromName = update.fromName else { return }
        guard let timestamp = update.timestamp else { return }
        
        let attributedText = NSMutableAttributedString(string: fromName, attributes: [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 16), NSAttributedStringKey.foregroundColor: UIColor.white])
        
        attributedText.append(NSAttributedString(string: " \(text) ", attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 16), NSAttributedStringKey.foregroundColor: UIColor.white]))
        
        self.typeLabel.text = "Group Invitation"
        self.titleLabel.attributedText = attributedText
        self.timestampLabel.text = timestamp.timeAgoDisplay()
    }
    
    let imageView: CustomImageView = {
        let iv = CustomImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.borderColor = UIColor.white.cgColor
        iv.layer.borderWidth = 1
        return iv
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.numberOfLines = 2
        return label
    }()
    
    let typeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 12)
        label.textColor = UIColor.white
        return label
    }()
    
    let timestampLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = UIColor.white
        label.textAlignment = .right
        return label
    }()
    
    override func setupCell() {
        super.setupCell()
        
        backgroundColor = ColorCodes.clansportlerBlue
        
        self.layer.cornerRadius = 5
        self.clipsToBounds = true
        
        setupViews()
    }
    
    func setupViews() {
        addSubview(imageView)
        
        addSubview(timestampLabel)
        addSubview(typeLabel)
        addSubview(titleLabel)
        
        imageView.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: nil, paddingTop: 4, paddingLeft: 4, paddingBottom: 4, paddingRight: 0, width: 100, height: 0)
        imageView.layer.cornerRadius = 5
        
        timestampLabel.anchor(top: topAnchor, left: nil, bottom: nil, right: rightAnchor, paddingTop: 4, paddingLeft: 0, paddingBottom: 0, paddingRight: 4, width: 100, height: 20)
        
        typeLabel.anchor(top: topAnchor, left: imageView.rightAnchor, bottom: nil, right: timestampLabel.leftAnchor, paddingTop: 4, paddingLeft: 4, paddingBottom: 0, paddingRight: 0, width: 0, height: 20)
        
        titleLabel.anchor(top: timestampLabel.bottomAnchor, left: typeLabel.leftAnchor, bottom: bottomAnchor, right: timestampLabel.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 4, paddingRight: 0, width: 0, height: 0)
        
    }
    
}
