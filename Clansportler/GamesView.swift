//
//  GamesView.swift
//  Clansportler
//
//  Created by Luca Kiedrowski on 17.08.17.
//  Copyright © 2017 LucaKiedrowski. All rights reserved.
//

import UIKit
import Firebase

class GamesView: CustomView, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    let cellId = "cellId"
    
    var teamController: TeamController? {
        didSet {
            self.team = teamController?.team
        }
    }
    
    var team: Team? {
        didSet {
            
            guard let team = team else { return }
            self.fetchTeamGames(team: team)
            
        }
    }
    
    var gameDictionary = [String: Int]()
    var teamGameDictionary = [TeamGame]() {
        didSet {
//            gamesCollectionView.reloadData()
        }
    }
    
    let gamesLabel: UILabel = {
        let label = UILabel()
        label.text = "Most played Games"
        label.textColor = ColorCodes.clansportlerBlue
        label.font = UIFont.boldSystemFont(ofSize: 16)
        return label
    }()
    
    lazy var gamesCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.dataSource = self
        cv.delegate = self
        cv.alwaysBounceHorizontal = true
        cv.showsHorizontalScrollIndicator = false
        cv.backgroundColor = UIColor.white
        return cv
    }()
    
    override func setupCustomView() {
        super.setupCustomView()
        
        backgroundColor = .white
        layer.cornerRadius = 5
        clipsToBounds = true
        
        setupCollectionView()
        
        addSubview(gamesLabel)
        addSubview(gamesCollectionView)
        
        gamesLabel.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: nil, paddingTop: 8, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 200, height: 25)
        
        gamesCollectionView.anchor(top: gamesLabel.bottomAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 8, paddingRight: 0, width: 0, height: 0)
        
        
    }
    
    func setupCollectionView() {
        gamesCollectionView.register(TeamGamesCell.self, forCellWithReuseIdentifier: cellId)
        gamesCollectionView.contentInset = UIEdgeInsetsMake(0, 8, 0, 8)
    }
    
    func fetchTeamGames(team: Team) {
        guard let memberIds = team.member else { return }
        
        for memberId in memberIds {
            
            let userRef = Database.database().reference().child("users").child(memberId)
            userRef.observeSingleEvent(of: .value, with: { (snapshot) in
                
                guard let dictionary = snapshot.value as? [String: Any] else { return }
                let user = User(uid: memberId, dictionary: dictionary)
                
                self.fetchUserGames(user: user)
                
            }, withCancel: { (err) in
                print("failed to fetch user", err)
            })
            
        }
        
    }
    
    func fetchUserGames(user: User) {
        
        guard let gameIds = user.gameIds else { return }
        
        for gameId in gameIds {
            let isGameInDictionary = teamGameDictionary.contains(where: { teamgame -> Bool in
                if teamgame.id == gameId {
                    return true
                } else {
                    return false
                }
                
            })
            
            if isGameInDictionary {
                teamGameDictionary.forEach({ teamgame in
                    if teamgame.id == gameId {
                        teamgame.playerCount = teamgame.playerCount + 1
                    }
                })
            } else {
                let teamGame = TeamGame(id: gameId, playerCount: 1)
                self.teamGameDictionary.append(teamGame)
            }
            
        }
        
        teamGameDictionary.sort(by: { (tg1, tg2) -> Bool in
            return tg1.playerCount > tg2.playerCount
        })
        
        self.gamesCollectionView.reloadData()
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let height: CGFloat = 130
        let width: CGFloat = 150
        
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return teamGameDictionary.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! TeamGamesCell
        
        let game = teamGameDictionary[indexPath.item]
        
        cell.teamMemberCount = self.team?.member?.count ?? 0
        
        cell.gameId = nil
        cell.gameId = game.id
        cell.playerCount = game.playerCount
        
        return cell
    }
    
}

