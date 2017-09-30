//
//  Update.swift
//  Clansportler
//
//  Created by Luca Kiedrowski on 07.08.17.
//  Copyright © 2017 LucaKiedrowski. All rights reserved.
//

import Foundation

class Update {
    
    static let databaseTeamRequests = "joinTeamRequests"
    static let databaseJoinedTeam = "joinedTeam"
    
    static let joiningGroupDatabase = "groupJoiningUpdate"
    static let groupInvitationDatabase = "groupInvitationUpdate"
    static let leavingGroupDatabase = "groupLeavingUpdate"
    
    var id: String
    var imageUrl: String?
    
    var text: String?
    var timestamp: Date?
    
    var fromId: String?
    var fromName: String?
    
    var teamId: String?
    var teamname: String?
    
    var groupId: String?
    
    init(id: String, imageUrl: String?) {
        self.imageUrl = imageUrl
        self.id = id
        
    }
    
}




