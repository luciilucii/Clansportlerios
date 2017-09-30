//
//  TeamMenuCell.swift
//  Clansportler
//
//  Created by Luca Kiedrowski on 30.07.17.
//  Copyright © 2017 LucaKiedrowski. All rights reserved.
//

import UIKit
import Firebase

class TeamMenuCell: BaseCell, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    let cellId = "cellId"
    
    let teamId = "teamId"
    let gameId = "gameId"
    
    var currentUser: User? {
        didSet {
            self.fetchTeams()
            self.fetchGames()
            
//            gamesCollectionView.reloadData()
//            teamsCollectionView.reloadData()
        }
    }
    
    var teams = [Team]()
    var games = [Game]()
    
    var menu: Menu? {
        didSet {
            gamesCollectionView.reloadData()
            teamsCollectionView.reloadData()
        }
    }
    
    let navBar: UIView = {
        let view = UIView()
        view.backgroundColor = ColorCodes.darkestGrey
        
        let seperatorView = UIView()
        seperatorView.backgroundColor = .white
        view.addSubview(seperatorView)
        seperatorView.anchor(top: nil, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0.5)
        
        let iconImageView = UIImageView()
        iconImageView.image = #imageLiteral(resourceName: "logo_blue_transparent")
        iconImageView.clipsToBounds = true
        
        view.addSubview(iconImageView)
        iconImageView.anchor(top: nil, left: view.leftAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 30, height: 30)
        iconImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        iconImageView.layer.cornerRadius = 30 / 2
        
        return view
    }()
    
    let teamLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.text = "My Clans"
        return label
    }()
    
    lazy var teamsCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.delegate = self
        cv.dataSource = self
        return cv
    }()
    
    let gamesLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.text = "My Games"
        return label
    }()
    
    lazy var gamesCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.delegate = self
        cv.dataSource = self
        return cv
    }()
    
    override func setupCell() {
        super.setupCell()
        
        backgroundColor = ColorCodes.darkestGrey
        
        setupCollectionViews()
        
        setupViews()
    }
    
    func setupCollectionViews() {
        teamsCollectionView.register(TMTeamCell.self, forCellWithReuseIdentifier: teamId)
        teamsCollectionView.backgroundColor = ColorCodes.darkestGrey
        
        
        gamesCollectionView.register(TMGameCell.self, forCellWithReuseIdentifier: gameId)
        gamesCollectionView.backgroundColor = ColorCodes.darkestGrey
    }
    
    func setupViews() {
        addSubview(navBar)
        addSubview(teamLabel)
        addSubview(teamsCollectionView)
        addSubview(gamesLabel)
        addSubview(gamesCollectionView)
        
        navBar.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 45)
        
        teamLabel.anchor(top: navBar.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 8, paddingLeft: 8, paddingBottom: 0, paddingRight: 8, width: 0, height: 30)
        
        teamsCollectionView.anchor(top: teamLabel.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 158)
        
        gamesLabel.anchor(top: teamsCollectionView.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 8, paddingLeft: 8, paddingBottom: 0, paddingRight: 8, width: 0, height: 30)
        
        gamesCollectionView.anchor(top: gamesLabel.bottomAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 32, paddingRight: 0, width: 0, height: 0)
        
    }
    
    func fetchTeams() {
        if let teamId = currentUser?.team {
            Database.fetchTeamWithId(uid: teamId, completion: { (team) in
                self.teams.append(team)
                self.teamsCollectionView.reloadData()
            })
        }
    }
    
    func fetchGames() {
        if let gameIds = currentUser?.gameIds {
            gameIds.forEach({ (gameId) in
                Database.fetchGameWithId(id: gameId, completion: { (game) in
                    self.games.append(game)
                    self.gamesCollectionView.reloadData()
                })
            })
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        var width: CGFloat
        var height: CGFloat
        
        switch collectionView {
        case teamsCollectionView:
            width = frame.width - 16
            height = 50
        case gamesCollectionView:
            width = frame.width - 16
            height = 50
        default:
            width = frame.width - 16
            height = 50
        }
        
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        
        switch collectionView {
        case teamsCollectionView:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: teamId, for: indexPath) as! TMTeamCell
            
            if let teamId = currentUser?.team {
                cell.teamId = teamId
            } else {
                if indexPath.item == 0 {
                    cell.buttonType = .searchTeam
                } else if indexPath.item == 1 {
                    cell.buttonType = .createTeam
                }
            }
            
            cell.menu = self.menu
            
            return cell
        case gamesCollectionView:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: gameId, for: indexPath) as! TMGameCell
            
            guard let gameId = currentUser?.gameIds?[indexPath.item] else { return cell }
            cell.gameId = gameId
            
            return cell
        default:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath)
            
            cell.backgroundColor = .red
            
            return cell
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch collectionView {
        case teamsCollectionView:
            
            if self.currentUser?.team != nil {
                return 1
            } else {
                return 2
            }
        case gamesCollectionView:
            return self.currentUser?.gameIds?.count ?? 0
        default:
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch collectionView {
        case teamsCollectionView:
            
            let teamController = TeamController()
            teamController.team = teams[indexPath.item]
            
            menu?.handleDismiss()
            menu?.startController?.show(teamController, sender: menu?.startController)
            
        case gamesCollectionView:
            let gameController = GameController()
            let game = games[indexPath.item]
            gameController.game = game
            
            menu?.handleDismiss()
            menu?.startController?.show(gameController, sender: menu?.startController)
            
        default:
            break
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 4
    }
    
}

class BaseCell: UICollectionViewCell {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupCell()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupCell() {
        
    }
    
}
