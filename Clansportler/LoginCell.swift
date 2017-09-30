//
//  LoginCell.swift
//  Clansportler
//
//  Created by Luca Kiedrowski on 03.08.17.
//  Copyright © 2017 LucaKiedrowski. All rights reserved.
//

import UIKit

class LoginCell: BaseCell {
    
    var onboardingPoint: OnboardingPoint? {
        didSet {
            self.iconImageView.image = onboardingPoint?.image
            
            self.subtitleLabel.text = onboardingPoint?.subtitle
            
            self.titleLabel.text = onboardingPoint?.name.rawValue
        }
    }
    
    
    override func setupCell() {
        super.setupCell()
        
        backgroundColor = .clear
        
        
        addSubview(titleLabel)
        addSubview(subtitleLabel)
        addSubview(iconImageView)
        
        titleLabel.anchor(top: nil, left: leftAnchor, bottom: subtitleLabel.topAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 16, paddingBottom: 8, paddingRight: 16, width: 0, height: 30)
        
        subtitleLabel.anchor(top: nil, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 16, paddingBottom: 48, paddingRight: 0, width: 0, height: 50)
        
        iconImageView.anchor(top: topAnchor, left: leftAnchor, bottom: titleLabel.topAnchor, right: rightAnchor, paddingTop: 33, paddingLeft: 16, paddingBottom: 8, paddingRight: 16, width: 0, height: 0)
    }
    
    let iconImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.image = #imageLiteral(resourceName: "logo_blue_transparent").withRenderingMode(.alwaysTemplate)
        iv.tintColor = UIColor.white
        return iv
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 24)
        label.textColor = UIColor.white
        label.textAlignment = .center
        return label
    }()
    
    let subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18)
        label.textColor = UIColor.white
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
}
