//
//  MainTabBarController.swift
//  Clansportler
//
//  Created by Luca Kiedrowski on 30.07.17.
//  Copyright © 2017 LucaKiedrowski. All rights reserved.
//

import UIKit
import Firebase
import FirebaseMessaging

class MainTabBarController: UITabBarController {
    
    static let updateControllerNotification = Notification.Name("UpdateMainTabBarController")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.reloadInputViews()
        
        tabBar.barTintColor = ColorCodes.darkestGrey
        
        tabBar.tintColor = ColorCodes.clansportlerDarkBlue
        tabBar.isTranslucent = false
        
        if Auth.auth().currentUser == nil {
            
            DispatchQueue.main.async {
                let layout = UICollectionViewFlowLayout()
                let loginController = LoginController(collectionViewLayout: layout)
                
                self.present(loginController, animated: true, completion: nil)
            }
            
            return
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleSetupController), name: MainTabBarController.updateControllerNotification, object: nil)
        
        UIApplication.shared.applicationIconBadgeNumber = 0
        
        setupViewControllers()
        
        
    }
    
    @objc func handleSetupController() {
        setupViewControllers()
    }
    
    func setupViewControllers() {
        
        let layout = UICollectionViewFlowLayout()
        let homeNavController = templateNavController(unselectedImage: #imageLiteral(resourceName: "home_icon_new"), selectedImage: #imageLiteral(resourceName: "home_icon_new"), rootViewController: HomeController(collectionViewLayout: UICollectionViewFlowLayout()))
        
        let searchLayout = UICollectionViewFlowLayout()
        let searchNavController = templateNavController(unselectedImage: #imageLiteral(resourceName: "tournament_icon_new"), selectedImage: #imageLiteral(resourceName: "tournament_icon_new"), rootViewController: TournamentsController(collectionViewLayout: searchLayout))
        
        let groupNavController = templateNavController(unselectedImage: #imageLiteral(resourceName: "groups_icon_new"), selectedImage: #imageLiteral(resourceName: "groups_icon_new"), rootViewController: GroupsController(collectionViewLayout: layout))
        
        let updatesNavController = templateNavController(unselectedImage: #imageLiteral(resourceName: "inbox_icon_new"), selectedImage: #imageLiteral(resourceName: "inbox_icon_new"), rootViewController: UpdatesController(collectionViewLayout: UICollectionViewFlowLayout()))
        
        let userNavController = templateNavController(unselectedImage: #imageLiteral(resourceName: "profile_icon_new"), selectedImage: #imageLiteral(resourceName: "profile_icon_new"), rootViewController: UserProfileController())
        
        viewControllers = [homeNavController, searchNavController, groupNavController, updatesNavController, userNavController]
        
        guard let items = tabBar.items else { return }
        
        for item in items {
            item.imageInsets = UIEdgeInsetsMake(4, 0, -4, 0)
        }
        
        checkIfUserIsInGroup()
        
    }
    
    fileprivate func checkIfUserIsInGroup() {
        
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
        
        let userRef = Database.database().reference().child("users").child(currentUserId)
        userRef.observeSingleEvent(of: .value, with: { (snapshot) in
            guard let dictionary = snapshot.value as? [String: Any] else { return }
            
            if dictionary[Group.currentGroupDatabase] != nil {
                
                guard let groupId = dictionary[Group.currentGroupDatabase] as? String else { return }
                self.showGroupController(groupId: groupId)
            }
        }) { (err) in
            print("failed to fetch currentUser", err)
        }
        
    }
    
    fileprivate func showGroupController(groupId: String) {
        
        
        Database.fetchAndObserveGroupWithId(id: groupId) { (fetchedGroup) in
            let openGroupController = OpenGroupController()
            openGroupController.group = fetchedGroup
            
            let navController = UINavigationController(rootViewController: openGroupController)
            self.present(navController, animated: true, completion: {
                //completion here
                
                openGroupController.reloadGroup()
                
            })
        }
        
    }
    
    fileprivate func templateNavController(unselectedImage: UIImage, selectedImage: UIImage, rootViewController: UIViewController = UIViewController()) -> UINavigationController {
        let viewController = rootViewController
        let navController = UINavigationController(rootViewController: viewController)
        
        let icon = unselectedImage.withRenderingMode(.alwaysOriginal)
        
        navController.tabBarItem.image = icon
        navController.tabBarItem.selectedImage = selectedImage
        
        return navController
    }
    
}
