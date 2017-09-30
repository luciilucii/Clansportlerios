//
//  ApproveGamesController.swift
//  Clansportler
//
//  Created by Luca Kiedrowski on 27.08.17.
//  Copyright © 2017 LucaKiedrowski. All rights reserved.
//

import UIKit
import Firebase

class ApproveGamesController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    let cellId = "cellId"
    
    var allGames = [Game]()
    var games = [Game]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView?.register(ApproveGamesCell.self, forCellWithReuseIdentifier: cellId)
        collectionView?.alwaysBounceVertical = true
        collectionView?.backgroundColor = ColorCodes.backgroundGrey
        
        newFetchGames()
    }
    
    fileprivate func newFetchGames() {
        let gameRef = Database.database().reference().child("games")
        gameRef.observeSingleEvent(of: .value, with: { (snapshot) in
            
            guard let dictionaries = snapshot.value as? [String: Any] else { return }
            
            dictionaries.forEach({ (key, value) in
                
                if key != "approvedGames" {
                    
                    guard let dictionary = value as? [String: Any] else { return }
                    let game = Game(id: key, dictionary: dictionary)
                    
                    self.checkIfShouldAppendGame(game: game)

                } else {
                    guard let dictionary = value as? [String: Any] else { return }
                    
                    if self.approvedGames == nil {
                        self.approvedGames = dictionary
                    }
                }
            })
            
        }) { (err) in
            print("failed to fetch games", err)
        }
        
    }
    
    var approvedGames: [String: Any]?
    
    func checkIfShouldAppendGame(game: Game) {
        
        if self.approvedGames == nil {
            let gameRef = Database.database().reference().child("games").child("approvedGames")
            gameRef.observeSingleEvent(of: .value, with: { (snapshot) in
                guard let dictionary = snapshot.value as? [String: Any] else { return }
                
                if self.approvedGames == nil {
                    self.approvedGames = dictionary
                }
                
                self.checkIfGameIsInApprovedGames(game: game, dictionary: dictionary)
                
            }) { (err) in
                print("failed to fetch approvedGames")
            }
        } else {
            guard let dictionary = self.approvedGames else { return }
            self.checkIfGameIsInApprovedGames(game: game, dictionary: dictionary)
        }
    }
    
    func checkIfGameIsInApprovedGames(game: Game, dictionary: [String: Any]) {
        if dictionary[game.id] != nil {
            return
        } else {
            self.games.append(game)
            self.collectionView?.reloadData()
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return games.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! ApproveGamesCell
        
        let game = games[indexPath.item]
        cell.game = game
                
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = view.frame.width
        let height: CGFloat = 66
        
        return CGSize(width: width, height: height)
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let game = games[indexPath.item]
        
        let detailController = DetailApproveController()
        detailController.game = game
        
        show(detailController, sender: self)
    }
    
}
