//
//  MessageHeader.swift
//  Clansportler
//
//  Created by Luca Kiedrowski on 31.07.17.
//  Copyright © 2017 LucaKiedrowski. All rights reserved.
//

import UIKit

class MessageHeader: UITableViewHeaderFooterView {
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        
        let view = UIView()
        view.frame = frame
        view.backgroundColor = ColorCodes.darkestGrey
        
        backgroundView = view
        
        addSubview(titleLabel)
        
        titleLabel.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 8, width: 0, height: 0)
    }
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.white
        label.font = UIFont.boldSystemFont(ofSize: 12)
        return label
    }()
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
