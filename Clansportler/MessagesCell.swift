//
//  MessagesCell.swift
//  Clansportler
//
//  Created by Luca Kiedrowski on 31.07.17.
//  Copyright © 2017 LucaKiedrowski. All rights reserved.
//

import UIKit
import Firebase

class MessagesCell: BaseCell, UITableViewDelegate, UITableViewDataSource {
    
    static let resetBadgesNotification = Notification.Name("resetBadgesNotification")
    
    var user: User? {
        didSet {
            guard let user = user else { return }
            fetchUserGroupchats(user: user)
            
            fetchUserChats(user: user)
            fetchNewMessageIds(user: user)
        }
    }
    
    var menu: Menu? {
        didSet {
            guard let user = self.user else { return }
            
        }
    }
    
    var groupchatsIds = [String]()
    var groupchats = [Groupchat]()
    
    var userchats = [User]()
    
    var badgeDictionary = [String: Int]() {
        didSet {
            self.setupBadges()
        }
    }
    
    lazy var tableView: UITableView = {
        let tv = UITableView(frame: .zero)
        tv.delegate = self
        tv.dataSource = self
        tv.alwaysBounceVertical = false
        tv.backgroundColor = ColorCodes.darkestGrey
        return tv
    }()
    
    let cellId = "cellId"
    let headerId = "headerId"
    
    override func setupCell() {
        super.setupCell()
        
        addSubview(tableView)
        tableView.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        
        setupTableView()
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleUpdateBadges), name: MessagesCell.resetBadgesNotification, object: nil)
        
    }
    
    @objc func handleUpdateBadges() {
//        badgeDictionary.removeAll()
        guard let user = user else { return }
        fetchNewMessageIds(user: user)
    }
    
    func setupTableView() {
        tableView.register(MessageCell.self, forCellReuseIdentifier: cellId)
        tableView.register(MessageHeader.self, forHeaderFooterViewReuseIdentifier: headerId)
        
        tableView.separatorStyle = .none
    }
    
    func fetchUserGroupchats(user: User) {
        
        if let userTeam = user.team {
            
            let teamGroupchatRef = Database.database().reference().child("teams").child(userTeam).child("groupchats")
            teamGroupchatRef.observeSingleEvent(of: .value, with: { (snapshot) in
                
                guard let dictionary = snapshot.value as? [String: Any] else { return }
                dictionary.forEach({ (key, value) in
                    
                    let groupchatRef = Database.database().reference().child("groupchats").child(key)
                    groupchatRef.observeSingleEvent(of: .value, with: { (snapshot) in
                        guard let dictionary = snapshot.value as? [String: Any] else { return }
                        
                        let groupchat = Groupchat(id: key, dictionary: dictionary)
                        self.groupchats.append(groupchat)
                        self.tableView.reloadData()
                        
                    }, withCancel: { (err) in
                        print("failed to fetch groupchat", err)
                    })
                })
            }, withCancel: { (err) in
                print("failed to fetch groupchats", err)
            })
        }
    }
    
    func fetchUserChats(user: User) {
        let currentUserId = user.id
        
        if let teamId = user.team {
            let teamRef = Database.database().reference().child("teams").child(teamId).child("member")
            teamRef.observeSingleEvent(of: .value, with: { (snapshot) in
                guard let dictionary = snapshot.value as? [String: Any] else { return }
                dictionary.forEach({ (key, value) in
                    
                    let userId = key
                    if userId != currentUserId {
                        let userRef = Database.database().reference().child("users").child(userId)
                        userRef.observeSingleEvent(of: .value, with: { (snapshot) in
                            guard let dictionary = snapshot.value as? [String: Any] else { return }
                            
                            let user = User(uid: userId, dictionary: dictionary)
                            self.userchats.append(user)
                            self.tableView.reloadData()
                            
                        }, withCancel: { (err) in
                            print("failed to fetch User from db: ", err)
                        })
                    }
                })
            }, withCancel: { (err) in
                print("failed to fetch Team:", err)
            })
        }
    }
    
    func fetchNewMessageIds(user: User) {
        badgeDictionary.removeAll()
//        tableView.reloadData()
        let userMessagesRef = Database.database().reference().child("user-messages").child(user.id).child("new-messages")
        
        userMessagesRef.observeSingleEvent(of: .value, with: { (snapshot) in
            
            guard let dictionary = snapshot.value as? [String: Any] else { return }
            dictionary.forEach({ (key, value) in
                self.fetchNewMessage(messageId: key)
            })
            self.tableView.reloadData()
            
        }) { (err) in
            print("failed to fetch new messages", err)
        }
    }
    
    func fetchNewMessage(messageId: String) {
        let messageRef = Database.database().reference().child("messages").child(messageId)
        messageRef.observeSingleEvent(of: .value, with: { (snapshot) in
            
            guard let dictionary = snapshot.value as? [String: AnyObject] else { return }
            let message = Message(dictionary: dictionary)
            
            guard let fromId = message.fromId else { return }
            self.saveCountToUserIdDictionary(messageFromId: fromId)
        }, withCancel: { (err) in
            print("failed to fetch message", err)
        })
    }
    
    func saveCountToUserIdDictionary(messageFromId: String) {
        if let fromIdMessageCount = self.badgeDictionary[messageFromId] {
            self.badgeDictionary[messageFromId] = fromIdMessageCount + 1
        } else {
            self.badgeDictionary[messageFromId] = 1
        }
    }
    
    func setupBadges() {
        userchats.forEach { (user) in
            let indexOfUser = userchats.index(where: { (user) -> Bool in
                self.badgeDictionary[user.id] != nil
            })
            
            guard let indexOfUserInUserchats = indexOfUser else { return }
            
            let intIndexOfUser = userchats.startIndex.distance(to: indexOfUserInUserchats)
            let indexPath = IndexPath(row: intIndexOfUser, section: 2)
            guard let cell = tableView.cellForRow(at: indexPath) as? MessageCell else { return }
            
            
            cell.badgeLabel.isHidden = false
            guard let messageCount = badgeDictionary[user.id] else { return }
            cell.badgeLabel.text = String(messageCount)
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: headerId) as! MessageHeader
        
        switch section {
        case 0:
            header.titleLabel.text = "HOME"
        case 1:
            header.titleLabel.text = "GROUPCHATS"
        default:
            header.titleLabel.text = "USER"
        }
        
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 20
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return groupchats.count
        default:
            return userchats.count
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 38
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch (indexPath.section) {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! MessageCell
            
            cell.selectionStyle = .none
            cell.usernameLabel.text = "home"
            
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! MessageCell
            
            cell.messagesCell = self
            cell.groupchat = groupchats[indexPath.row]
            cell.selectionStyle = .none
            
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! MessageCell
            
            cell.messagesCell = self
            cell.user = userchats[indexPath.row]
            cell.badgeLabel.isHidden = true
            
            cell.selectionStyle = .none
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch (indexPath.section) {
        case 0:
            showHomeController()
        case 1:
            let groupchat = groupchats[indexPath.row]
            shotChatControllerForGroupchat(groupchat: groupchat)
        case 2:
            let user = userchats[indexPath.row]
            showChatControllerForUser(user: user)
        default:
            break
        }
    }
    
    func getGroupchatIdsArray(id: String) -> [String]? {
        
        var userGroupArray = [String]()
        
        let ref = Database.database().reference().child("users").child(id).child("groupchats")
        
        ref.observe(.childAdded, with: { (snapshot) in
            
            guard let dictionary = snapshot.value as? [String: Any] else { return }
            
            dictionary.forEach({ (key, value) in
                
                userGroupArray.append(key)
                
            })
            
        }, withCancel: nil)
        
        return userGroupArray
        
    }
    
    func showHomeController() {
        
        
        let mainTabBarController = MainTabBarController()
        
        
        guard let controller = mainTabBarController.viewControllers?[0] as? UINavigationController else { return }
        
        guard let homeController = controller.viewControllers[0] as? HomeController else { return }
        
        homeController.menu = menu
        
        menu?.startController?.present(mainTabBarController, animated: false, completion: {
            //code here
            self.menu?.handleDismiss()
        })
        homeController.menu?.startController = homeController
    }
    
    func showChatControllerForUser(user: User) {
        let chatLogController = ChatLogController(collectionViewLayout: UICollectionViewFlowLayout())
        chatLogController.user = user
        chatLogController.menu = menu
        
        let navController = UINavigationController(rootViewController: chatLogController)
        
        menu?.startController?.present(navController, animated: false, completion: {
            //completion here
            self.menu?.handleDismiss()
        })
        chatLogController.menu?.startController = chatLogController
    }
    
    func shotChatControllerForGroupchat(groupchat: Groupchat) {
        let chatLogController = ChatLogController(collectionViewLayout: UICollectionViewFlowLayout())
        chatLogController.group = groupchat
        chatLogController.menu = menu
        
        let navController = UINavigationController(rootViewController: chatLogController)
        
        menu?.startController?.present(navController, animated: false, completion: { 
            self.menu?.handleDismiss()
        })
    }
    
}











