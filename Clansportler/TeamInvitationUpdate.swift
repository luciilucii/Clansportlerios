//
//  TeamInvitationUpdate.swift
//  Clansportler
//
//  Created by Luca Kiedrowski on 25.08.17.
//  Copyright © 2017 LucaKiedrowski. All rights reserved.
//

import Foundation
import Firebase

class TeamInvitationUpdate: Update {
    
    init(id: String, imageUrl: String, values: [String: Any]) {
        
        super.init(id: id, imageUrl: imageUrl)
        
        
        self.fromId = values["fromId"] as? String ?? ""
        self.fromName = values["fromName"] as? String ?? ""
        
        self.teamId = values["teamId"] as? String ?? ""
        self.teamname = values["teamname"] as? String ?? ""
        
        let secondsFrom1970 = values["timestamp"] as? Double ?? 0
        self.timestamp = Date(timeIntervalSince1970: secondsFrom1970)
        
        self.text = "has invited you to join"
    }
    
    static func sendClanInvitationUpdate(toUserId: String, clanId: String) {

        let updateId = UUID().uuidString
        let userRef = Database.database().reference().child("users").child(toUserId).child("teamInvitations")
        let userValues: [String: Any] = [updateId: 1]
        
        userRef.updateChildValues(userValues) { (err, _) in
            if let err = err {
                print("failed to send teamInvitationUpdate to user ref", err)
            }
        }
        
        let timestamp = Date().timeIntervalSince1970
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
        
        Database.fetchTeamWithId(uid: clanId) { (clan) in
            let values: [String: Any] = ["toId": toUserId, "teamId": clanId, "timestamp": timestamp, "fromId": currentUserId, "hasSeen": false, "teamname": clan.teamname, "imageUrl": clan.profileImageUrl]
            
            let updateRef = Database.database().reference().child("updates").child("teamInvitation").child(updateId)
            updateRef.updateChildValues(values, withCompletionBlock: { (err, _) in
                if let err = err {
                    print("failed to update team Invitation update", err)
                }
            })
        }
    }
    
}


