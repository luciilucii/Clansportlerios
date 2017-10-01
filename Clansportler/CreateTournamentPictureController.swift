//
//  CreateTournamentPictureController.swift
//  Clansportler
//
//  Created by Luca Kiedrowski on 01.10.17.
//  Copyright © 2017 LucaKiedrowski. All rights reserved.
//

import UIKit
import Firebase

class CreateTournamentPictureController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var values: [String: Any]?
    
    lazy var openButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Next", for: .normal)
        button.backgroundColor = ColorCodes.disabledRed
        button.isEnabled = false
        button.tintColor = UIColor.white
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.addTarget(self, action: #selector(handleOpen), for: .touchUpInside)
        return button
    }()
    
    lazy var profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.isUserInteractionEnabled = true
        iv.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handlePlusPhoto)))
        iv.contentMode = .scaleAspectFit
        iv.image = #imageLiteral(resourceName: "plus_photo").withRenderingMode(.alwaysTemplate)
        iv.tintColor = UIColor.white
        iv.clipsToBounds = true
        return iv
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = ColorCodes.clansportlerBlue
        
        navigationController?.navigationBar.tintColor = UIColor.white
        
        setupViews()
    }
    
    func setupViews() {
        view.addSubview(openButton)
        openButton.anchor(top: nil, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 45)
        
        view.addSubview(profileImageView)
        profileImageView.anchor(top: view.topAnchor, left: nil, bottom: nil, right: nil, paddingTop: 150, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 150, height: 150)
        
        profileImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
    }
    
    @objc func handlePlusPhoto() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = true
        imagePickerController.navigationBar.barTintColor = UIColor.white
        
        imagePickerController.navigationBar.tintColor = UIColor.black
        
        present(imagePickerController, animated: true) {
            UIApplication.shared.statusBarStyle = .default
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true) {
            
            UIApplication.shared.statusBarStyle = .lightContent
            
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage {
            
            profileImageView.image = editedImage.withRenderingMode(.alwaysOriginal)
            
        } else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            profileImageView.image = originalImage.withRenderingMode(.alwaysOriginal)
        }
        
        openButton.isEnabled = true
        openButton.backgroundColor = ColorCodes.clansportlerRed
        
        dismiss(animated: true) {
            UIApplication.shared.statusBarStyle = .lightContent
        }
    }
    
    @objc func handleOpen() {
        
        openButton.isEnabled = false
        openButton.backgroundColor = ColorCodes.disabledRed
        openButton.setTitle("Loading...", for: .normal)
        
        guard let image = profileImageView.image else { return }
        guard let imageData = UIImageJPEGRepresentation(image, 0.75) else { return }
        
        let filename = UUID().uuidString
        
        Storage.storage().reference().child("tournament_images").child(filename).putData(imageData, metadata: nil) { (metadata, error) in
            
            if let error = error {
                print("Failed to uplaod image:", error)
                self.enableButton()
            }
            
            guard let profileImageUrl = metadata?.downloadURL()?.absoluteString else { return }
            
            self.values?["tournamentImageUrl"] = profileImageUrl
            
            let createTournamentDateController = CreateTournamentNameDateController()
            createTournamentDateController.values = self.values
            self.show(createTournamentDateController, sender: self)
        }
    }
    
    func enableButton() {
        openButton.backgroundColor = ColorCodes.clansportlerRed
        openButton.isEnabled = true
        openButton.setTitle("Next", for: .normal)
    }
    
}
