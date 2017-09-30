//
//  TeamGames.swift
//  Clansportler
//
//  Created by Luca Kiedrowski on 19.08.17.
//  Copyright © 2017 LucaKiedrowski. All rights reserved.
//

import Foundation

class TeamGame {
    var playerCount: Int
    var id: String
    
    init(id: String, playerCount: Int) {
        
        self.id = id
        self.playerCount = playerCount
        
    }
}
