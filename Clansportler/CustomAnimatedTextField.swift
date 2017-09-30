//
//  CustomAnimatedTextField.swift
//  Clansportler
//
//  Created by Luca Kiedrowski on 03.08.17.
//  Copyright © 2017 LucaKiedrowski. All rights reserved.
//

import UIKit

class CustomAnimatedTextField: UIView, UITextFieldDelegate {
    
    var title = "Placeholder"
    
    lazy var textField: UITextField = {
        let tf = UITextField()
        tf.delegate = self
        tf.textColor = UIColor.darkGray
        return tf
    }()
    
    lazy var animatedLabel: UILabel = {
        let label = UILabel()
        label.text = self.title
        label.textColor = .lightGray
        label.font = UIFont.systemFont(ofSize: 12)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let nonAnimatedSeperatorView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red:0.92, green:0.92, blue:0.92, alpha:1.0)
        return view
    }()
    
    let seperatorView: UIView = {
        let view = UIView()
        view.backgroundColor = ColorCodes.clansportlerBlue
        return view
    }()
    
    var animatedLabelHeightAnchor: NSLayoutConstraint?
    var animatedLabelLeftAnchor: NSLayoutConstraint?
    
    var seperatorWidthAnchor: NSLayoutConstraint?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(textField)
        addSubview(animatedLabel)
        addSubview(nonAnimatedSeperatorView)
        addSubview(seperatorView)
        
        textField.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 8, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        
        animatedLabel.anchor(top: topAnchor, left: nil, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        
        animatedLabelLeftAnchor = animatedLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 0)
        animatedLabelLeftAnchor?.isActive = true
        
        animatedLabelHeightAnchor = animatedLabel.heightAnchor.constraint(equalToConstant: 20)
        animatedLabelHeightAnchor?.isActive = true
        
        
        nonAnimatedSeperatorView.anchor(top: nil, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 2)
        
        
        seperatorView.anchor(top: nil, left: nil, bottom: bottomAnchor, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 2)
        
        seperatorView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        
        seperatorWidthAnchor = seperatorView.widthAnchor.constraint(equalToConstant: 0)
        seperatorWidthAnchor?.isActive = true
        
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        
        seperatorWidthAnchor?.constant = frame.width
        
        UIView.animate(withDuration: 0.3) {
            self.layoutIfNeeded()
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        seperatorWidthAnchor?.constant = 0
        UIView.animate(withDuration: 0.3) {
            self.layoutIfNeeded()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
