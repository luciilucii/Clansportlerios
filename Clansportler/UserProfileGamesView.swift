//
//  UserProfileGamesView.swift
//  Clansportler
//
//  Created by Luca Kiedrowski on 23.09.17.
//  Copyright © 2017 LucaKiedrowski. All rights reserved.
//

import UIKit
import Firebase

class UserProfileGamesView: CustomView, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    let cellId = "cellId"
    
    var games = [Game]() {
        didSet {
            if games.count == 0 {
                noGamesLabel.isHidden = false
            } else {
                noGamesLabel.isHidden = true
            }
        }
    }
    
    var user: User? {
        didSet {
            if user?.id == Auth.auth().currentUser?.uid {
                self.addGamesButton.isHidden = false
            } else {
                self.addGamesButton.isHidden = true
            }
            if let gameIds = user?.gameIds {
                gameIds.forEach({ (gameId) in
                    Database.fetchGameWithId(id: gameId, completion: { (game) in
                        self.games.append(game)
                        self.collectionView.reloadData()
                    })
                })
            }
        }
    }
    
    var userProfileController: UserProfileController?
    
    let gamesLabel: UILabel = {
        let label = UILabel()
        label.text = "Games"
        label.textColor = .white
        label.font = UIFont.boldSystemFont(ofSize: 16)
        return label
    }()
    
    lazy var addGamesButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "plus_icon").withRenderingMode(.alwaysTemplate), for: .normal)
        button.tintColor = .white
        button.layer.borderColor = UIColor.white.cgColor
        button.addTarget(self, action: #selector(handleAddGames), for: .touchUpInside)
        button.layer.borderWidth = 1
        button.isHidden = true
        return button
    }()
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = ColorCodes.clansportlerBlue
        cv.alwaysBounceHorizontal = true
        cv.delegate = self
        cv.dataSource = self
        return cv
    }()
    
    let noGamesLabel: UILabel = {
        let label = UILabel()
        label.text = "No games chosen :/"
        label.textAlignment = .center
        label.textColor = UIColor.white
        return label
    }()
    
    override func setupCustomView() {
        super.setupCustomView()
        
        NotificationCenter.default.addObserver(self, selector: #selector(setupTimerForUpdate), name: UserProfileController.updateGamesViewNotification, object: nil)
        
        backgroundColor = ColorCodes.clansportlerBlue
        layer.cornerRadius = 5
        clipsToBounds = true
        
        collectionView.register(MyGamesCell.self, forCellWithReuseIdentifier: cellId)
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.contentInset = UIEdgeInsetsMake(0, 8, 0, 8)
        
        setupViews()
    }
    
    var updateTimer: Timer?
    
    @objc func setupTimerForUpdate() {
        updateTimer?.invalidate()
        updateTimer = Timer.scheduledTimer(timeInterval: 0.25, target: self, selector: #selector(fetchUserGamesUpdate), userInfo: nil, repeats: false)
    }
    
    @objc func fetchUserGamesUpdate() {
        guard let userId = self.user?.id else { return }
        self.games = [Game]()
        let userGamesRef = Database.database().reference().child("users").child(userId).child("games")
        userGamesRef.observeSingleEvent(of: .value, with: { (snapshot) in
            
            guard let dictionary = snapshot.value as? [String: Any] else { return }
            dictionary.forEach({ (key, value) in
                Database.fetchGameWithId(id: key, completion: { (game) in
                    self.games.append(game)
                    self.collectionView.reloadData()
                })
            })
        }) { (err) in
            print("failed to update games", err)
        }
    }
    
    fileprivate func setupViews() {
        
        addSubview(gamesLabel)
        addSubview(addGamesButton)
        addSubview(collectionView)
        addSubview(noGamesLabel)
        
        gamesLabel.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 8, paddingLeft: 8, paddingBottom: 0, paddingRight: 100, width: 0, height: 25)
        addGamesButton.anchor(top: topAnchor, left: nil, bottom: nil, right: rightAnchor, paddingTop: 4, paddingLeft: 0, paddingBottom: 0, paddingRight: 4, width: 30, height: 30)
        addGamesButton.layer.cornerRadius = 30/2
        collectionView.anchor(top: gamesLabel.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 8, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 85)
        
        noGamesLabel.anchor(top: gamesLabel.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 8, paddingLeft: 8, paddingBottom: 0, paddingRight: 8, width: 0, height: 85)
    }
    
    @objc func handleAddGames() {
        let layout = UICollectionViewFlowLayout()
        let chooseGamesController = ChooseGamesController(collectionViewLayout: layout)
        chooseGamesController.user = self.user
        chooseGamesController.tabbedGames = games
        chooseGamesController.userProfileController = userProfileController
        let navController = UINavigationController(rootViewController: chooseGamesController)
        self.userProfileController?.present(navController, animated: true) {
            //Completion here
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return games.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! MyGamesCell
        
        let game = games[indexPath.item]
        cell.game = game
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width: CGFloat = 150
        let height: CGFloat = 85
        
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 4
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let game = self.games[indexPath.item]
        let gameController = GameController()
        gameController.game = game
        self.userProfileController?.show(gameController, sender: userProfileController)
    }
    
}
















