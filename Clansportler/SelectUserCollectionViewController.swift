//
//  SelectUserCollectionViewController.swift
//  Clansportler
//
//  Created by Luca Kiedrowski on 25.08.17.
//  Copyright © 2017 LucaKiedrowski. All rights reserved.
//

import UIKit
import Firebase

class SelectUserCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout, UISearchBarDelegate {
    
    let cellId = "cellId"
    let headerId = "headerId"
    
    var createTeamController: CreateTeamController? {
        didSet {
            setupCreateTeamNavBarButtons()
        }
    }
    
    var createGroupController: CreateGroupController? {
        didSet {
            setupGroupControllerNavBarButtons()
        }
    }
    
    var openGroupController: OpenGroupController? {
        didSet {
            setupOpenGroupControllerNavBarButtons()
        }
    }
    
    var users = [User]()
    var filteredUsers = [User]()
    var selectedUsers = [User]()
    
    var tabbedUsers = [User]() {
        didSet {
            headerCell?.tabbedUser = tabbedUsers
            headerCell?.collectionView.reloadData()
        }
    }
    
    var headerCell: UserHeader? {
        didSet {
            headerCell?.tabbedUser = tabbedUsers
            headerCell?.collectionView.reloadData()
        }
    }
    
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
        
        setupCollectionView()
        fetchUsers()
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
            self.collectionView?.reloadData()
            
        }) { (err) in
            print("failed to fetch users:", err)
        }
    }
    
    func setupCollectionView() {
        collectionView?.alwaysBounceVertical = true
        collectionView?.allowsMultipleSelection = true
        collectionView?.register(UserCollectionViewCell.self, forCellWithReuseIdentifier: cellId)
        collectionView?.register(UserHeader.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: headerId)
        collectionView?.backgroundColor = ColorCodes.backgroundGrey
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        searchBar.isHidden = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        searchBar.isHidden = true
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
    
    func setupGroupControllerNavBarButtons() {
        let backButton = UIBarButtonItem(image: #imageLiteral(resourceName: "icon_back").withRenderingMode(.alwaysTemplate), style: .plain, target: self, action: #selector(handleCancel))
        backButton.tintColor = UIColor.white
        navigationItem.leftBarButtonItem = backButton
        
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(handleGroupDone))
        doneButton.tintColor = UIColor.white
        navigationItem.rightBarButtonItem = doneButton
        
        
        navigationController?.navigationBar.addSubview(searchBar)
        
        let navBar = navigationController?.navigationBar
        
        searchBar.anchor(top: navBar?.topAnchor, left: navBar?.leftAnchor, bottom: navBar?.bottomAnchor, right: navBar?.rightAnchor, paddingTop: 0, paddingLeft: 65, paddingBottom: 0, paddingRight: 65, width: 0, height: 0)
    }
    
    func setupOpenGroupControllerNavBarButtons() {
        let backButton = UIBarButtonItem(image: #imageLiteral(resourceName: "icon_back").withRenderingMode(.alwaysTemplate), style: .plain, target: self, action: #selector(handleCancel))
        backButton.tintColor = UIColor.white
        navigationItem.leftBarButtonItem = backButton
        
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(handleOpenGroupDone))
        doneButton.tintColor = UIColor.white
        navigationItem.rightBarButtonItem = doneButton
        
        
        navigationController?.navigationBar.addSubview(searchBar)
        
        let navBar = navigationController?.navigationBar
        
        searchBar.anchor(top: navBar?.topAnchor, left: navBar?.leftAnchor, bottom: navBar?.bottomAnchor, right: navBar?.rightAnchor, paddingTop: 0, paddingLeft: 65, paddingBottom: 0, paddingRight: 65, width: 0, height: 0)
    }
    
    @objc func handleCancel() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func handleDone() {
        searchBar.resignFirstResponder()
        
        createTeamController?.selectedMembers = tabbedUsers
        navigationController?.popViewController(animated: true)
    }
    
    @objc func handleGroupDone() {
        searchBar.resignFirstResponder()
        
        createGroupController?.selectedMembers = tabbedUsers
        navigationController?.popViewController(animated: true)
    }
    
    @objc func handleOpenGroupDone() {
        searchBar.resignFirstResponder()
        
        for tabbedUser in tabbedUsers {
            let userId = tabbedUser.id
            openGroupController?.sendGroupInvitation(userId: userId)
        }
        navigationController?.popViewController(animated: true)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if searchText.isEmpty {
            filteredUsers = [User]()
        } else {
            filteredUsers = self.users.filter { (user) -> Bool in
                return user.username.lowercased().contains(searchText.lowercased())
            }
        }
        self.collectionView?.reloadData()
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let width = view.frame.width
        var height: CGFloat
        
        if tabbedUsers.count == 0 {
            height = 0
        } else {
            height = 135
        }
        return CGSize(width: width, height: height)
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerId, for: indexPath) as! UserHeader
        
        header.selectUserController = self
        self.headerCell = header
        
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = view.frame.width
        let height: CGFloat = 66
        
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filteredUsers.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! UserCollectionViewCell
        
        let cellUser = filteredUsers[indexPath.item]
        
        cell.user = cellUser
        cell.selectUserController = self
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let user = filteredUsers[indexPath.item]
        
        let alreadyInTabbedUsers = tabbedUsers.contains(where: { (tUser) -> Bool in
            return user.id == tUser.id
        })
        if !alreadyInTabbedUsers {
            tabbedUsers.append(user)
            collectionView.reloadData()
        }
    }
    
}











