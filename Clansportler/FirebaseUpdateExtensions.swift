//
//  FirebaseUpdateExtensions.swift
//  Clansportler
//
//  Created by Luca Kiedrowski on 03.09.17.
//  Copyright © 2017 LucaKiedrowski. All rights reserved.
//

import UIKit
import Firebase

extension Database {
    
    static func sendGroupInvitation(groupId: String, toId: String, game: Game) {
        
        let updateId = UUID().uuidString
        
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
        let timestamp = Date().timeIntervalSince1970
        
        guard let imageUrl = game.imageUrl else { return }
        
        let values: [String: Any] = ["toId": toId, "fromId": currentUserId, "timestamp": timestamp, "hasSeen": false, "imageUrl": imageUrl, "groupId": groupId]
        
        let updateRef = Database.database().reference().child("updates").child(Update.groupInvitationDatabase).child(updateId)
        updateRef.updateChildValues(values) { (err, _) in
            if let err = err {
                print("Failed to upload Group Invitation", err)
            }
        }
        Database.sendUpdateIdToUser(toId: toId, updateId: updateId)
        Database.sendUpdateToGroupRef(groupId: groupId, updateId: updateId)
    }
    
    static func sendUpdateIdToUser(toId: String, updateId: String) {
        
        let values: [String: Any] = [updateId: 1]
        
        let userRef = Database.database().reference().child("users").child(toId).child("updates").child(Update.groupInvitationDatabase)
        userRef.updateChildValues(values) { (err, _) in
            if let err = err {
                print("failed to upload update to user Ref", err)
            }
        }
    }
    
    static func sendUpdateToGroupRef(groupId: String, updateId: String) {
        let values: [String: Any] = [updateId: 1]
        
        let groupRef = Database.database().reference().child("groups").child(Group.groupDataDB).child(groupId).child("updates").child(Update.groupInvitationDatabase)
        groupRef.updateChildValues(values) { (err, _) in
            if let err = err {
                print("failed to upload update to group Ref", err)
            }
        }
    }
    
}
