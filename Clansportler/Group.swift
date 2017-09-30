//
//  Group.swift
//  Clansportler
//
//  Created by Luca Kiedrowski on 01.09.17.
//  Copyright © 2017 LucaKiedrowski. All rights reserved.
//

import Foundation
import Firebase

class Group {
    
    static let maxGroupMemberDatabase = "maxGroupMember"
    static let currentGroupDatabase = "currentGroup"
    
    static let gameGroupsDatabase = "gameGroups"
    static let groupDataDB = "groupData"
    
    static let lastUpdateDatabase = "lastUpdate"
    
    static let updateGroupNotification = NSNotification.Name(rawValue: "UpdateGroup")
    
    var id: String
    
    var imageUrl: String?
    var gameId: String
    
    var description: String?
    
    var memberIds: [String]?
    var adminId: String?
    
    var groupchatId: String?
    var maxGroupMember: Int
    var currentGroupMemberCount: Int?
    
    var createdAt: Date?
    var closedAt: Date?
    var lastUpdate: Date
    
    var isOpen: Bool?
    var wildcardCount: Int
    
    init(id: String, values: [String: Any]) {
        
        self.id = id
        
        self.gameId = values["gameId"] as? String ?? ""
        self.wildcardCount = values["wildcardCount"] as? Int ?? 0
        self.maxGroupMember = values["maxGroupMember"] as? Int ?? 1
        
        self.imageUrl = values["imageUrl"] as? String ?? ""
        
        self.description = values["description"] as? String ?? ""
        
        let secondsFrom1970Update = values[Group.lastUpdateDatabase] as? Double ?? 0
        self.lastUpdate = Date(timeIntervalSince1970: secondsFrom1970Update)
        
        if let memberDictionary = values["memberIds"] as? [String: Any] {
            
            memberIds = [String]()
            
            memberDictionary.forEach({ (key, value) in
                memberIds?.append(key)
            })
            
            let unwrappedWildcardCount = self.wildcardCount
            self.currentGroupMemberCount = memberDictionary.keys.count + unwrappedWildcardCount
            
        }
        self.adminId = values["adminId"] as? String ?? ""
        
        self.groupchatId = values["groupchat"] as? String 
        
        let secondsFrom1970 = values["createdAt"] as? Double ?? 0
        self.createdAt = Date(timeIntervalSince1970: secondsFrom1970)
        
        let secondsFrom1970Close = values["closedAt"] as? Double ?? 0
        self.closedAt = Date(timeIntervalSince1970: secondsFrom1970Close)
        
        self.isOpen = values["isOpen"] as? Bool ?? false
        
    }
    
    static func closeGroup(group: Group) {
        let isOpenValues: [String: Any] = ["isOpen": false]
        let groupRef = Database.database().reference().child("groups").child(Group.groupDataDB).child(group.id)
        groupRef.updateChildValues(isOpenValues, withCompletionBlock: { (err, _) in
            if let err = err {
                print("failed to close group", err)
            }
        })
        
        let gameId = group.gameId
        
        let gameRef = Database.database().reference().child("groups").child(Group.gameGroupsDatabase).child(gameId).child(group.id)
        gameRef.removeValue(completionBlock: { (err, _) in
            if let err = err {
                print("failed to remove from open Groups", err)
            }
        })
    }
    
}
