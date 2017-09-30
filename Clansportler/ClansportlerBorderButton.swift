//
//  ClansportlerBorderButton.swift
//  Clansportler
//
//  Created by Luca Kiedrowski on 10.09.17.
//  Copyright © 2017 LucaKiedrowski. All rights reserved.
//

import UIKit

class ClansportlerBorderButton: UIButton {
    
    init(title: String, tintColor: UIColor) {
        super.init(frame: .zero)
        
        self.setTitle(title, for: .normal)
        self.setTitleColor(tintColor, for: .normal)
        self.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        self.layer.cornerRadius = 5
        self.backgroundColor = UIColor.clear
        self.layer.borderColor = tintColor.cgColor
        self.layer.borderWidth = 1
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
