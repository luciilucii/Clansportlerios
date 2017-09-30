//
//  AlgorithmHelper.swift
//  Clansportler
//
//  Created by Luca Kiedrowski on 19.08.17.
//  Copyright © 2017 LucaKiedrowski. All rights reserved.
//

import UIKit
import Firebase

class AlgorithmHelper: NSObject {
    
    static func fetchTeamGames(team: Team) -> [String: Int] {
        
        var gameDictionary = [String: Int]()
        
        guard let member = team.member else {
            return [String: Int]()
        }
        
        for userId in member {
            
            let userRef = Database.database().reference().child("user").child(userId)
            userRef.observeSingleEvent(of: .value, with: { (snapshot) in
                
                guard let values = snapshot.value as? [String: Any] else { return }
                let user = User(uid: userId, dictionary: values)
                
                guard let userGameIds = user.gameIds else { return }
                
                for gameId in userGameIds {
                    if let gameCount = gameDictionary[gameId] {
                        gameDictionary[gameId] = gameCount + 1
                    } else {
                        gameDictionary[gameId] = 1
                    }
                }
                
                
            }, withCancel: { (err) in
                print("failed to fetch user", err)
            })
            
        }
        
        return gameDictionary
        
    }
    
}
