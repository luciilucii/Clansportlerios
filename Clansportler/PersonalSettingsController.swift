//
//  PersonalSettingsController.swift
//  Clansportler
//
//  Created by Luca Kiedrowski on 18.09.17.
//  Copyright © 2017 LucaKiedrowski. All rights reserved.
//

import UIKit
import Firebase

class PersonalSettingsController: ScrollController {
    
    var currentUser: User? {
        didSet {
            guard let imageUrl = currentUser?.profileImageUrl else { return }
            profileImageView.loadImage(urlString: imageUrl)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
        Database.fetchUserWithUID(uid: currentUserId) { (user) in
            self.currentUser = user
        }
        scrollContainerView.backgroundColor = ColorCodes.backgroundGrey
        
        super.setupScrollView(height: 977)
        
        super.setupController()
        
        navigationController?.navigationBar.tintColor = .white
        
        setupViews()
        
        hideKeyboardWhenTappedAround(views: [scrollContainerView, scrollView, view])
    }
    
    let profileImageView: CustomImageView = {
        let iv = CustomImageView()
        iv.backgroundColor = UIColor.blue
        iv.clipsToBounds = true
        iv.contentMode = .scaleAspectFill
        return iv
    }()
    
    let personalContainer: PersonalContainer = {
        let container = PersonalContainer()
        return container
    }()
    
    let addressContainer: AddressContainer = {
        let container = AddressContainer()
        return container
    }()
    
    let contactContainer: ContactContainer = {
        let container = ContactContainer()
        return container
    }()
    
    lazy var updateButton: ClansportlerRedButton = {
        let button = ClansportlerRedButton(title: "Update")
        button.addTarget(self, action: #selector(handleUpdateData), for: .touchUpInside)
        return button
    }()
    
    override func setupViews() {
        
        scrollContainerView.addSubview(profileImageView)
        scrollContainerView.addSubview(personalContainer)
        scrollContainerView.addSubview(addressContainer)
        scrollContainerView.addSubview(contactContainer)
        scrollContainerView.addSubview(updateButton)
        
        profileImageView.anchor(top: scrollContainerView.topAnchor, left: nil, bottom: nil, right: nil, paddingTop: 25, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 125, height: 125)
        profileImageView.centerXAnchor.constraint(equalTo: scrollContainerView.centerXAnchor).isActive = true
        profileImageView.layer.cornerRadius = 125/2
        
        
        personalContainer.anchor(top: profileImageView.bottomAnchor, left: scrollContainerView.leftAnchor, bottom: nil, right: scrollContainerView.rightAnchor, paddingTop: 16, paddingLeft: 8, paddingBottom: 0, paddingRight: 8, width: 0, height: 150)
        
        addressContainer.anchor(top: personalContainer.bottomAnchor, left: scrollContainerView.leftAnchor, bottom: nil, right: scrollContainerView.rightAnchor, paddingTop: 16, paddingLeft: 8, paddingBottom: 0, paddingRight: 8, width: 0, height: 286)
        
        contactContainer.anchor(top: addressContainer.bottomAnchor, left: scrollContainerView.leftAnchor, bottom: nil, right: scrollContainerView.rightAnchor, paddingTop: 16, paddingLeft: 8, paddingBottom: 0, paddingRight: 8, width: 0, height: 154)
        
        updateButton.anchor(top: contactContainer.bottomAnchor, left: scrollContainerView.leftAnchor, bottom: nil, right: scrollContainerView.rightAnchor, paddingTop: 16, paddingLeft: 8, paddingBottom: 0, paddingRight: 8, width: 0, height: 50)
        
    }
    
    @objc func handleUpdateData() {
        
        self.updateButton.setTitle("Updating...", for: .normal)
        self.updateButton.backgroundColor = ColorCodes.disabledRed
        self.updateButton.isEnabled = false
        
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
        var personalInfoDictionary: [String: Any] = [String: Any]()
        
        if let firstname = personalContainer.firstnameTextField.text {
            personalInfoDictionary["firstname"] = firstname
        }
        if let lastname = personalContainer.lastnameTextField.text {
            personalInfoDictionary["lastname"] = lastname
        }
        
        if personalInfoDictionary.keys.count != 0 {
            let userRef = Database.database().reference().child("users").child(currentUserId)
            userRef.updateChildValues(personalInfoDictionary) { (err, _) in
                if let err = err {
                    print("failed to update personal info", err)
                }
            }
        }
        
        var addressValues: [String: Any] = [String: Any]()
        
        if let streetName = addressContainer.streetTextField.text {
            addressValues["street"] = streetName
        }
        
        if let postalCode = addressContainer.postalCodeTextField.text {
            addressValues["postalCode"] = postalCode
        }
        
        if let cityName = addressContainer.cityTextField.text {
            addressValues["city"] = cityName
        }
        if let countryName = addressContainer.countryTextField.text {
            addressValues["country"] = countryName
        }
        
        if addressValues.keys.count != 0 {
            let addressRef = Database.database().reference().child("user-addresses").child(currentUserId)
            addressRef.updateChildValues(addressValues, withCompletionBlock: { (err, _) in
                if let err = err {
                    print("failed to update address", err)
                }
            })
        }
        
        var contactValues: [String: Any] = [String: Any]()
        if let email = contactContainer.emailTextField.text {
            contactValues["email"] = email
        }
        if let phoneNumber = contactContainer.phoneTextField.text {
            contactValues["phone"] = phoneNumber
        }
        if contactValues.keys.count != 0 {
            let contactRef = Database.database().reference().child("users").child(currentUserId).child("contact")
            contactRef.updateChildValues(contactValues, withCompletionBlock: { (err, _) in
                if let err = err {
                    print("failed to update contacts", err)
                }
            })
        }
        
        self.navigationController?.popViewController(animated: true)
    }
    
}
















