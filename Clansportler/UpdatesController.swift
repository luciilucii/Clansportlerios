//
//  UpdatesController.swift
//  Clansportler
//
//  Created by Luca Kiedrowski on 07.08.17.
//  Copyright © 2017 LucaKiedrowski. All rights reserved.
//

import UIKit
import Firebase

class UpdatesController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    var updates = [Update]()
    
    lazy var menu: Menu = {
        let menu = Menu()
        menu.startController = self
        return menu
    }()
    
    let cellId = "cellId"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCollectionView()
        
        fetchUpdates()
        
        navigationController?.navigationBar.tintColor = UIColor.white
        navigationController?.navigationBar.isTranslucent = false
        
        navigationItem.title = "Updates"
        let textAttributes = [NSAttributedStringKey.foregroundColor:UIColor.white]
        navigationController?.navigationBar.titleTextAttributes = textAttributes
//        self.navigationBar.tintColor = UIColor.white
    }
    
    func setupCollectionView() {
        collectionView?.register(UpdatesCell.self, forCellWithReuseIdentifier: cellId)
        collectionView?.backgroundColor = ColorCodes.backgroundGrey
        collectionView?.alwaysBounceVertical = true
    }
    
    func handleMenu() {
        menu.showMenu()
        menu.startController = self
    }
    
    func fetchUpdates() {
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
        let userUpdateRef = Database.database().reference().child("users").child(currentUserId).child("teamInvitations")
        userUpdateRef.observe(.value, with: { (snapshot) in
            
            guard let dictionaries = snapshot.value as? [String: Any] else { return }
            
            for dictionary in dictionaries {
                let updateId = dictionary.key
                self.fetchTeamInvitationUpdate(updateId: updateId)
            }
            
        }) { (err) in
            print("failed to fetch inquiries:", err)
        }
        
        let joinRequestRef = Database.database().reference().child("users").child(currentUserId).child("updates").child(Update.databaseTeamRequests)
        joinRequestRef.observeSingleEvent(of: .value, with: { (snapshot) in
            guard let dictionary = snapshot.value as? [String: Any] else { return }
            
            dictionary.forEach({ (key, value) in
                
                self.fetchTeamJoiningRequests(updateId: key, currentUserId: currentUserId)
                
            })
        }) { (err) in
            print("failed to fetch clan joining requests", err)
        }
        
        let joinedTeamRef = Database.database().reference().child("users").child(currentUserId).child("updates").child(Update.databaseJoinedTeam)
        joinedTeamRef.observeSingleEvent(of: .value, with: { (snapshot) in
            guard let dictionary = snapshot.value as? [String: Any] else { return }
            
            dictionary.forEach({ (key, value) in
                
                self.fetchJoinedTeamUpdate(updateId: key, currentUserId: currentUserId)
            })
            
        }) { (err) in
            print("failed to fetch joined Clan updates", err)
        }
        
        let groupInvitationsRef = Database.database().reference().child("users").child(currentUserId).child("updates").child(Update.groupInvitationDatabase)
        groupInvitationsRef.observeSingleEvent(of: .value, with: { (snapshot) in
            
            guard let dictionary = snapshot.value as? [String: Any] else { return }
            dictionary.forEach({ (key, value) in
                self.fetchGroupInvitationUpdate(updateId: key, currentUserId: currentUserId)
            })
            
        }) { (err) in
            print("failed to fetch group invitations", err)
        }
        
    }
    
    func fetchTeamInvitationUpdate(updateId: String) {
        
        let updateRef = Database.database().reference().child("updates").child("teamInvitation").child(updateId)
        updateRef.observeSingleEvent(of: .value, with: { (snapshot) in
            
            guard let dictionary = snapshot.value as? [String: Any] else { return }
            
            var valuesDictionary = dictionary
            
            guard let fromId = dictionary["fromId"] as? String else { return }
            guard let imageUrl = dictionary["imageUrl"] as? String else { return }
            
            let userRef = Database.database().reference().child("users").child(fromId)
            userRef.observeSingleEvent(of: .value, with: { (snapshot) in
                
                guard let userDictionary = snapshot.value as? [String: Any] else { return }
                guard let username = userDictionary["username"] as? String else { return }
                
                valuesDictionary["fromName"] = username
                
                let teamInvitationUpdate = TeamInvitationUpdate(id: updateId, imageUrl: imageUrl, values: valuesDictionary)
                
                self.updates.append(teamInvitationUpdate)
                self.updates.sort(by: { (update1, update2) -> Bool in
                    return update1.timestamp?.compare(update2.timestamp!) == .orderedDescending
                })
                self.collectionView?.reloadData()
                
                self.updateSeenStatus(id: updateId, databaseRefName: "teamInvitation")
                
            }, withCancel: { (error) in
                print("failed to fetch user:", error)
            })
            
        }) { (err) in
            print("failed to fetch teamInvitationUpdate: ", err)
        }        
    }
    
    func fetchTeamJoiningRequests(updateId: String, currentUserId: String) {
        
        let updateRef = Database.database().reference().child("updates").child(Update.databaseTeamRequests).child(updateId)
        updateRef.observeSingleEvent(of: .value, with: { (snapshot) in
            
            guard let dictionary = snapshot.value as? [String: Any] else { return }
            guard let imageUrl = dictionary["imageUrl"] as? String else { return }
            guard let fromId = dictionary["fromId"] as? String else { return }
            
            var valuesDictionary = dictionary
            
            let userRef = Database.database().reference().child("users").child(fromId)
            userRef.observeSingleEvent(of: .value, with: { (snapshot) in
                
                guard let userDictionary = snapshot.value as? [String: Any] else { return }
                guard let username = userDictionary["username"] as? String else { return }
                
                valuesDictionary["fromName"] = username
                
                let update = JoinTeamRequestUpdate(id: updateId, imageUrl: imageUrl, values: valuesDictionary)
                
                if update.fromId != currentUserId {
                    self.updates.append(update)
                    self.updates.sort(by: { (update1, update2) -> Bool in
                        return update1.timestamp?.compare(update2.timestamp!) == .orderedDescending
                    })
                    self.collectionView?.reloadData()
                }
                
                self.updateSeenStatus(id: updateId, databaseRefName: Update.databaseTeamRequests)
            }, withCancel: { (err) in
                print("failed to fetch user", err)
            })
            
        }) { (err) in
            print("failed to fetch joinTeamRequest", err)
        }
    }
    
    func fetchJoinedTeamUpdate(updateId: String, currentUserId: String) {
        
        let updateRef = Database.database().reference().child("updates").child(Update.databaseJoinedTeam).child(updateId)
        updateRef.observeSingleEvent(of: .value, with: { (snapshot) in
            
            guard let dictionary = snapshot.value as? [String: Any] else { return }
            guard let imageUrl = dictionary["imageUrl"] as? String else { return }
            guard let fromId = dictionary["fromId"] as? String else { return }
            
            var valuesDictionary = dictionary
            
            let userRef = Database.database().reference().child("users").child(fromId)
            userRef.observeSingleEvent(of: .value, with: { (snapshot) in
                
                guard let userDictionary = snapshot.value as? [String: Any] else { return }
                guard let username = userDictionary["username"] as? String else { return }
                
                if fromId == Auth.auth().currentUser?.uid {
                    valuesDictionary["fromName"] = "\(username) (You)"
                } else {
                    valuesDictionary["fromName"] = username
                }
                
                let update = JoinedTeamUpdate(id: updateId, imageUrl: imageUrl, values: valuesDictionary)
                
                self.updates.append(update)
                self.updates.sort(by: { (update1, update2) -> Bool in
                    return update1.timestamp?.compare(update2.timestamp!) == .orderedDescending
                })
                self.collectionView?.reloadData()
                
                self.updateSeenStatus(id: updateId, databaseRefName: Update.databaseJoinedTeam)
                
            }, withCancel: { (err) in
                print("failed to fetch user", err)
            })
            
            
        }) { (err) in
            print("failed to fetch joinedTeamUpdate", err)
        }
        
    }
    
    func fetchGroupInvitationUpdate(updateId: String, currentUserId: String) {
        
        let updateRef = Database.database().reference().child("updates").child(Update.groupInvitationDatabase).child(updateId)
        updateRef.observeSingleEvent(of: .value, with: { (snapshot) in
            
            guard let dictionary = snapshot.value as? [String: Any] else { return }
            guard let imageUrl = dictionary["imageUrl"] as? String else { return }
            guard let fromId = dictionary["fromId"] as? String else { return }
            
            var valuesDictionary = dictionary
            
            Database.fetchUserWithUID(uid: fromId, completion: { (fromUser) in
                
                valuesDictionary["fromName"] = fromUser.username
                let update = GroupInvitationUpdate(id: updateId, imageUrl: imageUrl, values: valuesDictionary)
                
                self.updates.append(update)
                self.updates.sort(by: { (update1, update2) -> Bool in
                    return update1.timestamp?.compare(update2.timestamp!) == .orderedDescending
                })
                self.collectionView?.reloadData()
                
                self.updateSeenStatus(id: updateId, databaseRefName: Update.groupInvitationDatabase)
            })
            
        }) { (err) in
            print("failed to fetch group invitation update", err)
        }
        
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return updates.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! UpdatesCell
        
        cell.update = updates[indexPath.item]
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let update = updates[indexPath.item]
        
        checkWhichUpdateType(update: update)
        
    }
    
    func checkWhichUpdateType(update: Update) {
        if update is TeamInvitationUpdate {
            // do something here
            
//            guard let teamname = realUpdate.teamname else { return }
            guard let teamId = update.teamId else { return }
            
            let teamGroupchatsRef = Database.database().reference().child("teams").child(teamId)
            teamGroupchatsRef.observeSingleEvent(of: .value, with: { (snapshot) in
                
                guard let dictionary = snapshot.value as? [String: Any] else { return }
                
                let team = Team(uid: teamId, values: dictionary)
                let teamController = TeamController()
                teamController.team = team
                teamController.teamInvitation = true
                
                self.show(teamController, sender: self)
                
            }, withCancel: { (err) in
                print("failed to fetch team", err)
            })
            
        } else if let realUpdate = update as? JoinTeamRequestUpdate {
            
            guard let userId = realUpdate.fromId else { return }
            
            Database.fetchUserWithUID(uid: userId, completion: { (user) in
                
                let userController = UserProfileController()
                userController.isJoiningRequest = true
                userController.user = user
                
                
                self.show(userController, sender: self)
            })
        } else if let realUpdate = update as? JoinedTeamUpdate {
            
            guard let userId = realUpdate.fromId else { return }
            
            Database.fetchUserWithUID(uid: userId, completion: { (user) in
                
                let userController = UserProfileController()
                userController.user = user
                
                self.show(userController, sender: self)
            })
        } else if let realUpdate = update as? GroupInvitationUpdate {
            
            guard let groupId = realUpdate.groupId else { return }
            
            
            
            Database.fetchAndObserveGroupWithId(id: groupId, completion: { (group) in
                
                guard let groupIsOpen = group.isOpen else { return }
                
                if groupIsOpen {
                    let openGroupController = OpenGroupController()
                    openGroupController.group = group
                    openGroupController.gameId = group.gameId
                    
                    let navController = UINavigationController(rootViewController: openGroupController)
                    self.present(navController, animated: true, completion: {
                        //completion here
                        openGroupController.showJoiningAlertController()
                    })
                } else {
                    self.showGroupIsClosedAlertController()
                }
            })
        }
    }
    
    func showGroupIsClosedAlertController() {
        let alertController = UIAlertController(title: "Group is closed", message: "The Group is closed already", preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: { (action) in
            alertController.dismiss(animated: true, completion: nil)
        }))
        self.present(alertController, animated: true, completion: nil)
    }
    
    func updateSeenStatus(id: String, databaseRefName: String) {
        let hasSeenValues: [String: Any] = ["hasSeen": true]
        
        let updateRef = Database.database().reference().child("updates").child(databaseRefName).child(id)
        updateRef.updateChildValues(hasSeenValues) { (err, _) in
            if let err = err {
                print("failed to update seen status", err)
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = view.frame.width - 16
        let height: CGFloat = 75
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    
}
