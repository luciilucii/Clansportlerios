//
//  GroupHeader.swift
//  Clansportler
//
//  Created by Luca Kiedrowski on 09.09.17.
//  Copyright © 2017 LucaKiedrowski. All rights reserved.
//

import UIKit

class GroupHeader: BaseCell {
    
    let groupImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = #imageLiteral(resourceName: "Group_header")
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    
    override func setupCell() {
        super.setupCell()
        
        backgroundColor = .clear
        
        addSubview(groupImageView)
        
        groupImageView.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 4, paddingLeft: 8, paddingBottom: 4, paddingRight: 8, width: 0, height: 0)
    }
    
}
