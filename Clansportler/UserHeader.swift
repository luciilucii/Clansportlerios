//
//  UserHeader.swift
//  Clansportler
//
//  Created by Luca Kiedrowski on 26.08.17.
//  Copyright © 2017 LucaKiedrowski. All rights reserved.
//

import UIKit

class UserHeader: BaseCell, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, MemberCellDelegate {
    
    let cellId = "cellId"
    
    var tabbedUser = [User]() {
        didSet {
            collectionView.reloadData()
        }
    }
    
    var selectUserController: SelectUserCollectionViewController? 
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.delegate = self
        cv.dataSource = self
        cv.backgroundColor = UIColor.white
        return cv
    }()
    
    override func setupCell() {
        super.setupCell()
        
        setupCollectionView()
        
        addSubview(collectionView)
        
        collectionView.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        
        
    }
    
    fileprivate func setupCollectionView() {
        collectionView.register(MemberCell.self, forCellWithReuseIdentifier: cellId)
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.alwaysBounceHorizontal = true
    }
    
    func didTapCancel(user: User) {
        
        let index = tabbedUser.index { (tUser) -> Bool in
            return user.id == tUser.id
        }
        
        if let userIndex = index {
            tabbedUser.remove(at: userIndex)
            selectUserController?.tabbedUsers = tabbedUser
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width: CGFloat = 100
        let height: CGFloat = 125
        
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tabbedUser.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! MemberCell
        
        cell.delegate = self
        cell.user = tabbedUser[indexPath.item]
        cell.usernameLabel.textColor = ColorCodes.clansportlerBlue
        
        cell.checkmarkImageView.isHidden = true
        
        cell.cancelButton.isHidden = false
        cell.cancelButton.isEnabled = true
        
        return cell
    }
    
}
