//
//  DetailApproveController.swift
//  Clansportler
//
//  Created by Luca Kiedrowski on 30.08.17.
//  Copyright © 2017 LucaKiedrowski. All rights reserved.
//

import UIKit
import Firebase

class DetailApproveController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var game: Game? {
        didSet {
            guard let gamename = game?.name else { return }
            gameLabel.text = gamename
            
            guard let imageUrl = game?.imageUrl else { return }
            gameImageView.loadImage(urlString: imageUrl)
        }
    }
    
    var changedImage: Bool? = false
    
    let gameImageView: CustomImageView = {
        let iv = CustomImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = .brown
        return iv
    }()
    
    let gameLabel: UILabel = {
        let label = UILabel()
        label.text = "Starcraft 2"
        label.numberOfLines = 2
        label.textColor = .white
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 18)
        return label
    }()
    
    lazy var changeImageButton: ClansportlerBorderButton = {
        let button = ClansportlerBorderButton(title: "Change image", tintColor: UIColor.white)
        button.addTarget(self, action: #selector(handlePlusPhoto), for: .touchUpInside)
        return button
    }()
    
    lazy var declineButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .clear
        button.setTitle("Decline", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.setTitleColor(UIColor.white, for: .normal)
        button.layer.cornerRadius = 5
        button.layer.borderColor = UIColor.white.cgColor
        button.layer.borderWidth = 1
        button.addTarget(self, action: #selector(handleDecline), for: .touchUpInside)
        return button
    }()
    
    lazy var acceptButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = ColorCodes.clansportlerRed
        button.setTitle("Accept", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.setTitleColor(UIColor.white, for: .normal)
        button.layer.cornerRadius = 5
        button.addTarget(self, action: #selector(handleAccept), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = ColorCodes.backgroundGrey
        
        view.addSubview(gameImageView)
        view.addSubview(gameLabel)
        
        view.addSubview(acceptButton)
        view.addSubview(declineButton)
        
        view.addSubview(changeImageButton)
        
        gameImageView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: (view.frame.width / 16 * 9))
        
        gameLabel.anchor(top: gameImageView.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 8, width: 0, height: 50)
        
        acceptButton.anchor(top: nil, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 8, paddingBottom: 8, paddingRight: 8, width: 0, height: 50)
        
        declineButton.anchor(top: nil, left: view.leftAnchor, bottom: acceptButton.topAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 8, paddingBottom: 8, paddingRight: 8, width: 0, height: 50)
        
        changeImageButton.anchor(top: nil, left: view.leftAnchor, bottom: declineButton.topAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 8, paddingBottom: 8, paddingRight: 8, width: 0, height: 50)
        
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
            
            gameImageView.image = editedImage
            
        } else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            gameImageView.image = originalImage
        }
        
        self.changedImage = true
        
        dismiss(animated: true, completion: nil)
    }
    
    @objc func handleDecline() {
        guard let gameId = game?.id else { return }
        let gameRef = Database.database().reference().child("games").child(gameId)
        
        gameRef.removeValue { (err, _) in
            if let err = err {
                print("failed to delete game", err)
            }
        }
        
    }
    
    @objc func handleAccept() {
        guard let gameId = self.game?.id else { return }
        let values: [String: Any] = [gameId: 1]
        
        let approvedGamesRef = Database.database().reference().child("games").child("approvedGames")
        
        approvedGamesRef.updateChildValues(values) { (err, _) in
            if let err = err {
                print("failed to upload game", err)
            }
        }
        if self.changedImage == true {
            self.handleUploadGameImage()
        }
        
        navigationController?.popViewController(animated: true)
    }
    
    func handleUploadGameImage() {
        let filename = UUID().uuidString
        guard let gameId = self.game?.id else { return }
        
        guard let image = gameImageView.image else { return }
        guard let uploadData = UIImageJPEGRepresentation(image, 0.9) else { return }
        
        let storageRef = Storage.storage().reference().child("game_images").child(filename)
        storageRef.putData(uploadData, metadata: nil) { (metadata, error) in
            if let error = error {
                print("failed to upload game image:", error)
            }
            guard let imageUrl = metadata?.downloadURL()?.absoluteString else { return }
            
            let values: [String: Any] = ["imageUrl": imageUrl]
            
            let gamesRef = Database.database().reference().child("games").child(gameId)
            gamesRef.updateChildValues(values, withCompletionBlock: { (err, _) in
                if let err = err {
                    print("failed to update game into db:", err)
                }
            })
        }
    }
    
}















