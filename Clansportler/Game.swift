//
//  Game.swift
//  Clansportler
//
//  Created by Luca Kiedrowski on 15.08.17.
//  Copyright © 2017 LucaKiedrowski. All rights reserved.
//

import Foundation
import Firebase

class Game {
    
    var id: String
    var name: String?
    var imageUrl: String?
    
    var playerIds: [String]?
    var playerCount: Int?
    
    static let gameNotification = NSNotification.Name("SelectedGames")
    
    init(id: String, dictionary: [String: Any]) {
        self.id = id
        
        self.name = dictionary["gamename"] as? String
        self.imageUrl = dictionary["imageUrl"] as? String
        
        if let playerDictionary = dictionary["player"] as? [String: Any] {
            
            self.playerIds = [String]()
            
            playerDictionary.forEach({ (key, value) in
                self.playerIds?.append(key)
            })
            self.playerCount = playerIds?.count ?? 0
            
        }
    }
}


