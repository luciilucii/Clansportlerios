//
//  PlayerPickerView.swift
//  Clansportler
//
//  Created by Luca Kiedrowski on 31.08.17.
//  Copyright © 2017 LucaKiedrowski. All rights reserved.
//

import UIKit

class PlayerPickerView: CustomView {
    
    var currentNumber: Int = 1 {
        didSet {
            countLabel.text = "\(currentNumber)"
        }
    }
    
    var topLimit = 10
    var bottomLimit = 1
    
    lazy var plusButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "plus_icon").withRenderingMode(.alwaysTemplate), for: .normal)
        button.tintColor = UIColor.white
        button.imageView?.contentMode = .scaleAspectFit
        button.backgroundColor = .clear
        button.layer.cornerRadius = 5
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.white.cgColor
        button.addTarget(self, action: #selector(handlePlus), for: .touchUpInside)
        return button
    }()
    
    let countLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.white
        label.font = UIFont.systemFont(ofSize: 46)
        label.text = "1"
        label.textAlignment = .center
        label.layer.cornerRadius = 5
        label.layer.borderColor = UIColor.white.cgColor
        label.layer.borderWidth = 1
        return label
    }()
    
    lazy var minusButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "minus_icon").withRenderingMode(.alwaysTemplate), for: .normal)
        button.tintColor = UIColor.white
        button.imageView?.contentMode = .scaleAspectFit
        button.backgroundColor = .clear
        button.layer.cornerRadius = 5
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.white.cgColor
        button.addTarget(self, action: #selector(handleMinus), for: .touchUpInside)
        return button
    }()
    
    override func setupCustomView() {
        super.setupCustomView()
        
        addSubview(plusButton)
        addSubview(minusButton)
        addSubview(countLabel)
        
        
        plusButton.anchor(top: topAnchor, left: nil, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 50, height: 25)
        plusButton.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        countLabel.anchor(top: plusButton.bottomAnchor, left: nil, bottom: minusButton.topAnchor, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 75, height: 0)
        countLabel.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        
        minusButton.anchor(top: nil, left: nil, bottom: bottomAnchor, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 50, height: 25)
        minusButton.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
    }
    
    @objc func handlePlus() {
        if currentNumber < topLimit {
            currentNumber += 1
        }
    }
    
    @objc func handleMinus() {
        if currentNumber > bottomLimit {
            currentNumber -= 1
        }
    }
    
}










