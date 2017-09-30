//
//  SearchTeamController.swift
//  Clansportler
//
//  Created by Luca Kiedrowski on 10.08.17.
//  Copyright © 2017 LucaKiedrowski. All rights reserved.
//

import UIKit
import Firebase

class SearchTeamController: UICollectionViewController, UICollectionViewDelegateFlowLayout, UISearchBarDelegate, UINavigationControllerDelegate {
    
    let cellId = "cellId"
    
    var teams = [Team]()
    var filteredTeams = [Team]()
    
    lazy var searchBar: UISearchBar = {
        let sb = UISearchBar()
        sb.placeholder = "Enter Teamname"
        sb.barTintColor = .gray
        sb.delegate = self
        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).backgroundColor = UIColor.white
        return sb
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupBarCancelButton()
        setupSearchBar()
        fetchTeams()
        
        collectionView?.backgroundColor = ColorCodes.backgroundGrey
        collectionView?.register(SearchTeamCell.self, forCellWithReuseIdentifier: cellId)
        collectionView?.alwaysBounceVertical = true
        
    }
    
    func setupSearchBar() {
        navigationItem.titleView = searchBar
    }
    
    func fetchTeams() {
        
        let teamRef = Database.database().reference().child("teams")
        teamRef.observeSingleEvent(of: .value, with: { (snapshot) in
            
            guard let dictionaries = snapshot.value as? [String: Any] else { return }
            dictionaries.forEach({ (key, value) in
                
                guard let dictionary = value as? [String: Any] else { return }
                
                let team = Team(uid: key, values: dictionary)
                
                self.teams.append(team)
                
            })
            
            self.teams.sort(by: { (t1, t2) -> Bool in
                
                return t1.teamname.compare(t2.teamname) == .orderedAscending
                
            })
            self.filteredTeams = self.teams
            self.collectionView?.reloadData()
            
        }) { (err) in
            print("failed to fetch Teams: ", err)
        }
        
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            filteredTeams = teams
        } else {
            filteredTeams = self.teams.filter { (team) -> Bool in
                return team.teamname.lowercased().contains(searchText.lowercased())
            }
        }
        self.collectionView?.reloadData()
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let teamController = TeamController()
        teamController.team = filteredTeams[indexPath.item]
        
        show(teamController, sender: self)
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filteredTeams.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! SearchTeamCell
        
        let team = filteredTeams[indexPath.item]
        cell.team = team
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = view.frame.width
        let height: CGFloat = 65
        
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
}
