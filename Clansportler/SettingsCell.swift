//
//  SettingsCell.swift
//  Clansportler
//
//  Created by Luca Kiedrowski on 27.08.17.
//  Copyright © 2017 LucaKiedrowski. All rights reserved.
//

import UIKit

class SettingsCell: BaseCell {
    
    var singleSetting: SingleSetting? {
        didSet {
            guard let settingName = singleSetting?.name.rawValue else { return }
            settingLabel.text = settingName
            
            if let image = singleSetting?.icon {
                self.iconImageView.image = image
            }
        }
    }
    
    let settingLabel: UILabel = {
        let label = UILabel()
        label.textColor = ColorCodes.backgroundGrey
        label.font = UIFont.boldSystemFont(ofSize: 16)
        return label
    }()
    
    let iconImageView: UIImageView = {
        let iv = UIImageView()
        iv.tintColor = ColorCodes.backgroundGrey
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    
    override func setupCell() {
        super.setupCell()
        
        backgroundColor = UIColor.white
        self.clipsToBounds = true
        self.layer.cornerRadius = 5
        
        setupViews()
    }
    
    func setupViews() {
        addSubview(iconImageView)
        addSubview(settingLabel)
        
        iconImageView.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: nil, paddingTop: 12, paddingLeft: 8, paddingBottom: 12, paddingRight: 0, width: 42, height: 0)
        
        settingLabel.anchor(top: topAnchor, left: iconImageView.rightAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 8, width: 0, height: 0)
        
    }
    
}
