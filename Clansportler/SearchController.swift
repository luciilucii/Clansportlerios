//
//  SearchController.swift
//  Clansportler
//
//  Created by Luca Kiedrowski on 15.09.17.
//  Copyright © 2017 LucaKiedrowski. All rights reserved.
//

import UIKit
import Firebase

class SearchController: UICollectionViewController, UICollectionViewDelegateFlowLayout, UISearchBarDelegate, SearchMenuBarDelegate {
    
    let cellId = "cellId"
    
    var searchMenuTitle: SearchMenuBarTitle = SearchMenuBarTitle.user 
    
    var filteredUsers = [User]()
    var filteredClans = [Team]()
    
    lazy var searchMenuBar: SearchMenuBar = {
        let smb = SearchMenuBar()
        smb.delegate = self
        return smb
    }()
    
    lazy var searchBar: UISearchBar = {
        let sb = UISearchBar()
        sb.placeholder = "Search"
        sb.barTintColor = .gray
        sb.delegate = self
//        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).backgroundColor = ColorCodes.middleGrey
//        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).textColor = UIColor.white
        return sb
    }()
    
    let tournamentLabel: UILabel = {
        let label = UILabel()
        label.text = "Tournaments are coming..."
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.textAlignment = .center
        label.isHidden = false
        label.textColor = UIColor.white
        return label
    }()
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            _ = Timer.scheduledTimer(timeInterval: 0.3, target: self, selector: #selector(handleSearchBarEmpty), userInfo: nil, repeats: false)
        } else {
            switch searchMenuTitle {
            case .user:
                fetchUserWithUsername(searchText: searchText.lowercased())
            case .clans:
                fetchClanWithName(searchText: searchText.lowercased())
            default:
                break
            }
            tournamentLabel.isHidden = true
        }
        self.collectionView?.reloadData()
    }
    
    @objc func handleSearchBarEmpty() {
        filteredUsers = [User]()
        filteredClans = [Team]()
        tournamentLabel.isHidden = false
        
        collectionView?.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView?.backgroundColor = ColorCodes.backgroundGrey
        
        let closeButton = UIBarButtonItem(image: #imageLiteral(resourceName: "cancel").withRenderingMode(.alwaysTemplate), style: .plain, target: self, action: #selector(handleDismiss))
        closeButton.tintColor = UIColor.white
        navigationItem.rightBarButtonItem = closeButton
        
        navigationController?.navigationBar.tintColor = UIColor.white
        navigationController?.navigationBar.addSubview(searchBar)
        
        let navBar = navigationController?.navigationBar
        
        searchBar.anchor(top: navBar?.topAnchor, left: navBar?.leftAnchor, bottom: navBar?.bottomAnchor, right: navBar?.rightAnchor, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 65, width: 0, height: 0)
        
        collectionView?.register(UserSearchCell.self, forCellWithReuseIdentifier: cellId)
        collectionView?.alwaysBounceVertical = true
        collectionView?.keyboardDismissMode = .onDrag
        collectionView?.contentInset = UIEdgeInsetsMake(40, 0, 0, 0)
        
        setupViews()
    }
    
    @objc func handleDismiss() {
        self.dismiss(animated: true) {
            //completion here
        }
    }
    
    func setupViews() {
        view.addSubview(searchMenuBar)
        
        searchMenuBar.anchor(top: topLayoutGuide.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 40)
        
        
        view.addSubview(tournamentLabel)
        
        tournamentLabel.anchor(top: nil, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 8, width: 0, height: 30)
        tournamentLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
    }
    
    func fetchUserWithUsername(searchText: String) {
        filteredUsers = [User]()
        
        let userRef = Database.database().reference().child("users").queryOrdered(byChild: "username").queryStarting(atValue: searchText).queryEnding(atValue: searchText+"\u{f8ff}")
        userRef.observeSingleEvent(of: .value, with: { (snapshot) in
            
            guard let dictionaries = snapshot.value as? [String: Any] else { return }
            
            dictionaries.forEach({ (key, value) in
                guard let userDictionary = value as? [String: Any] else { return }
                let user = User(uid: key, dictionary: userDictionary)
                
                let isContained = self.filteredUsers.contains(where: { (containedUser) -> Bool in
                    return user.id == containedUser.id
                })
                if !isContained {
                    self.filteredUsers.append(user)
                    self.collectionView?.reloadData()
                }
            })
        }) { (err) in
            print("failed to fetch searched User", err)
        }
    }
    
    func fetchClanWithName(searchText: String) {
        filteredClans = [Team]()
        
        let userRef = Database.database().reference().child("teams").queryOrdered(byChild: "teamname").queryStarting(atValue: searchText).queryEnding(atValue: searchText+"\u{f8ff}")
        
        userRef.observeSingleEvent(of: .value, with: { (snapshot) in
            
            guard let dictionaries = snapshot.value as? [String: Any] else { return }
            
            dictionaries.forEach({ (key, value) in
                
                guard let clanDictionary = value as? [String: Any] else { return }
                let team = Team(uid: key, values: clanDictionary)
                
                let isContained = self.filteredClans.contains(where: { (containedClan) -> Bool in
                    return team.id == containedClan.id
                })
                if !isContained {
                    self.filteredClans.append(team)
                    self.collectionView?.reloadData()
                }
            })
        }) { (err) in
            print("failed to fetch searched User", err)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        searchBar.isHidden = false
    }
    
    func didSelectorMenuBarCell(searchMenuBarTitle: SearchMenuBarTitle) {
        self.searchMenuTitle = searchMenuBarTitle
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        switch self.searchMenuTitle {
        case .user:
            searchBar.isHidden = true
            searchBar.resignFirstResponder()
            
            let user = filteredUsers[indexPath.item]
            
            let userProfileController = UserProfileController()
            userProfileController.user = user
            navigationController?.pushViewController(userProfileController, animated: true)
        case .clans:
            searchBar.isHidden = true
            searchBar.resignFirstResponder()
            
            let clan = filteredClans[indexPath.item]
            
            let teamController = TeamController()
            teamController.team = clan
            
            navigationController?.pushViewController(teamController, animated: true)
        default:
            break
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch self.searchMenuTitle {
        case .user:
            return filteredUsers.count
        case .clans:
            return filteredClans.count
        case .tournaments:
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: 66)
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! UserSearchCell
        
        switch searchMenuTitle {
        case .user:
            cell.user = filteredUsers[indexPath.item]
        case .clans:
            cell.clan = filteredClans[indexPath.item]
        default:
            break
        }
        return cell
    }
    
}
