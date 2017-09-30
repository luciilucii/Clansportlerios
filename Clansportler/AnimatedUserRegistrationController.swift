//
//  AnimatedUserRegistrationController.swift
//  Clansportler
//
//  Created by Luca Kiedrowski on 05.08.17.
//  Copyright © 2017 LucaKiedrowski. All rights reserved.
//

import UIKit
import Firebase
import FirebaseMessaging

class AnimatedUserRegistrationController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    let cellId = "cellId"
    
    var currentPage: Int?
    
    var loginController: LoginController?
    
    var didChoosePicture: Bool?
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Choose your Name"
        label.font = UIFont.boldSystemFont(ofSize: 22)
        label.textColor = ColorCodes.darkestGrey
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    let pageControl: UIPageControl = {
        let pc = UIPageControl()
        pc.pageIndicatorTintColor = UIColor(red:0.49, green:0.75, blue:0.94, alpha:1.0)
        pc.currentPageIndicatorTintColor = ColorCodes.clansportlerBlue
        pc.numberOfPages = 3
        return pc
    }()
    
    lazy var continueButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = ColorCodes.disabledBlue
        button.isEnabled = false
        button.tintColor = UIColor.white
        button.setTitle("Continue", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.addTarget(self, action: #selector(handleContinue), for: .touchUpInside)
        return button
    }()
    
    lazy var cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "cancel").withRenderingMode(.alwaysTemplate), for: .normal)
        button.tintColor = ColorCodes.darkestGrey
        button.addTarget(self, action: #selector(handleCancel), for: .touchUpInside)
        return button
    }()
    
    lazy var usernameTextField: CustomAnimatedTextField = {
        let tf = CustomAnimatedTextField()
        tf.textField.addTarget(self, action: #selector(handleDidBeginEditingUsername), for: .editingChanged)
        tf.animatedLabel.text = "Username"
        tf.backgroundColor = .white
        tf.textField.delegate = self
        tf.textField.autocorrectionType = .no
        return tf
    }()
    
    lazy var emailTextField: CustomAnimatedTextField = {
        let tf = CustomAnimatedTextField()
        tf.textField.addTarget(self, action: #selector(handleDidBeginEditingEmail), for: .editingChanged)
        tf.animatedLabel.text = "Email Address"
        tf.textField.keyboardType = .emailAddress
        tf.backgroundColor = .white
        tf.textField.delegate = self
        tf.textField.autocorrectionType = .no
        return tf
    }()
    
    lazy var passwordTextField: CustomAnimatedTextField = {
        let tf = CustomAnimatedTextField()
        tf.textField.addTarget(self, action: #selector(handleDidBeginEditingPassword), for: .editingChanged)
        tf.textField.isSecureTextEntry = true
        tf.animatedLabel.text = "Password"
        tf.backgroundColor = .white
        tf.textField.delegate = self
        return tf
    }()
    
    let falseLoginView: UIView = {
        let view = UIView()
        view.backgroundColor = ColorCodes.clansportlerRed
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
        return view
    }()
    
    let falseLoginImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "bell")?.withRenderingMode(.alwaysTemplate)
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFill
        iv.tintColor = .white
        return iv
    }()
    
    let falseLoginLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.text = "Failed to create user. Please check if all fields are filled and your Internet-Connection is fine."
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .left
        label.numberOfLines = 3
        label.lineBreakMode = .byWordWrapping
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()
    
    var continueButtonBottomAnchor: NSLayoutConstraint?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        didChoosePicture = false
        
        view.backgroundColor = .white
        
        usernameTextField.textField.becomeFirstResponder()
        
        currentPage = 0
        
        setupKeyboardObservers()
        setupViews()
        setupTextFields()
    }
    
    @objc func handleCancel() {
        dismiss(animated: true) { 
            // completion here
            UIApplication.shared.statusBarStyle = .lightContent
        }
    }
    
    func setupViews() {
        view.addSubview(pageControl)
        pageControl.anchor(top: view.topAnchor, left: nil, bottom: nil, right: nil, paddingTop: 20, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 100, height: 20)
        pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        view.addSubview(continueButton)
        
        continueButton.anchor(top: nil, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 44)
        
        continueButtonBottomAnchor = continueButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -16)
        continueButtonBottomAnchor?.isActive = true
        
        view.addSubview(titleLabel)
        titleLabel.anchor(top: view.topAnchor, left: nil, bottom: nil, right: nil, paddingTop: 45, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: view.frame.width - 32, height: 65)
        titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        view.addSubview(cancelButton)
        cancelButton.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: nil, right: nil, paddingTop: 20, paddingLeft: 16, paddingBottom: 0, paddingRight: 0, width: 44, height: 44)
        
        
        setupFalseLogin()
        
    }
    
    func setupFalseLogin() {
        view.addSubview(falseLoginView)
        
        //x,y,w,h
        falseLoginView.topAnchor.constraint(equalTo: view.topAnchor, constant: 20).isActive = true
        falseLoginView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        falseLoginView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        falseLoginView.heightAnchor.constraint(equalToConstant: 100).isActive = true
        
        falseLoginView.addSubview(falseLoginLabel)
        falseLoginView.addSubview(falseLoginImageView)
        
        //x,y,w,h
        falseLoginLabel.leftAnchor.constraint(equalTo: falseLoginImageView.rightAnchor, constant: 8).isActive = true
        falseLoginLabel.centerYAnchor.constraint(equalTo: falseLoginView.centerYAnchor).isActive = true
        falseLoginLabel.rightAnchor.constraint(equalTo: falseLoginView.rightAnchor, constant: -25).isActive = true
        falseLoginLabel.heightAnchor.constraint(equalToConstant: 80).isActive = true
        
        //x,y,w,h
        falseLoginImageView.leftAnchor.constraint(equalTo: falseLoginView.leftAnchor, constant: 16).isActive = true
        falseLoginImageView.centerYAnchor.constraint(equalTo: falseLoginView.centerYAnchor).isActive = true
        falseLoginImageView.widthAnchor.constraint(equalToConstant: 30).isActive = true
        falseLoginImageView.heightAnchor.constraint(equalToConstant: 30).isActive = true
    }
    
    var usernameTextFieldLeftAnchor: NSLayoutConstraint?
    var emailTextFieldLeftAnchor: NSLayoutConstraint?
    var passwordTextFieldLeftAnchor: NSLayoutConstraint?
    
    
    func setupTextFields() {
        
        view.addSubview(usernameTextField)
        
        usernameTextField.anchor(top: view.topAnchor, left: nil, bottom: nil, right: nil, paddingTop: 150, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: view.frame.width - 32, height: 50)
        usernameTextFieldLeftAnchor = usernameTextField.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 16)
        usernameTextFieldLeftAnchor?.isActive = true
        
        view.addSubview(emailTextField)
        emailTextField.anchor(top: view.topAnchor, left: nil, bottom: nil, right: nil, paddingTop: 150, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: view.frame.width - 32, height: 50)
        emailTextFieldLeftAnchor = emailTextField.leftAnchor.constraint(equalTo: view.leftAnchor, constant: view.frame.width + 16)
        emailTextFieldLeftAnchor?.isActive = true
        
        view.addSubview(passwordTextField)
        passwordTextField.anchor(top: view.topAnchor, left: nil, bottom: nil, right: nil, paddingTop: 150, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: view.frame.width - 32, height: 50)
        passwordTextFieldLeftAnchor = passwordTextField.leftAnchor.constraint(equalTo: view.leftAnchor, constant: view.frame.width + 16)
        passwordTextFieldLeftAnchor?.isActive = true
        
        
    }
    
    @objc func handleContinue() {
        guard let page = currentPage else { return }
        currentPage = page + 1
        
        guard let updatedPage = currentPage else { return }
        scrollToPage(page: updatedPage)
        pageControl.currentPage = updatedPage
    }
    
    func scrollToPage(page: Int) {
        switch page {
        case 1:
            usernameTextFieldLeftAnchor?.constant = -view.frame.width + 16
            emailTextFieldLeftAnchor?.constant = 16
            emailTextField.textField.becomeFirstResponder()
            
            continueButton.backgroundColor = ColorCodes.disabledBlue
            continueButton.isEnabled = false
            
            titleLabel.text = "Your Email"
        case 2:
            emailTextFieldLeftAnchor?.constant = -view.frame.width + 16
            passwordTextFieldLeftAnchor?.constant = 16
            passwordTextField.textField.becomeFirstResponder()
            
            continueButton.backgroundColor = ColorCodes.disabledBlue
            continueButton.isEnabled = false
            
            continueButton.setTitle("Register", for: .normal)
            continueButton.addTarget(self, action: #selector(handleRegisterWithoutImage), for: .touchUpInside)
            
            titleLabel.text = "Your Password"
        default:
            break
        }
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: { 
            self.view.layoutIfNeeded()
        }) { (_) in
            
            //completion here
            
        }
    }
    
    @objc func handleDidBeginEditingUsername() {
        if usernameTextField.textField.text != nil {
            continueButton.isEnabled = true
            continueButton.backgroundColor = ColorCodes.clansportlerBlue
        }
    }
    
    @objc func handleDidBeginEditingEmail() {
        if emailTextField.textField.text != nil {
            continueButton.isEnabled = true
            continueButton.backgroundColor = ColorCodes.clansportlerBlue
        }
    }
    
    @objc func handleDidBeginEditingPassword() {
        if passwordTextField.textField.text != nil {
            continueButton.isEnabled = true
            continueButton.backgroundColor = ColorCodes.clansportlerBlue
        }
    }
    
    func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    @objc func handleKeyboardWillShow(notification: NSNotification) {
        let keyboardFrame = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as AnyObject).cgRectValue
        guard let keyboardDuration = (notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue else { return }
        
        guard let keyboardHeight = keyboardFrame?.height else { return }
        continueButtonBottomAnchor?.constant = -keyboardHeight
        
        UIView.animate(withDuration: keyboardDuration) {
            self.view.layoutIfNeeded()
        }
    }
    
    @objc func handleKeyboardWillHide(notification: NSNotification) {
        let keyboardDuration = (notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue
        
        continueButtonBottomAnchor?.constant = 0
        
        UIView.animate(withDuration: keyboardDuration!) {
            self.view.layoutIfNeeded()
        }
    }
    
    @objc func handleRegisterWithoutImage() {
        guard let email = emailTextField.textField.text, let password = passwordTextField.textField.text, let username = usernameTextField.textField.text else { return }
        
        guard let token = Messaging.messaging().fcmToken else { return }
        let tokenDictionary: [String: Any] = [token: 1]
        
        continueButton.backgroundColor = ColorCodes.disabledBlue
        continueButton.isEnabled = false
        continueButton.setTitle("Loading...", for: .normal)
        
        Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
            
            if let err = error {
                print("failed to create user", err)
                self.falseLoginView.isHidden = false
                return
            }
            
            Auth.auth().currentUser?.sendEmailVerification(completion: { (err) in
                if let err = err {
                    print("failed to send email verification", err)
                }
            })
            
            let profileImageUrl = "https://firebasestorage.googleapis.com/v0/b/clansportler.appspot.com/o/clansportler_pictures%2Fuser_portraits%2FBetaSportler.png?alt=media&token=555e2e96-7614-4d28-8a62-362315e32619"
            
            guard let uid = user?.uid else { return }
            
            let currentTimestamp = Date().timeIntervalSince1970
            let lowercasedUsername = username.lowercased()
            
            let dictionaryValues: [String: Any] = ["username": lowercasedUsername, "profileImageUrl": profileImageUrl, "email": email, "createdAt": currentTimestamp]
            let values = [uid: dictionaryValues]
            
            Database.database().reference().child("users").updateChildValues(values, withCompletionBlock: { (err, ref) in
                
                if let err = err {
                    print("Failed to save user info into db: ", err)
                    self.setupRegisterButton()
                }
                
                print("successfully saved user info into db")
                
                guard let mainTabBarController = UIApplication.shared.keyWindow?.rootViewController as? MainTabBarController else { return }
                mainTabBarController.setupViewControllers()
                
                self.dismiss(animated: true, completion: {
                    UIApplication.shared.statusBarStyle = .lightContent
                })
                
                guard let userId = user?.uid else { return }
                self.postToken(userId: userId, token: tokenDictionary)
                
                self.loginController?.dismiss(animated: true, completion: {
                    let onboardingController = OnboardingController()
                    mainTabBarController.present(onboardingController, animated: true, completion: {
                        //completion here
                        UIApplication.shared.statusBarStyle = .default
                    })
                })
            })
        }
    }
    
    func setupRegisterButton() {
        continueButton.setTitle("Register", for: .normal)
        continueButton.isEnabled = true
        continueButton.backgroundColor = ColorCodes.clansportlerBlue
    }
    
}









