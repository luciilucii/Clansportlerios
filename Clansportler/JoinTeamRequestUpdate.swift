//
//  JoinTeamRequestUpdate.swift
//  Clansportler
//
//  Created by Luca Kiedrowski on 25.08.17.
//  Copyright © 2017 LucaKiedrowski. All rights reserved.
//

import Foundation

class JoinTeamRequestUpdate: Update {
    
    init(id: String, imageUrl: String, values: [String: Any]) {
        super.init(id: id, imageUrl: imageUrl)
        
        self.fromId = values["fromId"] as? String ?? ""
        self.fromName = values["fromName"] as? String ?? ""
        
        self.teamId = values["teamId"] as? String ?? ""
        self.teamname = values["teamname"] as? String ?? ""
        
        let secondsFrom1970 = values["timestamp"] as? Double ?? 0
        self.timestamp = Date(timeIntervalSince1970: secondsFrom1970)
        
        self.text = "wants to join"
        
    }
    
}
