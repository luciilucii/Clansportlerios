//
//  Tournament.swift
//  Clansportler
//
//  Created by Luca Kiedrowski on 29.09.17.
//  Copyright © 2017 LucaKiedrowski. All rights reserved.
//

import UIKit
import Firebase

enum TournamentPlayerType {
    case clans
    case players
}

class Tournament {
    
    var id: String
    var shortName: String
    var fullName: String
    
    var gameId: String?
    
    var playerType: TournamentPlayerType?
    
    init(id: String, values: [String: Any]) {
        self.id = id
        self.shortName = values["shortName"] as? String ?? ""
        self.fullName = values["fullName"] as? String ?? ""
        
        self.gameId = values["gameId"] as? String
        
        self.playerType = values["playerType"] as? TournamentPlayerType
    }
    
}
