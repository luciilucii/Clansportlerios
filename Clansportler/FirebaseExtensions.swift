//
//  FirebaseExtensions.swift
//  Clansportler
//
//  Created by Luca Kiedrowski on 06.08.17.
//  Copyright © 2017 LucaKiedrowski. All rights reserved.
//

import UIKit
import Firebase

var userTeamId: String?

extension Database {
    
    func checkForTeamId(userId: String) -> String? {
        
        let userRef = Database.database().reference().child("users").child(userId)
        userRef.observeSingleEvent(of: .value, with: { (snapshot) in
            
            guard let dictionary = snapshot.value as? [String: Any] else { return }
            guard let teamId = dictionary["team"] as? String else { return }
            
            userTeamId = teamId
            
        }) { (err) in
            print("failed to fetch user: ", err)
        }
        
        if userTeamId != nil {
            return userTeamId
        } else {
            return nil
        }
        
    }
    
}

var clanCache = [String: Team]()
var userCache = [String: User]()
var gameCache = [String: Game]()

extension Database {
    static func fetchUserWithUID(uid: String, completion: @escaping (User) -> ()) {
        
        if let user = userCache[uid] {
            completion(user)
            return
        }
        Database.database().reference().child("users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            guard let userDictionary = snapshot.value as? [String: Any] else { return }
            
            let user = User(uid: uid, dictionary: userDictionary)
            userCache[uid] = user
            
            completion(user)
            
        }) { (err) in
            print("failed to fetch user for posts: ", err)
        }
    }
    
    static func fetchTeamWithId(uid: String, completion: @escaping (Team) -> ()) {
        if let clan = clanCache[uid] {
            completion(clan)
            return
        }
        Database.database().reference().child("teams").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            
            guard let values = snapshot.value as? [String: Any] else { return }
            
            let team = Team(uid: uid, values: values)
            clanCache[uid] = team
            
            completion(team)
            
        }) { (err) in
            print("failed to fetch team", err)
        }
        
    }
    
    static func fetchGameWithId(id: String, completion: @escaping (Game) -> ()) {
        if let game = gameCache[id] {
            completion(game)
            return
        }
        Database.database().reference().child("games").child(id).observeSingleEvent(of: .value, with: { (snapshot) in
            
            guard let values = snapshot.value as? [String: Any] else { return }
            
            let game = Game(id: id, dictionary: values)
            gameCache[id] = game
            
            completion(game)
            
        }) { (err) in
            print("failed to fetch game", err)
        }
        
    }
    
    static func fetchAndObserveGroupWithId(id: String, completion: @escaping (Group) -> ()) {
        let timestamp = Date().timeIntervalSince1970
        
        let groupRef = Database.database().reference().child("groups").child(Group.groupDataDB).child(id)
        groupRef.observe(.value, with: { (snapshot) in
            
            guard let dictionary = snapshot.value as? [String: Any] else { return }
            let group = Group(id: id, values: dictionary)
            
            let groupLastUpdate = group.lastUpdate.timeIntervalSince1970
            let timeSinceLastUpdate = Int(timestamp) - Int(groupLastUpdate)
            
            if group.memberIds?.count == 0 || timeSinceLastUpdate > 36000 {
                Group.closeGroup(group: group)
            }
            
            completion(group)
            
        }) { (err) in
            print("failed to fetch and observe Group", err)
        }
    }
    
    static func fetchGroupchat(withId: String, completion: @escaping (Groupchat) -> ()) {
        
        let groupchatRef = Database.database().reference().child("groupchats").child(withId)
        groupchatRef.observeSingleEvent(of: .value, with: { (snapshot) in
            guard let dictionary = snapshot.value as? [String: Any] else { return }
            
            let groupchat = Groupchat(id: withId, dictionary: dictionary)
            
            completion(groupchat)
            
        }) { (err) in
            print("failed to fetch groupchat")
        }
        
    }
    
    static func uploadUserGroupChats(currentUserId: String, groupchatId: String) {
        
        let groupValues: [String: Any] = [currentUserId: 1]
        
        let groupRef = Database.database().reference().child("groupchats").child(groupchatId).child("users")
        groupRef.updateChildValues(groupValues) { (err, _) in
            if let err = err {
                print("failed to post user into group db:", err)
            }
        }
        
        let userValues: [String: Any] = [groupchatId: 1]
        let userGroupsRef = Database.database().reference().child("users").child(currentUserId).child("groupchats")
        userGroupsRef.updateChildValues(userValues) { (err, _) in
            if let err = err {
                print("failed to post group into user db:", err)
            }
        }
        
    }
    
}











