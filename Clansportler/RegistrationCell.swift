//
//  RegistrationCell.swift
//  Clansportler
//
//  Created by Luca Kiedrowski on 05.08.17.
//  Copyright © 2017 LucaKiedrowski. All rights reserved.
//

import UIKit

enum RegistrationCellType {
    case username
    case email
    case password
    case profileImage
}

protocol RegistrationCellDelegate {
    func didTapContinue()
}

class RegistrationCell: BaseCell {
    
    var delegate: RegistrationCellDelegate?
    
    
    
    let inputTextField: CustomAnimatedTextField = {
        let tf = CustomAnimatedTextField()
//        tf.textField.addTarget(self, action: #selector(handleDidBeginEditing), for: .editingDidBegin)
        tf.textField.keyboardType = .emailAddress
        tf.animatedLabel.text = "Email Address"
        tf.backgroundColor = .white
        return tf
    }()
    
    func setupCell(cellType: RegistrationCellType) {
        super.setupCell()
        
        switch cellType {
        case .email:
            inputTextField.animatedLabel.text = "Email"
            inputTextField.isHidden = false
        case .password:
            inputTextField.animatedLabel.text = "Password"
            inputTextField.isHidden = false
        case .username:
            inputTextField.animatedLabel.text = "Username"
            inputTextField.isHidden = false
        case .profileImage:
            inputTextField.isHidden = true
        }
        
        addSubview(inputTextField)
//        addSubview(continueButton)
//        
//        continueButton.anchor(top: nil, left: nil, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 16, width: 100, height: 50)
        
        inputTextField.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 16, paddingLeft: 16, paddingBottom: 0, paddingRight: 16, width: 0, height: 50)
    }
    
    func handleContinue() {
        delegate?.didTapContinue()
    }
    
}
