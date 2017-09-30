//
//  AddGameController.swift
//  Clansportler
//
//  Created by Luca Kiedrowski on 15.08.17.
//  Copyright © 2017 LucaKiedrowski. All rights reserved.
//

import UIKit
import Firebase

class AddGameController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var didChoosePicture = false {
        didSet {
            
        }
    }
    
    lazy var plusPhotoImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = #imageLiteral(resourceName: "plus_photo").withRenderingMode(.alwaysTemplate)
        iv.tintColor = ColorCodes.clansportlerBlue
        iv.contentMode = .scaleAspectFill
        iv.isUserInteractionEnabled = true
        iv.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handlePlusPhoto)))
        iv.clipsToBounds = true
        return iv
    }()
    
    let addGameLabel: UILabel = {
        let label = UILabel()
        label.text = "Add your Game"
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.textAlignment = .center
        label.textColor = ColorCodes.clansportlerBlue
        return label
    }()
    
    lazy var gamenameTextField: CustomAnimatedTextField = {
        let tf = CustomAnimatedTextField()
        tf.animatedLabel.text = "Name of the Game"
        tf.textField.addTarget(self, action: #selector(handleNameChanged), for: .editingChanged)
        tf.backgroundColor = .white
        return tf
    }()
    
    lazy var uploadButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = ColorCodes.disabledBlue
        button.setTitle("Upload", for: .normal)
        button.tintColor = .white
        button.addTarget(self, action: #selector(handleUploadGame), for: .touchUpInside)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        button.backgroundColor = ColorCodes.disabledBlue
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        let textAttributes = [NSAttributedStringKey.foregroundColor:UIColor.white]
        navigationController?.navigationBar.titleTextAttributes = textAttributes
        
        self.navigationItem.title = "Upload your Game"
        self.navigationController?.navigationBar.tintColor = .white
        
        setupConstraints()
        hideKeyboardWhenTappedAround(views: [view])
        setupKeyboardObservers()
    }
    
    var uploadButtonBottomAnchor: NSLayoutConstraint?
    var uploadButtonWidthAnchor: NSLayoutConstraint?
    
    func setupConstraints() {
        
        view.addSubview(plusPhotoImageView)
        view.addSubview(addGameLabel)
        view.addSubview(gamenameTextField)
        view.addSubview(uploadButton)
        
        plusPhotoImageView.anchor(top: view.topAnchor, left: nil, bottom: nil, right: nil, paddingTop: 81, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 125, height: 125)
        plusPhotoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        plusPhotoImageView.layer.cornerRadius = 125 / 2
        
        addGameLabel.anchor(top: plusPhotoImageView.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 16, paddingLeft: 8, paddingBottom: 0, paddingRight: 8, width: 0, height: 30)
        
        gamenameTextField.anchor(top: addGameLabel.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 8, paddingLeft: 8, paddingBottom: 0, paddingRight: 8, width: 0, height: 50)
        
        uploadButton.anchor(top: nil, left: nil, bottom: view.bottomAnchor, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 16, paddingRight: 0, width: 0, height: 0)
        
        
        uploadButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        uploadButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        uploadButton.widthAnchor.constraint(equalToConstant: view.frame.width - 16).isActive = true
        
    }
    
    @objc func handleNameChanged() {
        if didChoosePicture {
            uploadButton.isEnabled = true
            uploadButton.backgroundColor = ColorCodes.clansportlerBlue
        }
    }
    
    @objc func handleUploadGame() {
        uploadButton.isEnabled = false
        uploadButton.backgroundColor = ColorCodes.disabledBlue
        uploadButton.setTitle("Loading...", for: .normal)
        
        let filename = UUID().uuidString
        
        guard let image = plusPhotoImageView.image else { return }
        guard let uploadData = UIImageJPEGRepresentation(image, 0.9) else { return }
        
        let storageRef = Storage.storage().reference().child("game_images").child(filename)
        storageRef.putData(uploadData, metadata: nil) { (metadata, error) in
            if let error = error {
                print("failed to upload game image:", error)
            }
            
            guard let imageUrl = metadata?.downloadURL()?.absoluteString else { return }
            
            guard let gamename = self.gamenameTextField.textField.text else { return }
            let timestamp = Date().timeIntervalSince1970
            let values: [String: Any] = ["gamename": gamename, "createdAt": timestamp, "imageUrl": imageUrl, "approved": false]
            
            let gamesRef = Database.database().reference().child("games").childByAutoId()
            gamesRef.updateChildValues(values, withCompletionBlock: { (err, _) in
                if let err = err {
                    print("failed to update game into db:", err)
                }
            })
            
            self.navigationController?.popViewController(animated: true)
            
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
            
            plusPhotoImageView.image = editedImage
            
        } else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            plusPhotoImageView.image = originalImage
        }
        
        didChoosePicture = true
        
        dismiss(animated: true) {
            UIApplication.shared.statusBarStyle = .lightContent
        }
        guard let isTextFieldEmpty = gamenameTextField.textField.text?.isEmpty else { return }
        
        if !isTextFieldEmpty {
            uploadButton.isEnabled = true
            uploadButton.backgroundColor = ColorCodes.clansportlerBlue
        }
        
    }
    
    func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    @objc func handleKeyboardWillShow(notification: NSNotification) {
        let keyboardFrame = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as AnyObject).cgRectValue
        let keyboardDuration = (notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue
        
        uploadButtonBottomAnchor?.constant = -keyboardFrame!.height
        uploadButtonWidthAnchor?.constant = view.frame.width
        uploadButton.layer.cornerRadius = 0
        
        UIView.animate(withDuration: keyboardDuration!) {
            self.view.layoutIfNeeded()
        }
    }
    
    @objc func handleKeyboardWillHide(notification: NSNotification) {
        let keyboardDuration = (notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue
        
        uploadButtonBottomAnchor?.constant = -16
        uploadButtonWidthAnchor?.constant = CGFloat(view.frame.width - 32)
        uploadButton.layer.cornerRadius = 5
        
        UIView.animate(withDuration: keyboardDuration!) {
            self.view.layoutIfNeeded()
        }
    }
    
}
