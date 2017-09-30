//
//  GamenameModalController.swift
//  Clansportler
//
//  Created by Luca Kiedrowski on 10.09.17.
//  Copyright © 2017 LucaKiedrowski. All rights reserved.
//

import UIKit

protocol GamenameModalControllerDelegate {
    func didTapCancel(gamenameModalController: GamenameModalController)
    func didTapContinue(gamenameModalController: GamenameModalController, playername: String)
}

class GamenameModalController: UIViewController, UITextFieldDelegate {
    
    var delegate: GamenameModalControllerDelegate?
    
    var game: Game? {
        didSet {
            guard let gamename = game?.name else { return }
            self.titleLabel.text = "What's your Game-Name & Id for \(gamename)?"
        }
    }
    
    let whiteView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 5
        return view
    }()
    
    lazy var continueButton: ClansportlerRedButton = {
        let button = ClansportlerRedButton(title: "Continue")
        button.addTarget(self, action: #selector(handleContinue), for: .touchUpInside)
        button.isEnabled = false
        button.backgroundColor = ColorCodes.disabledRed
        return button
    }()
    
    lazy var cancelButton: ClansportlerBorderButton = {
        let button = ClansportlerBorderButton(title: "Cancel", tintColor: ColorCodes.clansportlerBlue)
        button.addTarget(self, action: #selector(handleCancel), for: .touchUpInside)
        return button
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = ColorCodes.middleGrey
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.textAlignment = .center
        label.numberOfLines = 2
        return label
    }()
    
    lazy var gamenameTextField: CustomAnimatedTextField = {
        let tf = CustomAnimatedTextField()
        tf.animatedLabel.text = "Your Game-Name"
        tf.textField.addTarget(self, action: #selector(handleTextInputChange), for: .editingChanged)
        tf.textField.autocorrectionType = .no
        tf.textField.autocapitalizationType = .none
        tf.textField.placeholder = "e.g. Test#1234"
        return tf
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        hideKeyboardWhenTappedAround(views: [whiteView])
        
        view.backgroundColor = UIColor(white: 0, alpha: 0.5)
        view.isOpaque = false
        
        view.addSubview(whiteView)
        
        gamenameTextField.textField.becomeFirstResponder()
        
        whiteView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 125, paddingLeft: 16, paddingBottom: 0, paddingRight: 16, width: 0, height: 173)
        
        whiteView.addSubview(continueButton)
        whiteView.addSubview(cancelButton)
        whiteView.addSubview(titleLabel)
        whiteView.addSubview(gamenameTextField)
        
        continueButton.anchor(top: nil, left: whiteView.centerXAnchor, bottom: whiteView.bottomAnchor, right: whiteView.rightAnchor, paddingTop: 0, paddingLeft: 4, paddingBottom: 8, paddingRight: 8, width: 0, height: 45)
        
        cancelButton.anchor(top: nil, left: whiteView.leftAnchor, bottom: whiteView.bottomAnchor, right: whiteView.centerXAnchor, paddingTop: 0, paddingLeft: 8, paddingBottom: 8, paddingRight: 4, width: 0, height: 45)
        
        titleLabel.anchor(top: whiteView.topAnchor, left: whiteView.leftAnchor, bottom: nil, right: whiteView.rightAnchor, paddingTop: 8, paddingLeft: 8, paddingBottom: 0, paddingRight: 8, width: 0, height: 50)
        
        gamenameTextField.anchor(top: titleLabel.bottomAnchor, left: whiteView.leftAnchor, bottom: nil, right: whiteView.rightAnchor, paddingTop: 4, paddingLeft: 8, paddingBottom: 0, paddingRight: 8, width: 0, height: 50)
    }
    
    @objc func handleTextInputChange() {
        let isFormValid = gamenameTextField.textField.text?.characters.count ?? 0 > 0
        
        if isFormValid {
            continueButton.isEnabled = true
            continueButton.backgroundColor = ColorCodes.clansportlerRed
            
            
        } else {
            continueButton.isEnabled = false
            continueButton.backgroundColor = ColorCodes.disabledRed
        }
    }
    
    @objc func handleContinue() {
        guard let playername = gamenameTextField.textField.text else { return }
        delegate?.didTapContinue(gamenameModalController: self, playername: playername)
    }
    
    @objc func handleCancel() {
        delegate?.didTapCancel(gamenameModalController: self)
    }
    
}


















