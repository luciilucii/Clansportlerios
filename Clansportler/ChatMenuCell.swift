//
//  ChatMenuCell.swift
//  Clansportler
//
//  Created by Luca Kiedrowski on 30.07.17.
//  Copyright © 2017 LucaKiedrowski. All rights reserved.
//

import UIKit
import Firebase

class ChatMenuCell: BaseCell, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    let navBarContainer: UIView = {
        let view = UIView()
        
        view.backgroundColor = ColorCodes.darkestGrey
        
        let seperatorView = UIView()
        seperatorView.backgroundColor = UIColor.white
        
        view.addSubview(seperatorView)
        seperatorView.anchor(top: nil, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0.5)
        
        return view
    }()
    
    var currentUser: User?
    var menu: Menu? {
        didSet {
//            collectionView.reloadData()
        }
    }
    
    var team: Team?
    
    func setupNavBarContainer() {
        navBarContainer.addSubview(chatTitlelabel)
        
        chatTitlelabel.anchor(top: navBarContainer.topAnchor, left: navBarContainer.leftAnchor, bottom: navBarContainer.bottomAnchor, right: navBarContainer.rightAnchor, paddingTop: 2, paddingLeft: 8, paddingBottom: 2, paddingRight: 8, width: 0, height: 0)
        
    }
    
    let chatTitlelabel: UILabel = {
        let label = UILabel()
        label.text = "Chats"
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.textColor = UIColor.white
        return label
    }()
    
    let searchBar: UISearchBar = {
        let sb = UISearchBar()
        sb.tintColor = UIColor.white
        sb.barTintColor = ColorCodes.darkestGrey
        sb.searchBarStyle = .minimal
        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).backgroundColor = ColorCodes.darkestGrey
        return sb
    }()
    
    let cellId = "cellId"
    let headerId = "headerId"
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = ColorCodes.darkestGrey
        cv.dataSource = self
        cv.delegate = self
        cv.alwaysBounceVertical = true
        return cv
    }()
    
    override func setupCell() {
        super.setupCell()
        
        hideKeyboardWhenTapped()
        setupNavBarContainer()
        setupSearchBar()
        
        backgroundColor = UIColor(red:0.21, green:0.25, blue:0.28, alpha:1.0)
        
        collectionView.register(MessagesCell.self, forCellWithReuseIdentifier: cellId)
        collectionView.register(ChatMenuCellHeader.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: headerId)
        
        addSubview(navBarContainer)
        addSubview(collectionView)
        
        navBarContainer.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 45)
        
        collectionView.anchor(top: navBarContainer.bottomAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 32, paddingRight: 0, width: 0, height: 0)
    }
    
    func setupSearchBar() {
        let textFieldInSearchBar = searchBar.value(forKey: "searchField") as? UITextField
        textFieldInSearchBar?.textColor = UIColor.white
    }
    
    func loadTeam(teamId: String) {
        
        let teamRef = Database.database().reference().child("teams").child(teamId)
        teamRef.observeSingleEvent(of: .value, with: { (snapshot) in
            
            guard let dictionary = snapshot.value as? [String: Any] else { return }
            self.team = Team(uid: teamId, values: dictionary)
            
        }) { (err) in
            print("failed to fetch Team", err)
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let width = collectionView.frame.width
        let height: CGFloat = 110
        
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerId, for: indexPath) as! ChatMenuCellHeader
        
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.width
        let height: CGFloat = collectionView.frame.height - 110
        
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! MessagesCell
        
        cell.menu = menu
        cell.user = currentUser
        
        return cell
    }
    
    func hideKeyboardWhenTapped() {
        self.addGestureRecognizer(setupGestureRecognizer())
    }
    
    func dismissKeyboard() {
        self.endEditing(true)
    }
    
    func setupGestureRecognizer() -> UITapGestureRecognizer {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        return tap
    }
    
}
