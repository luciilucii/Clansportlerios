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
    case teams
    case player
}

class Tournament {
    
    var id: String
    var shortName: String
    var fullName: String
    
    var gameId: String?
    var teamSize: Int?
    
    var playerType: TournamentPlayerType?
    
    var tournamentImageUrl: String?
    
    init(id: String, values: [String: Any]) {
        self.id = id
        self.shortName = values["shortName"] as? String ?? ""
        self.fullName = values["fullName"] as? String ?? ""
        
        self.gameId = values["gameId"] as? String
        
        self.tournamentImageUrl = values["tournamentImageUrl"] as? String
        
        self.playerType = values["playerType"] as? TournamentPlayerType
        if let teamSize = values["teamSize"] as? Int {
            self.teamSize = teamSize
            if teamSize > 1 {
                self.playerType = .teams
            } else {
                self.playerType = .player
            }
        }
    }
    
}











