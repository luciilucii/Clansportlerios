//
//  CreateTournamentRegistrationController.swift
//  Clansportler
//
//  Created by Luca Kiedrowski on 30.09.17.
//  Copyright © 2017 LucaKiedrowski. All rights reserved.
//

import UIKit
import Firebase

class CreateTournamentRegistrationController: ScrollController {
    
    var values: [String: Any]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        super.setupScrollView(height: 1500)
        super.setupController()
        
        hideKeyboardWhenTappedAround(views: [view, scrollContainerView, scrollView])
        
        scrollView.backgroundColor = ColorCodes.clansportlerBlue
        scrollContainerView.backgroundColor = ColorCodes.clansportlerBlue
        
        setupViews()
    }
    
    override func setupViews() {
        
        
        
    }
    
}
