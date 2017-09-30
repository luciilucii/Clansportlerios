//
//  SuggestedClan.swift
//  Clansportler
//
//  Created by Luca Kiedrowski on 13.09.17.
//  Copyright © 2017 LucaKiedrowski. All rights reserved.
//

import Foundation
import Firebase

class SuggestedClan: NSObject {
    
    var clan: Team
    var clanGameDictionary: [String: Int]? = [String: Int]() {
        didSet {
            sortingTimer?.invalidate()
            sortingTimer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(sortClanGameCount), userInfo: nil, repeats: false)
        }
    }
    var clanMemberCount: Int?
    var clanImageUrl: String?
    
    var rank: Double?
    
    var sortingTimer: Timer?
    var rankTimer: Timer?
    
    var currentUserGameIds: [String]?
    
    var memberIds: [String]? {
        didSet {
            guard let unwrappedMemberIds = memberIds else { return }
            self.fetchMemberGames(memberIds: unwrappedMemberIds)
        }
    }
    
    var biggestGameId: String? {
        didSet {
            guard let gameId = biggestGameId else { return }
            
            Database.fetchGameWithId(id: gameId) { (fetchedGame) in
                self.biggestGame = fetchedGame
            }
        }
    }
    
    var biggestGameCount: Int?
    var biggestGame: Game? {
        didSet {
            if let clanCell = self.suggestedClanCell {
                guard let bigGame = biggestGame else { return }
                setupCell(cell: clanCell, game: bigGame)
            }
        }
    }
    
    var suggestedClanCell: SuggestedTeamCell? {
        didSet {
            guard let clanCell = suggestedClanCell else { return }
            if let bigGame = self.biggestGame {
                setupCell(cell: clanCell, game: bigGame)
            }
        }
    }
    
    func setupCell(cell: SuggestedTeamCell, game: Game) {
        
        guard let biggestGameCount = self.biggestGameCount else { return }
        guard let memberCount = self.clanMemberCount else { return }
        
        let percentCount = biggestGameCount * 100 / memberCount
        guard let gameName = game.name else { return }
        
        cell.gamesLabel.text = "\(percentCount)% of members play \(gameName)"
    }
    
    
    init(clan: Team, currentUser: User) {
        
        self.clan = clan
        super.init()
        self.clanGameDictionary = [String: Int]()
        self.currentUserGameIds = currentUser.gameIds
        
        let memberIds = clan.member
        
        self.setOtherValues(memberIds: memberIds, clanMemberCount: memberIds?.count)
    }
    
    func setOtherValues(memberIds: [String]?, clanMemberCount: Int?) {
        self.memberIds = memberIds
        self.clanMemberCount = clanMemberCount
    }
    
    func fetchMemberGames(memberIds: [String]) {
        memberIds.forEach({ (memberId) in
            Database.fetchUserWithUID(uid: memberId, completion: { (fetchedUser) in
                guard let gameIds = fetchedUser.gameIds else { return }
                
                for gameId in gameIds {
                    if let gameCount = self.clanGameDictionary?[gameId] {
                        self.clanGameDictionary?[gameId] = gameCount + 1
                        
                    } else {
                        self.clanGameDictionary?[gameId] = 1
                    }
                }
            })
        })
    }
    
    @objc func sortClanGameCount() {
        var biggestGameId = ""
        var biggestValue = 0
        
        self.clanGameDictionary?.forEach({ (key, value) in
            if value > biggestValue {
                biggestValue = value
                
                biggestGameId = key
            }
        })
        
        self.biggestGameCount = biggestValue
        self.biggestGameId = biggestGameId
        
    }
    
}















