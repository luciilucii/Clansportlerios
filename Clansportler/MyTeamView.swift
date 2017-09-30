//
//  MyTeamView.swift
//  Clansportler
//
//  Created by Luca Kiedrowski on 16.08.17.
//  Copyright © 2017 LucaKiedrowski. All rights reserved.
//

import UIKit
import Firebase


class MyTeamView: CustomView, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    var user: User? {
        didSet {
            
        }
    }
    
    var team: Team? {
        didSet {
            guard let imageUrl = team?.profileImageUrl else { return }
            teamImageView.loadImage(urlString: imageUrl)
            guard let teamname = team?.teamname else { return }
            self.teamnameLabel.text = teamname
            
        }
    }
    
    var userProfileController: UserProfileController?
    
    let cellId = "cellId"
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = ColorCodes.clansportlerBlue
        label.text = "My Clan"
        label.font = UIFont.boldSystemFont(ofSize: 16)
        return label
    }()
    
    lazy var teamImageView: CustomImageView = {
        let iv = CustomImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 5
        iv.isUserInteractionEnabled = true
        iv.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleShowTeam)))
        return iv
    }()
    
    let teamnameBlueView: UIView = {
        let view = UIView()
        view.backgroundColor = ColorCodes.clansportlerBlue
        view.layer.cornerRadius = 5
        return view
    }()
    
    let teamnameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.textAlignment = .center
        label.textColor = UIColor.white
        return label
    }()
    
    override func setupCustomView() {
        super.setupCustomView()
        
        self.backgroundColor = UIColor.white
        self.layer.cornerRadius = 5
        
        setupViews()
    }
    
    
    func setupViews() {
        addSubview(titleLabel)
        
        titleLabel.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 8, paddingLeft: 8, paddingBottom: 0, paddingRight: 8, width: 0, height: 20)
        
        addSubview(teamImageView)
        
        teamImageView.anchor(top: titleLabel.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 8, paddingLeft: 8, paddingBottom: 0, paddingRight: 8, width: 0, height: 125)
        
        teamImageView.addSubview(teamnameBlueView)
        
        
        teamnameBlueView.anchor(top: teamImageView.topAnchor, left: teamImageView.leftAnchor, bottom: nil, right: teamImageView.rightAnchor, paddingTop: 85, paddingLeft: 16, paddingBottom: 0, paddingRight: -5, width: 0, height: 30)
        
        teamnameBlueView.addSubview(teamnameLabel)
        teamnameLabel.anchor(top: teamnameBlueView.topAnchor, left: teamnameBlueView.leftAnchor, bottom: teamnameBlueView.bottomAnchor, right: teamnameBlueView.rightAnchor, paddingTop: 0, paddingLeft: 4, paddingBottom: 0, paddingRight: 9, width: 0, height: 0)
        
        
        
    }
    
    @objc func handleShowTeam() {
        let teamController = TeamController()
        teamController.team = self.team
        
        userProfileController?.navigationController?.pushViewController(teamController, animated: true)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! SuggestedTeamCell
        
        cell.backgroundColor = ColorCodes.clansportlerBlue
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width: CGFloat = 150
        let height: CGFloat = 120
        
        return CGSize(width: width, height: height)
    }
    
}












