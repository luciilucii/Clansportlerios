//
//  HomeController.swift
//  Clansportler
//
//  Created by Luca Kiedrowski on 30.07.17.
//  Copyright © 2017 LucaKiedrowski. All rights reserved.
//

import UIKit
import Firebase

class HomeController: UICollectionViewController, UICollectionViewDelegateFlowLayout, OnlineCellDelegate {
    
    var menu: Menu?
    
    let cellId = "cellId"
    let welcomeId = "defaultId"
    let onlineId = "onlineId"
    let groupId = "groupId"
    
    var currentUser: User? {
        didSet {
            
            collectionView?.reloadData()
        }
    }
    
    @objc func showUpdater() {
        _ = Updater()
        
    }
    
    let purplePointView: UIView = {
        let view = UIView()
        view.backgroundColor = ColorCodes.clansportlerPurple
        view.layer.cornerRadius = 5
        view.isHidden = true
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchCurrentUser()
        checkIfMenuIsSet()
        
        setupNavBarButtons()
        setupCollectionView()
        
        setupPurpleOnlineButton()
        navigationController?.navigationBar.isTranslucent = false
        
        _ = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(showUpdater), userInfo: nil, repeats: false)
    }
    
    @objc func showOnboardingController() {
        let onboardingController = OnboardingController()
        self.present(onboardingController, animated: true) {
            //completion here
            
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let timestamp = Date().timeIntervalSince1970
        let values: [String: Any] = ["homeControllerLastVisit": timestamp]
        
        uploadOnlineStatusToDatabase(values: values)
    }
    
    func uploadOnlineStatusToDatabase(values: [String: Any]) {
        guard let currentUserId = currentUser?.id else { return }
        
        let userRef = Database.database().reference().child("users").child(currentUserId)
        userRef.updateChildValues(values, withCompletionBlock: { (err, _) in
            if let err = err {
                print("failed to update online status", err)
            }
        })
    }
    
    func setupCollectionView() {
        collectionView?.backgroundColor = ColorCodes.backgroundGrey
        collectionView?.alwaysBounceVertical = true
        
        collectionView?.contentInset = UIEdgeInsetsMake(8, 0, 8, 0)
        
        collectionView?.register(UICollectionViewCell.self, forCellWithReuseIdentifier: cellId)
        collectionView?.register(WelcomeCell.self, forCellWithReuseIdentifier: welcomeId)
        collectionView?.register(OnlineCell.self, forCellWithReuseIdentifier: onlineId)
        collectionView?.register(SuggestedGroupsCell.self, forCellWithReuseIdentifier: groupId)
    }
    
    func fetchCurrentUser() {
        
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        let currentUserRef = Database.database().reference().child("users").child(userId)
        currentUserRef.observeSingleEvent(of: .value, with: { (snapshot) in
            
            guard let dictionary = snapshot.value as? [String: Any] else { return }
            
            self.currentUser = User(uid: userId, dictionary: dictionary)
            
        }) { (error) in
            print("failed to fetch current user:", error)
        }
        
    }
    
    fileprivate func checkIfMenuIsSet() {
        if menu == nil {
            menu = Menu()
            menu?.startController = self
        }
    }
    
    fileprivate func setupNavBarButtons() {
        let menuButton = UIBarButtonItem(image: #imageLiteral(resourceName: "Gruppe 5").withRenderingMode(.alwaysTemplate), style: .plain, target: self, action: #selector(handleMenu))
        menuButton.tintColor = .white
        navigationItem.leftBarButtonItem = menuButton
        
        setupWhiteTitle(title: "Home")
        
        let searchButton = UIBarButtonItem(image: #imageLiteral(resourceName: "search_icon_new").withRenderingMode(.alwaysTemplate), style: .plain, target: self, action: #selector(handleSearch))
        searchButton.tintColor = UIColor.white
        navigationItem.rightBarButtonItem = searchButton
    }
    
    func setupPurpleOnlineButton() {
        let navBar = navigationController?.navigationBar
        
        navBar?.addSubview(purplePointView)
        purplePointView.anchor(top: navBar?.topAnchor, left: navBar?.leftAnchor, bottom: nil, right: nil, paddingTop: 8, paddingLeft: 42, paddingBottom: 0, paddingRight: 0, width: 10, height: 10)
    }
    
    @objc func handleMenu() {
        menu?.showMenu()
        menu?.currentUser = currentUser
        menu?.homeController = self
    }
    
    @objc func handleSearch() {
        let layout = UICollectionViewFlowLayout()
        let searchController = SearchController(collectionViewLayout: layout)
        let navController = UINavigationController(rootViewController: searchController)
        self.present(navController, animated: true) {
            //completion here
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        switch indexPath.item {
        case 0:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: welcomeId, for: indexPath) as! WelcomeCell
            
            cell.user = self.currentUser
            
            return cell
        case 1:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: onlineId, for: indexPath) as! OnlineCell
            
            cell.currentUser = self.currentUser
            cell.homeController = self
            cell.delegate = self
            
            return cell
        case 2:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: groupId, for: indexPath) as! SuggestedGroupsCell
            
            cell.homeController = self
            cell.currentUser = self.currentUser
            
            return cell
            
            
        default:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath)
            
            return cell
        }
        
    }
    
    func isOnline() {
        purplePointView.isHidden = false
    }
    
    func isOffline() {
        purplePointView.isHidden = true
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width: CGFloat = view.frame.width - 16
        let height: CGFloat
        
        
        switch indexPath.item {
        case 0:
            height = 185
        case 1:
            height = 253
        case 2:
            height = 283
        default:
            height = 150
        }
        
        return CGSize(width: width, height: height)
    }
    
}













