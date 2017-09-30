//
//  GroupLeavingUpdate.swift
//  Clansportler
//
//  Created by Luca Kiedrowski on 05.09.17.
//  Copyright © 2017 LucaKiedrowski. All rights reserved.
//

import Foundation
import Firebase

class GroupLeavingUpdate: Update {
    
    init(id: String, imageUrl: String, values: [String: Any]) {
        
        super.init(id: id, imageUrl: imageUrl)
        
        self.fromId = values["userId"] as? String ?? ""
        self.fromName = values["fromName"] as? String ?? ""
        
        self.groupId = values["groupId"] as? String ?? ""
        
        let secondsFrom1970 = values["timestamp"] as? Double ?? 0
        self.timestamp = Date(timeIntervalSince1970: secondsFrom1970)
        
        self.text = "left your group"
    }
    
    static func uploadGroupLeavingUpdateToDatabase(groupId: String, userId: String) {
        
        let updateId = UUID().uuidString
        let timestamp = Date().timeIntervalSince1970
        
        let updateValues: [String: Any] = ["timestamp": timestamp, "userId": userId, "groupId": groupId]
        
        let updateRef = Database.database().reference().child("updates").child(Update.leavingGroupDatabase).child(updateId)
        updateRef.updateChildValues(updateValues) { (err, _) in
            if let err = err {
                print("failed to upload leaving group Update", err)
            }
        }
        
        let userValues: [String: Any] = [updateId: 1]
        
        let userRef = Database.database().reference().child("users").child(userId).child("updates").child(Update.leavingGroupDatabase)
        userRef.updateChildValues(userValues) { (err, _) in
            if let err = err {
                print("failed to upload update to user Ref", err)
            }
        }
        
        let lastUpdateValues: [String: Any] = [Group.lastUpdateDatabase: timestamp]
        let groupRef = Database.database().reference().child("groups").child(Group.groupDataDB).child(groupId)
        groupRef.updateChildValues(lastUpdateValues) { (err, _) in
            if let err = err {
                print("failed to upload last update", err)
            }
        }
    }
    
}
