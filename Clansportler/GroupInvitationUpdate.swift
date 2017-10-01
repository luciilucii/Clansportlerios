//
//  GroupInvitationUpdate.swift
//  Clansportler
//
//  Created by Luca Kiedrowski on 02.09.17.
//  Copyright © 2017 LucaKiedrowski. All rights reserved.
//

import Foundation

class GroupInvitationUpdate: Update {
    
    init(id: String, imageUrl: String, values: [String: Any]) {
        
        super.init(id: id, imageUrl: imageUrl)
        
        self.fromId = values["fromId"] as? String ?? ""
        self.fromName = values["fromName"] as? String ?? ""
        
        self.groupId = values["groupId"] as? String ?? ""
        
        let secondsFrom1970 = values["timestamp"] as? Double ?? 0
        self.timestamp = Date(timeIntervalSince1970: secondsFrom1970)
        
        self.text = "wants you to join his group"
    }
    
}


