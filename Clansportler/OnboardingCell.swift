//
//  OnboardingCell.swift
//  Clansportler
//
//  Created by Luca Kiedrowski on 24.09.17.
//  Copyright © 2017 LucaKiedrowski. All rights reserved.
//

import UIKit

class OnboardingCell: BaseCell {
    
    var onboardingPoint: OnboardingPoint? {
        didSet {
            if let gifname = onboardingPoint?.gifname {
                self.iconImageView.loadGif(name: gifname)
            }
            if let image = onboardingPoint?.image {
                self.iconImageView.image = image
            }
            
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
        
        titleLabel.anchor(top: nil, left: leftAnchor, bottom: subtitleLabel.topAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 16, paddingBottom: 8, paddingRight: 16, width: 0, height: 50)
        
        subtitleLabel.anchor(top: nil, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 16, paddingBottom: 0, paddingRight: 0, width: 0, height: 120)
        
        iconImageView.anchor(top: topAnchor, left: leftAnchor, bottom: titleLabel.topAnchor, right: rightAnchor, paddingTop: 16, paddingLeft: 8, paddingBottom: 8, paddingRight: 8, width: 0, height: 0)
    }
    
    let iconImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.textColor = ColorCodes.backgroundGrey
        label.textAlignment = .center
        label.numberOfLines = 2
        return label
    }()
    
    let subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18)
        label.textColor = ColorCodes.backgroundGrey
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
}
