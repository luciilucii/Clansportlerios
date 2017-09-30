//
//  PasswordSettingController.swift
//  Clansportler
//
//  Created by Luca Kiedrowski on 19.09.17.
//  Copyright © 2017 LucaKiedrowski. All rights reserved.
//

import UIKit
import Firebase

class PasswordSettingController: ScrollController, UITextFieldDelegate {
    
    var currentUser: User?
    
    let passwordTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Current Password"
        label.textColor = UIColor.white
        label.font = UIFont.boldSystemFont(ofSize: 16)
        return label
    }()
    
    let oldPasswordTextField: UITextField = {
        let tv = UITextField()
        tv.backgroundColor = ColorCodes.lightGrey
        tv.setLeftPaddingPoints(5)
        tv.setRightPaddingPoints(5)
        tv.isSecureTextEntry = true
        tv.placeholder = "Current Password"
        tv.textColor = UIColor(red:0.33, green:0.33, blue:0.33, alpha:1.0)
        return tv
    }()
    
    let newPasswordTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "New Password"
        label.textColor = UIColor.white
        label.font = UIFont.boldSystemFont(ofSize: 16)
        return label
    }()
    
    let newPasswordTextField: UITextField = {
        let tv = UITextField()
        tv.backgroundColor = ColorCodes.lightGrey
        tv.setLeftPaddingPoints(5)
        tv.setRightPaddingPoints(5)
        tv.isSecureTextEntry = true
        tv.placeholder = "New Password"
        tv.textColor = UIColor(red:0.33, green:0.33, blue:0.33, alpha:1.0)
        return tv
    }()
    
    let confirmPasswordTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Confirm new Password"
        label.textColor = UIColor.white
        label.font = UIFont.boldSystemFont(ofSize: 16)
        return label
    }()
    
    lazy var confirmPasswordTextField: UITextField = {
        let tv = UITextField()
        tv.backgroundColor = ColorCodes.lightGrey
        tv.setLeftPaddingPoints(5)
        tv.setRightPaddingPoints(5)
        tv.placeholder = "Confirm new Password"
        tv.isSecureTextEntry = true
        tv.delegate = self
        tv.textColor = UIColor(red:0.33, green:0.33, blue:0.33, alpha:1.0)
        return tv
    }()
    
    lazy var updateButton: ClansportlerRedButton = {
        let button = ClansportlerRedButton(title: "Change Password")
        button.addTarget(self, action: #selector(handleChangePassword), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
        Database.fetchUserWithUID(uid: currentUserId) { (user) in
            self.currentUser = user
        }
        scrollContainerView.backgroundColor = ColorCodes.backgroundGrey
        
        super.setupScrollView(height: view.frame.width)
        
        super.setupController()
        
        navigationController?.navigationBar.tintColor = .white
        
        setupViews()
        
        setupKeyboardObservers()
        hideKeyboardWhenTappedAround(views: [scrollContainerView, scrollView, view])
    }
    
    override func setupViews() {
        scrollContainerView.addSubview(passwordTitleLabel)
        scrollContainerView.addSubview(oldPasswordTextField)
        
        scrollContainerView.addSubview(newPasswordTitleLabel)
        scrollContainerView.addSubview(newPasswordTextField)
        
        scrollContainerView.addSubview(confirmPasswordTitleLabel)
        scrollContainerView.addSubview(confirmPasswordTextField)
        
        scrollContainerView.addSubview(updateButton)
        
        
        passwordTitleLabel.anchor(top: scrollContainerView.topAnchor, left: scrollContainerView.leftAnchor, bottom: nil, right: scrollContainerView.rightAnchor, paddingTop: 25, paddingLeft: 8, paddingBottom: 0, paddingRight: 8, width: 0, height: 30)
        
        oldPasswordTextField.anchor(top: passwordTitleLabel.bottomAnchor, left: scrollContainerView.leftAnchor, bottom: nil, right: scrollContainerView.rightAnchor, paddingTop: 8, paddingLeft: 8, paddingBottom: 0, paddingRight: 8, width: 0, height: 50)
        
        newPasswordTitleLabel.anchor(top: oldPasswordTextField.bottomAnchor, left: scrollContainerView.leftAnchor, bottom: nil, right: scrollContainerView.rightAnchor, paddingTop: 8, paddingLeft: 8, paddingBottom: 0, paddingRight: 8, width: 0, height: 30)
        
        newPasswordTextField.anchor(top: newPasswordTitleLabel.bottomAnchor, left: scrollContainerView.leftAnchor, bottom: nil, right: scrollContainerView.rightAnchor, paddingTop: 8, paddingLeft: 8, paddingBottom: 0, paddingRight: 8, width: 0, height: 50)
        
        confirmPasswordTitleLabel.anchor(top: newPasswordTextField.bottomAnchor, left: scrollContainerView.leftAnchor, bottom: nil, right: scrollContainerView.rightAnchor, paddingTop: 8, paddingLeft: 8, paddingBottom: 0, paddingRight: 8, width: 0, height: 30)
        
        confirmPasswordTextField.anchor(top: confirmPasswordTitleLabel.bottomAnchor, left: scrollContainerView.leftAnchor, bottom: nil, right: scrollContainerView.rightAnchor, paddingTop: 8, paddingLeft: 8, paddingBottom: 0, paddingRight: 8, width: 0, height: 50)
        
        updateButton.anchor(top: confirmPasswordTextField.bottomAnchor, left: scrollContainerView.leftAnchor, bottom: nil, right: scrollContainerView.rightAnchor, paddingTop: 8, paddingLeft: 8, paddingBottom: 0, paddingRight: 8, width: 0, height: 50)
        
    }
    
    @objc func handleChangePassword() {
        
        let firAuth = Auth.auth().currentUser
        
        
        
        guard let currentEmail = Auth.auth().currentUser?.email else { return }
        
        guard let currentPassword = oldPasswordTextField.text else { return }
        
        //TODO: Check for current password
        
        guard let newPassword = newPasswordTextField.text else { return }
        guard let confirmPassword = confirmPasswordTextField.text else { return }
        
        if newPassword != confirmPassword {
            return
        } else {
            firAuth?.updatePassword(to: newPassword, completion: { (err) in
                if let err = err {
                    print("failed to update error", err)
                }
            })
        }
    }
    
    func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    @objc func handleKeyboardWillShow(notification: NSNotification) {
        let keyboardFrame = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as AnyObject).cgRectValue
        let keyboardDuration = (notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue
        
        guard let keyboardHeight = keyboardFrame?.height else {
            print("Fehler in der Keyboard Höhe")
            return
        }
        
        let aboveKeyboardView = view.frame.height - keyboardHeight
        
        if confirmPasswordTextField.isEditing == true {
            
            if confirmPasswordTextField.frame.maxY >= aboveKeyboardView {
                guard let duration = keyboardDuration else {
                    return
                }
                UIView.animate(withDuration: duration, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                    
                    self.scrollView.contentOffset.y = 100
                    
                }, completion: nil)
            }
        }
    }
    
    @objc func handleKeyboardWillHide(notification: NSNotification) {
        let keyboardDuration = (notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue
        
        guard let duration = keyboardDuration else {
            return
        }
        UIView.animate(withDuration: duration, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            
            self.scrollView.contentOffset.y = 0
            
        }, completion: nil)
        
    }
    
}





















