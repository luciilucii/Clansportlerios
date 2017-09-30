//
//  Updater.swift
//  Clansportler
//
//  Created by Luca Kiedrowski on 26.08.17.
//  Copyright © 2017 LucaKiedrowski. All rights reserved.
//

import UIKit
import Firebase

class Updater: NSObject {
    
    var backgroundView = UIView()
    
    override init() {
        super.init()
        
        fetchNewUpdates()
    }
    
    var timer: Timer?
    
    var updatesCount = 0 {
        didSet {
            timer?.invalidate()
            timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(showUpdater), userInfo: nil, repeats: false)
        }
    }
    
    func fetchNewUpdates() {
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
        let teamInvitationsRef = Database.database().reference().child("users").child(currentUserId).child("teamInvitations")
        teamInvitationsRef.observeSingleEvent(of: .value, with: { (snapshot) in
            
            guard let teamInvitesDictionary = snapshot.value as? [String: Any] else { return }
            
            teamInvitesDictionary.forEach({ (key, value) in
                
                let updateRef = Database.database().reference().child("updates").child("teamInvitation").child(key)
                updateRef.observeSingleEvent(of: .value, with: { (snapshot) in
                    guard let dictionary = snapshot.value as? [String: Any] else { return }
                    guard let hasSeenStatus = dictionary["hasSeen"] as? Bool else { return }
                    
                    if !hasSeenStatus {
                        self.updatesCount += 1
                    }
                }, withCancel: { (err) in
                    print("failed to fetch Team Invitation Update", err)
                })
            })
        }) { (err) in
            print("failed to fetch teamInvitations", err)
        }
        
        let joinedTeamRef = Database.database().reference().child("users").child(currentUserId).child("updates").child(Update.databaseJoinedTeam)
        joinedTeamRef.observeSingleEvent(of: .value, with: { (snapshot) in
            guard let dictionary = snapshot.value as? [String: Any] else { return }
            
            dictionary.forEach({ (key, value) in
                
                let updateRef = Database.database().reference().child("updates").child(Update.databaseJoinedTeam).child(key)
                updateRef.observeSingleEvent(of: .value, with: { (snapshot) in
                    
                    guard let updateDictionary = snapshot.value as? [String: Any] else { return }
                    guard let hasSeenStatus = updateDictionary["hasSeen"] as? Bool else { return }
                    if !hasSeenStatus {
                        self.updatesCount += 1
                    }
                    
                }, withCancel: { (err) in
                    print("failed to fetch joined Team Update", err)
                })
            })
        }) { (err) in
            print("failed to fetch joined Team Updates", err)
        }
        
        let joinTeamRequestsRef = Database.database().reference().child("users").child(currentUserId).child("updates").child(Update.databaseTeamRequests)
        joinTeamRequestsRef.observeSingleEvent(of: .value, with: { (snapshot) in
            
            guard let dictionary = snapshot.value as? [String: Any] else { return }
            dictionary.forEach({ (key, value) in
                let updateRef = Database.database().reference().child("updates").child(Update.databaseTeamRequests).child(key)
                updateRef.observeSingleEvent(of: .value, with: { (snapshot) in
                    
                    guard let updateDictionary = snapshot.value as? [String: Any] else { return }
                    
                    guard let hasSeenStatus = updateDictionary["hasSeen"] as? Bool else { return }
                    
                    if !hasSeenStatus {
                        self.updatesCount += 1
                    }
                }, withCancel: { (err) in
                    print("failed to fetch join Team Requests update", err)
                })
            })
        }) { (err) in
            print("failed to fetch join Team Requests updates", err)
        }
        
    }
    
    @objc func showUpdater() {
        
        if let keyWindow = UIApplication.shared.keyWindow {
            
            backgroundView.backgroundColor = UIColor.clear
            backgroundView.alpha = 0
            keyWindow.addSubview(backgroundView)
            
            let paddingCenterX: CGFloat = keyWindow.frame.width / 5 * 3.5
            
            backgroundView.anchor(top: nil, left: nil, bottom: keyWindow.bottomAnchor, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 50, paddingRight: 0, width: 45, height: 55)
            backgroundView.centerXAnchor.constraint(equalTo: keyWindow.leftAnchor, constant: paddingCenterX).isActive = true
            
            self.setupViews()
            
            badgeLabel.text = "\(updatesCount)"
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: { 
                
                self.backgroundView.alpha = 1
                
            }, completion: { (completed) in
                //completion here
                
                _ = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(self.closeUpdater), userInfo: nil, repeats: false)
            })
        }
    }
    
    @objc func closeUpdater() {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: { 
            
            self.backgroundView.alpha = 0
            
        }) { (completed) in
            //completion here
        }
    }
    
    let purpleView: UIView = {
        let view = UIView()
        view.backgroundColor = ColorCodes.clansportlerRed
        view.layer.cornerRadius = 4
        return view
    }()
    
    let triangleImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleToFill
        iv.image = #imageLiteral(resourceName: "triangle_down").withRenderingMode(.alwaysTemplate)
        iv.tintColor = ColorCodes.clansportlerRed
        iv.clipsToBounds = true
        return iv
    }()
    
    let badgeLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = UIColor.white
        label.font = UIFont.boldSystemFont(ofSize: 22)
        return label
    }()
    
    func setupViews() {
        
        backgroundView.addSubview(purpleView)
        backgroundView.addSubview(triangleImageView)
        
        purpleView.addSubview(badgeLabel)
        
        purpleView.anchor(top: backgroundView.topAnchor, left: backgroundView.leftAnchor, bottom: backgroundView.bottomAnchor, right: backgroundView.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 8, paddingRight: 0, width: 0, height: 0)
        triangleImageView.anchor(top: nil, left: backgroundView.leftAnchor, bottom: backgroundView.bottomAnchor, right: backgroundView.rightAnchor, paddingTop: 0, paddingLeft: 12, paddingBottom: 0, paddingRight: 12, width: 0, height: 10)
        
        badgeLabel.anchor(top: purpleView.topAnchor, left: purpleView.leftAnchor, bottom: purpleView.bottomAnchor, right: purpleView.rightAnchor, paddingTop: 0, paddingLeft: 2, paddingBottom: 0, paddingRight: 2, width: 0, height: 0)
        
    }
    
}












