//
//  ChooseGamesController.swift
//  Clansportler
//
//  Created by Luca Kiedrowski on 12.08.17.
//  Copyright © 2017 LucaKiedrowski. All rights reserved.
//

import UIKit
import Firebase

class ChooseGamesController: UICollectionViewController, UICollectionViewDelegateFlowLayout, UISearchBarDelegate {
    
    let cellId = "cellId"
    let headerId = "headerId"
    let addGameId = "addGameId"
    
    var games = [Game]()
    var selectedGames = [Game]()
    var filteredGames = [Game]() {
        didSet {
            self.collectionView?.reloadData()
        }
    }
    var tabbedGames = [Game]() {
        didSet {
            headerCell?.tabbedGames = tabbedGames
        }
    }
    
    var gameIds: [String]? {
        didSet {
            guard let gameIds = self.gameIds else { return }
            gameIds.forEach { (gameId) in
                Database.fetchGameWithId(id: gameId, completion: { (fetchedUserGame) in
                    self.tabbedGames.append(fetchedUserGame)
                })
            }
            
        }
    }
    
    var userProfileController: UserProfileController?
    var user: User?
    
    var headerCell: ChooseGamesHeader? {
        didSet {
            headerCell?.tabbedGames = tabbedGames
        }
    }
    
    lazy var searchBar: UISearchBar = {
        let sb = UISearchBar()
        sb.placeholder = "Enter Game"
        sb.barTintColor = .gray
        sb.delegate = self
        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).backgroundColor = UIColor.white
        return sb
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCollectionView()
        setupBarCancelButton()
        fetchGames()
        setupNavBarButtonsAndSearchBar()
    }
    
    func setupCollectionView() {
        collectionView?.backgroundColor = ColorCodes.backgroundGrey
        collectionView?.alwaysBounceVertical = true
        collectionView?.register(ChooseGamesHeader.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: headerId)
        collectionView?.register(ChooseGamesCell.self, forCellWithReuseIdentifier: cellId)
        collectionView?.register(AddGameCell.self, forCellWithReuseIdentifier: addGameId)
        collectionView?.contentInset = UIEdgeInsetsMake(8, 8, 8, 8)
        
        collectionView?.keyboardDismissMode = .onDrag
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        searchBar.isHidden = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        searchBar.isHidden = true
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if searchText.isEmpty {
            filteredGames = games
        } else {
            filteredGames = self.games.filter { (game) -> Bool in
                guard let gamename = game.name else { return false }
                return gamename.lowercased().contains(searchText.lowercased())
            }
        }
        self.collectionView?.reloadData()
    }
    
    func setupNavBarButtonsAndSearchBar() {
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(handleDone))
        doneButton.tintColor = .white
        
        navigationItem.rightBarButtonItem = doneButton
        
        navigationController?.navigationBar.addSubview(searchBar)
        
        let navBar = navigationController?.navigationBar
        
        searchBar.anchor(top: navBar?.topAnchor, left: navBar?.leftAnchor, bottom: navBar?.bottomAnchor, right: navBar?.rightAnchor, paddingTop: 0, paddingLeft: 65, paddingBottom: 0, paddingRight: 65, width: 0, height: 0)
    }
    
    @objc func handleDone() {
        searchBar.resignFirstResponder()
        guard let currentUserId = user?.id else { return }
        let userRef = Database.database().reference().child("users").child(currentUserId).child("games")
        userRef.removeValue { (err, completed) in
            if let err = err {
                print("failed to delete gameIds", err)
                return
            }
            self.tabbedGames.forEach { (tabbedGame) in
                self.loadGameIntoUserDb(game: tabbedGame)
            }
            self.dismiss(animated: true) {
                //completion here
            }
        }
    }
    
    func loadGameIntoUserDb(game: Game) {
        guard let currentUserId = user?.id else { return }
        
        let values: [String: Any] = [game.id: 1]
        
        let userRef = Database.database().reference().child("users").child(currentUserId).child("games")
        userRef.updateChildValues(values) { (err, _) in
            if let err = err {
                print("failed to upload games into user db", err)
            }
            NotificationCenter.default.post(name: UserProfileController.updateGamesViewNotification, object: nil)
        }
        
        let hasChoosenRef = Database.database().reference().child("users").child(currentUserId)
        let choosenValues: [String: Any] = ["hasChoosenGames": true]
        
        hasChoosenRef.updateChildValues(choosenValues) { (err, _) in
            if let err = err {
                print("failed to post choosen Games", err)
            }
        }
        loadPlayerIntoGameDb(game: game, userId: currentUserId)
    }
    
    func loadPlayerIntoGameDb(game: Game, userId: String) {
        let values: [String: Any] = [userId: 1]
        let gameRef = Database.database().reference().child("games").child(game.id).child("player")
        gameRef.updateChildValues(values) { (err, _) in
            if let err = err {
                print("failed to upload user into game db", err)
            }
        }
    }
    
    func fetchGames() {
        self.games = [Game]()
        
        let gamesRef = Database.database().reference().child("games").child("approvedGames")
        gamesRef.observe(.value, with: { (snapshot) in
            guard let dictionaries = snapshot.value as? [String: Any] else { return }
            for dictionary in dictionaries {
                Database.fetchGameWithId(id: dictionary.key, completion: { (game) in
                    self.games.append(game)
                    self.filteredGames.append(game)
                    self.collectionView?.reloadData()
                })
            }
        }) { (err) in
            print("failed to fetch game ids", err)
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filteredGames.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let width = view.frame.width
        var height: CGFloat
        
        if tabbedGames.count == 0 {
            height = 30
        } else {
            height = 135
        }
        return CGSize(width: width, height: height)
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerId, for: indexPath) as! ChooseGamesHeader
        
        header.chooseGamesController = self
        self.headerCell = header
        
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (view.frame.width - 24) / 2
        let height: CGFloat = 150
        return CGSize(width: width, height: height)
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch indexPath.item {
        case filteredGames.count:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: addGameId, for: indexPath) as! AddGameCell
            
            cell.chooseGamesController = self
            
            return cell
        default:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! ChooseGamesCell
            
            cell.game = filteredGames[indexPath.item]
            
            return cell
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let game = filteredGames[indexPath.item]
        
        selectedGames.append(game)
        
        let isContained = tabbedGames.contains { (containedGame) -> Bool in
            return containedGame.id == game.id
        }
        if !isContained {
            tabbedGames.append(game)
            collectionView.reloadData()
        }
        
    }
    
}




