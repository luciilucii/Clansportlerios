//
//  ClansportlerRedButton.swift
//  Clansportler
//
//  Created by Luca Kiedrowski on 10.09.17.
//  Copyright © 2017 LucaKiedrowski. All rights reserved.
//

import UIKit

class ClansportlerRedButton: UIButton {
    
    
    
    required init(title: String) {
//        super.init(type: .system)
        super.init(frame: .zero)
        
        self.setTitle(title, for: .normal)
        self.setTitleColor(UIColor.white, for: .normal)
        self.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        self.layer.cornerRadius = 5
        self.backgroundColor = ColorCodes.clansportlerRed
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
