//
//  TMTeamCell.swift
//  Clansportler
//
//  Created by Luca Kiedrowski on 20.08.17.
//  Copyright © 2017 LucaKiedrowski. All rights reserved.
//

import UIKit
import Firebase

enum ButtonType {
    case searchTeam
    case createTeam
}

class TMTeamCell: BaseCell {
    
    var menu: Menu?
    
    var teamId: String? {
        didSet {
            guard let teamId = teamId else { return }
            setupViews()
            fetchTeam(withId: teamId)
        }
    }
    
    var team: Team? {
        didSet {
            guard let teamname = team?.teamname else { return }
            teamnameLabel.text = teamname
            
            guard let imageUrl = team?.profileImageUrl else { return }
            teamImageView.loadImage(urlString: imageUrl)
            teamImageBackgroundView.loadImage(urlString: imageUrl)
            
            guard let member = team?.member else { return }
            memberLabel.text = "\(member.count) member"
        }
    }
    
    var buttonType: ButtonType? {
        didSet {
            if buttonType == .searchTeam {
                setupSearchTeamButton()
            } else if buttonType == .createTeam {
                setupCreateTeamButton()
            }
        }
    }
    
    let teamImageView: CustomImageView = {
        let iv = CustomImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.borderColor = UIColor.white.cgColor
        iv.layer.borderWidth = 1
        return iv
    }()
    
    let teamImageBackgroundView: CustomImageView = {
        let iv = CustomImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        return iv
    }()
    
    let backgroundLayerView: UIView = {
        let view = UIView()
        view.backgroundColor = ColorCodes.middleGrey
        view.alpha = 0.75
        return view
    }()
    
    let teamnameLabel: UILabel = {
        let label = UILabel()
        label.textColor = ColorCodes.backgroundGrey
        label.font = UIFont.boldSystemFont(ofSize: 16)
        return label
    }()
    
    let memberLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = ColorCodes.backgroundGrey
        return label
    }()
    
    lazy var searchTeamButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Search a Team", for: .normal)
        button.backgroundColor = ColorCodes.darkestGrey
        button.setTitleColor(UIColor.white, for: .normal)
        button.layer.borderColor = UIColor.white.cgColor
        button.layer.borderWidth = 1
        button.layer.cornerRadius = 5
        button.addTarget(self, action: #selector(handleSearchTeam), for: .touchUpInside)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        return button
    }()
    
    lazy var createTeamButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Create a Team", for: .normal)
        button.backgroundColor = ColorCodes.clansportlerRed
        button.setTitleColor(UIColor.white, for: .normal)
        button.layer.cornerRadius = 5
        button.addTarget(self, action: #selector(handleCreateTeam), for: .touchUpInside)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        return button
    }()
    
    override func setupCell() {
        super.setupCell()
        
        clipsToBounds = true
        self.layer.cornerRadius = 5
        backgroundColor = .white
        
        
    }
    
    func fetchTeam(withId: String) {
        
        Database.fetchTeamWithId(uid: withId) { (team) in
            self.team = team
        }
        
    }
    
    func setupViews() {
        

        addSubview(teamImageBackgroundView)
        
        teamImageBackgroundView.anchor(top: nil, left: nil, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 80, height: 80)
        teamImageBackgroundView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        teamImageBackgroundView.layer.cornerRadius = 80 / 2
        
        
        teamImageBackgroundView.centerXAnchor.constraint(equalTo: leftAnchor, constant: 10).isActive = true
        
        addSubview(backgroundLayerView)
        
        backgroundLayerView.anchor(top: nil, left: nil, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 80, height: 80)
        backgroundLayerView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        backgroundLayerView.layer.cornerRadius = 80 / 2
        
        
        backgroundLayerView.centerXAnchor.constraint(equalTo: leftAnchor, constant: 10).isActive = true
        
        
        addSubview(teamImageView)
        
        addSubview(teamnameLabel)
        addSubview(memberLabel)
        
        teamImageView.anchor(top: nil, left: nil, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 60, height: 60)
        teamImageView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        teamImageView.layer.cornerRadius = 60 / 2
        
        teamImageView.centerXAnchor.constraint(equalTo: leftAnchor, constant: 10).isActive = true
        
        teamnameLabel.anchor(top: topAnchor, left: teamImageBackgroundView.rightAnchor, bottom: nil, right: rightAnchor, paddingTop: 6, paddingLeft: 4, paddingBottom: 0, paddingRight: 8, width: 0, height: 20)
        
        memberLabel.anchor(top: teamnameLabel.bottomAnchor, left: teamnameLabel.leftAnchor, bottom: nil, right: teamnameLabel.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 20)
        
        
    }
    
    func setupSearchTeamButton() {
        
        addSubview(searchTeamButton)
        
        searchTeamButton.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        
    }
    
    func setupCreateTeamButton() {
        addSubview(createTeamButton)
        
        createTeamButton.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
    }
    
    @objc func handleSearchTeam() {
        
        closeMenu { (controller) in
            
            let layout = UICollectionViewFlowLayout()
            let searchTeamController = SearchTeamController(collectionViewLayout: layout)
            let navController = UINavigationController(rootViewController: searchTeamController)
            
            controller.present(navController, animated: true, completion: {
                //completion here
            })
            
        }
        
    }
    
    func closeMenu(completion: @escaping(MainTabBarController) ->()) {
        let mainTabBarController = MainTabBarController()
        guard let controller = mainTabBarController.viewControllers?[0] as? UINavigationController else { return }
        
        guard let homeController = controller.viewControllers[0] as? HomeController else { return }
        
        homeController.menu = menu
        
        menu?.startController?.present(mainTabBarController, animated: false, completion: {
            //code here
            
            completion(mainTabBarController)
            
            self.menu?.handleDismiss()
        })
        homeController.menu?.startController = homeController
    }
    
    @objc func handleCreateTeam() {
        
        closeMenu { (controller) in
            
            let createTeamController = CreateTeamController()
            let navController = UINavigationController(rootViewController: createTeamController)
            
            controller.present(navController, animated: true, completion: { 
                //completion here
            })
            
        }
        
    }
    
}















