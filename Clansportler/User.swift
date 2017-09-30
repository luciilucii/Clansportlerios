//
//  User.swift
//  Clansportler
//
//  Created by Luca Kiedrowski on 30.07.17.
//  Copyright © 2017 LucaKiedrowski. All rights reserved.
//

import Foundation

class User {
    static let authenticationsDatabase = "authentications"
    
    var id: String
    var username: String
    var email: String
    var profileImageUrl: String
    
    var team: String?
    var hasChoosenGames: Bool?
    
    var groupchats: [String]?
    
    var gameIds: [String]?
    var isOnline: Bool?
    
    var authentications: [String: String]?
    
    init(uid: String, dictionary: [String: Any]) {
        
        self.id = uid
        self.username = dictionary["username"] as? String ?? ""
        self.email = dictionary["email"] as? String ?? ""
        self.profileImageUrl = dictionary["profileImageUrl"] as? String ?? ""
        
        self.team = dictionary["team"] as? String
        
        self.hasChoosenGames = dictionary["hasChoosenGames"] as? Bool
        self.isOnline = dictionary ["isOnline"] as? Bool
        
        if let gameDictionary = dictionary["games"] as? [String: Any] {
            gameIds = [String]()
            gameDictionary.forEach({ (key, value) in
                gameIds?.append(key)
            })
        }
        if let authenticationDictionary = dictionary["authentications"] as? [String: String] {
            self.authentications = authenticationDictionary
        }
        if let groupDictionary = dictionary["groupchats"] as? [String: Any] {
            groupchats = [String]()
            groupDictionary.forEach({ (key, value) in
                groupchats?.append(key)
            })
        }
    }
    
}
