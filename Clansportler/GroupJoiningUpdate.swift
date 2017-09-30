//
//  GroupJoiningUpdate.swift
//  Clansportler
//
//  Created by Luca Kiedrowski on 03.09.17.
//  Copyright © 2017 LucaKiedrowski. All rights reserved.
//

import Foundation
import Firebase

class GroupJoiningUpdate: Update {
    
    init(id: String, imageUrl: String?, values: [String: Any]) {
        
        super.init(id: id, imageUrl: imageUrl)
        
        self.fromId = values["userId"] as? String ?? ""
        self.fromName = values["fromName"] as? String ?? ""
        
        self.groupId = values["groupId"] as? String ?? ""
        
        let secondsFrom1970 = values["timestamp"] as? Double ?? 0
        self.timestamp = Date(timeIntervalSince1970: secondsFrom1970)
        
        self.text = "has joined your group"
    }
    
    static func fetchJoiningUpdate(updateId: String, completion: @escaping (GroupJoiningUpdate) -> ()) {
        
        let updateRef = Database.database().reference().child("updates").child(Update.joiningGroupDatabase).child(updateId)
        updateRef.observeSingleEvent(of: .value, with: { (snapshot) in
            
            guard let dictionary = snapshot.value as? [String: Any] else { return }
            let update = GroupJoiningUpdate(id: updateId, imageUrl: nil, values: dictionary)
            
            completion(update)
            
        }) { (err) in
            print("failed to fetch joining update", err)
        }
        
    }
    
    static func uploadGroupJoiningUpdate(groupId: String, userId: String) {
        let updateId = UUID().uuidString
        let timestamp = Date().timeIntervalSince1970
        
        let values: [String: Any] = ["timestamp": timestamp, "groupId": groupId, "userId": userId]
        
        let updateRef = Database.database().reference().child("updates").child(Update.joiningGroupDatabase).child(updateId)
        updateRef.updateChildValues(values) { (err, _) in
            if let err = err {
                print("Failed to upload Group Joining Update", err)
            }
        }
        let userValues: [String: Any] = [updateId: 1]
        
        let userRef = Database.database().reference().child("users").child(userId).child("updates").child(Update.joiningGroupDatabase)
        userRef.updateChildValues(userValues) { (err, _) in
            if let err = err {
                print("failed to upload Group Joining Update to user Ref", err)
            }
        }
        let groupUpdateRef = Database.database().reference().child("groups").child(Group.groupDataDB).child(groupId).child("updates").child(Update.joiningGroupDatabase)
        groupUpdateRef.updateChildValues(userValues) { (err, _) in
            if let err = err {
                print("failed to uplaod update to group Ref", err)
            }
        }
        
        
        let updateValues: [String: Any] = [Group.lastUpdateDatabase: timestamp]
        let groupRef = Database.database().reference().child("groups").child(Group.groupDataDB).child(groupId)
        groupRef.updateChildValues(updateValues) { (err, _) in
            if let err = err {
                print("failed to update last update", err)
            }
        }
    }
}









