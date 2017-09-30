//
//  GameAccountsSettingController.swift
//  Clansportler
//
//  Created by Luca Kiedrowski on 20.09.17.
//  Copyright © 2017 LucaKiedrowski. All rights reserved.
//

import UIKit
import Firebase

class GameAccountsSettingController: ScrollController {
    
    var currentUser: User?
    
    let cardImageView: UIImageView = {
        let iv = UIImageView()
        iv.tintColor = UIColor.white
        iv.contentMode = .scaleAspectFit
        iv.image = #imageLiteral(resourceName: "playernames_settings_psd").withRenderingMode(.alwaysTemplate)
        return iv
    }()
    
    let moreToComeLabel: UILabel = {
        let label = UILabel()
        label.text = "This Section is coming soon."
        label.textAlignment = .center
        label.textColor = UIColor.white
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
        Database.fetchUserWithUID(uid: currentUserId) { (user) in
            self.currentUser = user
        }
        scrollContainerView.backgroundColor = ColorCodes.backgroundGrey
        
        super.setupScrollView(height: view.frame.height)
        
        super.setupController()
        
        navigationController?.navigationBar.tintColor = .white
        
        setupViews()
        
        hideKeyboardWhenTappedAround(views: [scrollContainerView, scrollView, view])
    }
    
    override func setupViews() {
        scrollContainerView.addSubview(cardImageView)
        scrollContainerView.addSubview(moreToComeLabel)
        
        cardImageView.anchor(top: scrollContainerView.topAnchor, left: nil, bottom: nil, right: nil, paddingTop: 25, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 200, height: 150)
        cardImageView.centerXAnchor.constraint(equalTo: scrollContainerView.centerXAnchor).isActive = true
        
        moreToComeLabel.anchor(top: cardImageView.bottomAnchor, left: scrollContainerView.leftAnchor, bottom: nil, right: scrollContainerView.rightAnchor, paddingTop: 16, paddingLeft: 8, paddingBottom: 0, paddingRight: 8, width: 0, height: 30)
        
    }
    
}
