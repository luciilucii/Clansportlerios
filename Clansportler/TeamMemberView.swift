//
//  TeamMembersView.swift
//  Clansportler
//
//  Created by Luca Kiedrowski on 18.08.17.
//  Copyright © 2017 LucaKiedrowski. All rights reserved.
//

import UIKit
import Firebase

class TeamMemberView: CustomView, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    let cellId = "cellId"
    
    var teamController: TeamController? {
        didSet {
            self.team = teamController?.team
        }
    }
    
    var team: Team? {
        didSet {
            guard let member = team?.member else { return }
            fetchTeamMember(member: member)
        }
    }
    
    var member = [User]() {
        didSet {
            collectionView.reloadData()
        }
    }
    
    let sectionTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Clan Member"
        label.textColor = .white
        label.font = UIFont.boldSystemFont(ofSize: 16)
        return label
    }()
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.delegate = self
        cv.dataSource = self
        cv.alwaysBounceVertical = false
        return cv
    }()
    
    lazy var seeMoreButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("See All Members", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.setTitleColor(ColorCodes.clansportlerRed, for: .normal)
        button.addTarget(self, action: #selector(handleSeeMore), for: .touchUpInside)
        return button
    }()
    
    override func setupCustomView() {
        super.setupCustomView()
        
        backgroundColor = ColorCodes.clansportlerBlue
        layer.cornerRadius = 5
        clipsToBounds = true
        
        setupCollectionView()
        setupViews()
        
    }
    
    //NOTE: Collectionview height is 255 when there are 3 or 4 cells
    
    func setupViews() {
        addSubview(sectionTitleLabel)
        addSubview(seeMoreButton)
        addSubview(collectionView)
        
        sectionTitleLabel.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 200, height: 30)
        collectionView.anchor(top: sectionTitleLabel.bottomAnchor, left: leftAnchor, bottom: seeMoreButton.topAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        seeMoreButton.anchor(top: nil, left: nil, bottom: bottomAnchor, right: rightAnchor, paddingTop: 8, paddingLeft: 0, paddingBottom: 0, paddingRight: 8, width: 135, height: 30)
        
    }
    
    func setupCollectionView() {
        collectionView.register(MemberCell.self, forCellWithReuseIdentifier: cellId)
        collectionView.backgroundColor = ColorCodes.clansportlerBlue
        
        collectionView.contentInset = UIEdgeInsetsMake(0, 28, 0, 28)
    }
    
    func fetchTeamMember(member: [String]) {
        member.forEach { (memberId) in
            fetchUser(userId: memberId)
        }
        
    }
    
    fileprivate func fetchUser(userId: String) {
        
        let userRef = Database.database().reference().child("users").child(userId)
        userRef.observeSingleEvent(of: .value, with: { (snapshot) in
            
            guard let dictionary = snapshot.value as? [String: Any] else { return }
            let user = User(uid: userId, dictionary: dictionary)
            self.member.append(user)
            self.collectionView.reloadData()
            
        }) { (err) in
            print("failed to fetch user", err)
        }
        
    }
    
    @objc func handleSeeMore() {
        let layout = UICollectionViewFlowLayout()
        let memberController = MemberController(collectionViewLayout: layout)
        memberController.type = .clan
        memberController.member = self.member
        
        teamController?.navigationController?.pushViewController(memberController, animated: true)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if member.count > 2 {
            return 2
        } else {
            return member.count
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! MemberCell
        
        cell.user = member[indexPath.item]
        
        cell.profileImageView.layer.borderColor = UIColor.white.cgColor
        cell.usernameLabel.textColor = UIColor.white
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let user = member[indexPath.item]
        
        let userProfileController = UserProfileController()
        userProfileController.user = user
//        userProfileController.userId = user.id
        
        teamController?.show(userProfileController, sender: self)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width: CGFloat = 100
        let height: CGFloat = 125
        
        return CGSize(width: width, height: height)
    }
    
}
