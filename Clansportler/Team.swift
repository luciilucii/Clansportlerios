//
//  Team.swift
//  Clansportler
//
//  Created by Luca Kiedrowski on 06.08.17.
//  Copyright © 2017 LucaKiedrowski. All rights reserved.
//

import Foundation

class Team {
    
    var id: String
    var teamname: String
    var profileImageUrl: String
    
    var member: [String]?
//    var teamImageUrl: [String]?
    
    var groupchats: [String]?
    
    var adminId: String?
    
    init(uid: String, values: [String: Any]) {
        
        self.id = uid
        self.teamname = values["teamname"] as? String ?? ""
        self.profileImageUrl = values["profileImageUrl"] as? String ?? ""
        self.adminId = values["adminId"] as? String
        
        if let groupDictionary = values["groupchats"] as? [String: Any] {
            
            groupchats = [String]()
            groupDictionary.forEach({ (key, value) in
                groupchats?.append(key)
            })
        }
        
        if let memberDictionary = values["member"] as? [String: Any] {
            
            member = [String]()
            memberDictionary.forEach({ (key, value) in
                member?.append(key)
            })
            
        }
        
    }
    
}
