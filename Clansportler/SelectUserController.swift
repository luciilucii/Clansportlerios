//
//  SelectUserController.swift
//  Clansportler
//
//  Created by Luca Kiedrowski on 06.08.17.
//  Copyright © 2017 LucaKiedrowski. All rights reserved.
//

import UIKit
import Firebase

class SelectUserController: UITableViewController, UISearchBarDelegate {
    
    var createTeamController: CreateTeamController? {
        didSet {
            setupCreateTeamNavBarButtons()
        }
    }
    
    var teamController: TeamController? {
        didSet {
            setupMemberControllerButtons()
        }
    }
    
    var memberController: MemberController? {
        didSet {
            setupMemberControllerButtons()
        }
    }
    
    private let cellId = "cellId"
    
    var users = [User]()
    
    var selectedUsers = [User]()
    var filteredUsers = [User]()
    
    var tabbedMembers = [User]()
    
    
    lazy var searchBar: UISearchBar = {
        let sb = UISearchBar()
        sb.placeholder = "Enter username"
        sb.barTintColor = .gray
        sb.delegate = self
        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).backgroundColor = UIColor.white
        return sb
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchUsers()
        view.backgroundColor = .white
        
        tableView.allowsMultipleSelection = true
        tableView.keyboardDismissMode = .onDrag
        tableView.register(UserCell.self, forCellReuseIdentifier: cellId)
        
        searchBar.isHidden = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        searchBar.isHidden = true
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if searchText.isEmpty {
            filteredUsers = users
        } else {
            filteredUsers = self.users.filter { (user) -> Bool in
                return user.username.lowercased().contains(searchText.lowercased())
            }
        }
        self.tableView.reloadData()
    }
    
    fileprivate func setupCreateTeamNavBarButtons() {
        let backButton = UIBarButtonItem(image: #imageLiteral(resourceName: "icon_back").withRenderingMode(.alwaysTemplate), style: .plain, target: self, action: #selector(handleCancel))
        backButton.tintColor = UIColor.white
        navigationItem.leftBarButtonItem = backButton
        
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(handleDone))
        doneButton.tintColor = UIColor.white
        navigationItem.rightBarButtonItem = doneButton
        
        
        navigationController?.navigationBar.addSubview(searchBar)
        
        let navBar = navigationController?.navigationBar
        
        searchBar.anchor(top: navBar?.topAnchor, left: navBar?.leftAnchor, bottom: navBar?.bottomAnchor, right: navBar?.rightAnchor, paddingTop: 0, paddingLeft: 65, paddingBottom: 0, paddingRight: 65, width: 0, height: 0)
        
    }
    
    fileprivate func setupMemberControllerButtons() {
        setupBarCancelButton()
        
        let inviteButton = UIBarButtonItem(title: "Invite", style: .plain, target: self, action: #selector(handleInvite))
        inviteButton.tintColor = .white
        navigationItem.rightBarButtonItem = inviteButton
    }
    
    @objc func handleInvite() {
        print("abc, easy as 123")
    }
    
    func fetchUsers() {
        users = [User]()
        
        let userRef = Database.database().reference().child("users")
        userRef.observeSingleEvent(of: .value, with: { (snapshot) in
            
            guard let dictionaries = snapshot.value as? [String: Any] else { return }
            
            dictionaries.forEach({ (key, value) in
                if key == Auth.auth().currentUser?.uid {
                    return
                }
                guard let userDictionary = value as? [String: Any] else { return }
                let user = User(uid: key, dictionary: userDictionary)
                
                self.users.append(user)
            })
            
            self.users.sort(by: { (u1, u2) -> Bool in
                
                return u1.username.compare(u2.username) == .orderedAscending
                
            })
            self.filteredUsers = self.users
            self.tableView.reloadData()
            
        }) { (err) in
            print("failed to fetch users:", err)
        }
    }
    
    @objc func handleCancel() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func handleDone() {
//        guard let indexPaths = tableView.indexPathsForSelectedRows else {
//            //no row selected
//            return
//        }
//        
//        for indexPath in indexPaths {
//            let user = users[indexPath.row]
//            selectedUsers.append(user)
//        }
        searchBar.isHidden = true
        searchBar.resignFirstResponder()
        
        createTeamController?.selectedMembers = selectedUsers
        navigationController?.popViewController(animated: true)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredUsers.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! UserCell
        
        let user = filteredUsers[indexPath.row]
        
        cell.selectUserController = self
        cell.user = user
        
        cell.profileImageView.loadImage(urlString: user.profileImageUrl)
        
        cell.accessoryType = cell.isSelected ? .checkmark : .none
        cell.selectionStyle = .default
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 66
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
        
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        tableView.cellForRow(at: indexPath)?.accessoryType = .none
    }
    
}
