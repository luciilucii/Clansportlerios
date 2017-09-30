//
//  TeamImageController.swift
//  Clansportler
//
//  Created by Luca Kiedrowski on 07.08.17.
//  Copyright © 2017 LucaKiedrowski. All rights reserved.
//

import UIKit
import Firebase

class TeamImageController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var teamMember = [User]()
    var teamname = ""
    
    var homeController: HomeController?
    
    lazy var openButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Open Clan", for: .normal)
        button.backgroundColor = ColorCodes.disabledBlue
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
        iv.image = #imageLiteral(resourceName: "plus_photo")
        iv.clipsToBounds = true
        return iv
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        navigationController?.navigationBar.tintColor = UIColor.white
        
        setupViews()
        setupKeyboardObservers()
    }
    
    var openButtonBottomAnchor: NSLayoutConstraint?
    
    func setupViews() {
        view.addSubview(openButton)
        openButton.anchor(top: nil, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 45)
        
        openButtonBottomAnchor = openButton.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        openButtonBottomAnchor?.isActive = true
        
        view.addSubview(profileImageView)
        profileImageView.anchor(top: view.topAnchor, left: nil, bottom: nil, right: nil, paddingTop: 150, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 150, height: 150)
        
        profileImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        profileImageView.layer.cornerRadius = 150 / 2
        
    }
    
    func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    @objc func handleKeyboardWillShow(notification: NSNotification) {
        let keyboardFrame = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as AnyObject).cgRectValue
        guard let keyboardDuration = (notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue else { return }
        
        guard let keyboardHeight = keyboardFrame?.height else { return }
        openButtonBottomAnchor?.constant = -keyboardHeight
        
        UIView.animate(withDuration: keyboardDuration) {
            self.view.layoutIfNeeded()
        }
    }
    
    @objc func handleKeyboardWillHide(notification: NSNotification) {
        let keyboardDuration = (notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue
        
        openButtonBottomAnchor?.constant = 0
        
        UIView.animate(withDuration: keyboardDuration!) {
            self.view.layoutIfNeeded()
        }
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
            
            profileImageView.image = editedImage
            
        } else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            profileImageView.image = originalImage
        }
        
        openButton.isEnabled = true
        openButton.backgroundColor = ColorCodes.clansportlerBlue
        
        dismiss(animated: true) { 
            UIApplication.shared.statusBarStyle = .lightContent
        }
    }
    
    @objc func handleOpen() {
        
        openButton.isEnabled = false
        openButton.backgroundColor = ColorCodes.disabledBlue
        openButton.setTitle("Loading...", for: .normal)
        
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
        
        let teamId = UUID().uuidString
        let values = ["team": teamId]
        
        guard let image = profileImageView.image else { return }
        guard let imageData = UIImageJPEGRepresentation(image, 0.75) else { return }
        
        let filename = UUID().uuidString
        
        uploadClanGroupchatsToDB(currentUserId: currentUserId, teamId: teamId)
        
        Storage.storage().reference().child("team_images").child(filename).putData(imageData, metadata: nil) { (metadata, error) in
            
            if let error = error {
                print("Failed to uplaod image:", error)
                self.enableButton()
            }
            
            guard let profileImageUrl = metadata?.downloadURL()?.absoluteString else { return }
            print("successfully uploaded profile image:", profileImageUrl)
            
            let userRef = Database.database().reference().child("users").child(currentUserId)
            userRef.updateChildValues(values) { (err, ref) in
                if let err = err {
                    print("failed to update child values:", err)
                    self.enableButton()
                }
                print("successfully created clan")
                
                let teamValues = ["teamname": self.teamname, "profileImageUrl": profileImageUrl, "adminId": currentUserId]
                
                let teamRef = Database.database().reference().child("teams").child(teamId)
                teamRef.updateChildValues(teamValues, withCompletionBlock: { (err, ref) in
                    if let err = err {
                        print("failed to post clan to db: ", err)
                        self.enableButton()
                    }
                    
                    let teamMemberRef = teamRef.child("member")
                    teamMemberRef.updateChildValues([currentUserId: 1], withCompletionBlock: { (error, ref) in
                        if let error = error {
                            print("failed to post current user in clan db:", error)
                            self.enableButton()
                        }
                    })
                    
                    NotificationCenter.default.post(name: MainTabBarController.updateControllerNotification, object: nil)
                    
                    for member in self.teamMember {
                        
                        let memberId = member.id
                        let updateId = UUID().uuidString
                        
                        let teamMemberUserRef = Database.database().reference().child("users").child(memberId).child("teamInvitations")
                        let userValues: [String: Any] = [updateId: 1]
                        teamMemberUserRef.updateChildValues(userValues, withCompletionBlock: { (error, ref) in
                            if let error = error {
                                print("failed to post into users db:", error)
                                self.enableButton()
                            }
                        })
                        
                        let timestamp = Date().timeIntervalSince1970
                        let values: [String: Any] = ["toId": memberId, "teamId": teamId, "timestamp": timestamp, "fromId": currentUserId, "hasSeen": false, "teamname": self.teamname, "imageUrl": profileImageUrl]
                        
                        let updateRef = Database.database().reference().child("updates").child("teamInvitation").child(updateId)
                        updateRef.updateChildValues(values, withCompletionBlock: { (error, ref) in
                            
                            if let error = error {
                                print("failed to put update in db:", error)
                                self.enableButton()
                            }
                        })
                        
                    }
                    
                    self.dismiss(animated: true, completion: { 
                        //completion here
                        
                        
                    })
                })
            }
        }
    }
    
    func uploadClanGroupchatsToDB(currentUserId: String, teamId: String) {
        let groupId = UUID().uuidString
        let groupchatUserRef = Database.database().reference().child("groupchats").child(groupId)
        
        let groupChatUsers: [String: Any] = [currentUserId: 1]
        let groupChatValues: [String: Any] = ["users": groupChatUsers, "name": "clanchat", "teamId": teamId]
        groupchatUserRef.updateChildValues(groupChatValues) { (err, _) in
            if let err = err {
                print("failed to create groupchat into db: ", err)
            }
        }
        
        let teamValues: [String: Any] = [groupId: 1]
        
        let teamRef = Database.database().reference().child("teams").child(teamId).child("groupchats")
        teamRef.updateChildValues(teamValues) { (err, _) in
            if let err = err {
                print("failed to post groupchat in team db: ", err)
            }
        }
        
        let userGroupValues: [String: Any] = [groupId: 1]
        
        let userRef = Database.database().reference().child("users").child(currentUserId).child("groupchats")
        userRef.updateChildValues(userGroupValues) { (err, _) in
            if let err = err {
                print("failed to create groupchat into user db: ", err)
            }
        }
        
    }
    
    func enableButton() {
        openButton.backgroundColor = ColorCodes.clansportlerBlue
        openButton.isEnabled = true
        openButton.setTitle("Open Clan", for: .normal)
    }
    
}








