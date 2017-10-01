//
//  TournamentDateView.swift
//  Clansportler
//
//  Created by Luca Kiedrowski on 01.10.17.
//  Copyright © 2017 LucaKiedrowski. All rights reserved.
//

import UIKit

class TournamentDateView: CustomView {
    
    var tournament: Tournament? {
        didSet {
            
        }
    }
    
    let dateLabel: UILabel = {
        let label = UILabel()
        label.text = "Sat. 20.08.2017\n8pm"
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.numberOfLines = 2
        return label
    }()
    
    override func setupCustomView() {
        super.setupCustomView()
        
        self.backgroundColor = UIColor.white
        self.layer.cornerRadius = 5
        self.clipsToBounds = true
        
        setupViews()
    }
    
    fileprivate func setupViews() {
        
        //Height is 66px
        addSubview(dateLabel)
        
        dateLabel.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: centerXAnchor, paddingTop: 8, paddingLeft: 8, paddingBottom: 0, paddingRight: 4, width: 0, height: 50)
    }
    
}









