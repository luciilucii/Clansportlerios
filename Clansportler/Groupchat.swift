//
//  Group.swift
//  Clansportler
//
//  Created by Luca Kiedrowski on 31.07.17.
//  Copyright © 2017 LucaKiedrowski. All rights reserved.
//

import UIKit

class Groupchat: NSObject {
    var id: String
    var name: String?
    var users: [User]?
    var userIds: [String]?
    
    init(id: String, dictionary: [String: Any]) {
        
        self.id = id
        
        self.name = dictionary["name"] as? String ?? ""
        self.userIds = dictionary["users"] as? [String]
        
    }
}
