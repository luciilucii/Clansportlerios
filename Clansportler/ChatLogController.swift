//
//  ChatLogController.swift
//  Clansportler
//
//  Created by Luca Kiedrowski on 31.07.17.
//  Copyright © 2017 LucaKiedrowski. All rights reserved.
//

import UIKit
import Firebase
import MobileCoreServices
import AVFoundation

var messageCache = [String: Message]()

class ChatLogController: UICollectionViewController, UITextFieldDelegate, UICollectionViewDelegateFlowLayout, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var user: User? {
        didSet {
            navigationItem.title = user?.username
            
            observeMessages()
        }
    }
    
    var group: Groupchat? {
        didSet {
            navigationItem.title = group?.name
            
            observeMessages()
        }
    }
    
    var messages = [Message]()
    
    func observeMessages() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        if let group = self.group {
            let groupId = group.id
            
            let messageRef = Database.database().reference().child("user-messages").child(groupId)
            observeMessageRef(ref: messageRef)
        }
        
        if let user = self.user {
            let userId = user.id
            
            let messageRef = Database.database().reference().child("user-messages").child(uid).child(userId)
            observeMessageRef(ref: messageRef)
            
        }
    }
    
    func observeMessageRef(ref: DatabaseReference) {
        ref.observe(.childAdded, with: { (snapshot) in
            
            let messageId = snapshot.key
            
            if let message = messageCache[messageId] {
                self.messages.append(message)
                self.messages.sort(by: { (m1, m2) -> Bool in
                    return m1.timestamp!.compare(m2.timestamp!) == .orderedAscending
                })
                return
            }
            let messagesRef = Database.database().reference().child("messages").child(messageId)
            messagesRef.observeSingleEvent(of: .value, with: { (snapshot) in
                
                guard let dictionary = snapshot.value as? [String: AnyObject] else {
                    return
                }
                let message = Message(dictionary: dictionary)
                self.messages.append(message)
                messageCache[messageId] = message
                self.messages.sort(by: { (m1, m2) -> Bool in
                    return m1.timestamp!.compare(m2.timestamp!) == .orderedAscending
                })
                
                self.updateSeenStatusInDatabase(messageId: messageId)
                
                DispatchQueue.main.async {
                    self.collectionView?.reloadData()
                    //scroll to the last index
                    
                    if self.messages.count > 14 {
                        let indexPath = IndexPath(item: self.messages.count - 1 , section: 0)
                        self.collectionView?.scrollToItem(at: indexPath, at: .bottom, animated: true)
                    }
                }
            }, withCancel: nil)
        }, withCancel: nil)
    }
    
    func updateSeenStatusInDatabase(messageId: String) {
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
        let messageRef = Database.database().reference().child("messages").child(messageId)
        let userHasSeenValues: [String: Any] = [currentUserId: true]
        let values: [String: Any] = ["hasSeen": userHasSeenValues]
        messageRef.updateChildValues(values) { (err, _) in
            if let err = err {
                print("failed to update Seen Status", err)
            }
        }
        let newMessageRef = Database.database().reference().child("user-messages").child(currentUserId).child("new-messages").child(messageId)
        newMessageRef.removeValue { (err, _) in
            if let err = err {
                print("failed to remove new-message", err)
            }
        }
    }
    
    lazy var inputTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Enter message..."
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.addTarget(self, action: #selector(handleChangeSendButton), for: .editingChanged)
        textField.delegate = self
        return textField
    }()
    
    var menu: Menu? {
        didSet {
            setupNavBarButtons()
        }
    }
    
    let cellId = "cellId"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let textAttributes = [NSAttributedStringKey.foregroundColor:UIColor.white]
        navigationController?.navigationBar.titleTextAttributes = textAttributes
        
        setupCollectionView()
        
        setupKeyboardObservers()
        
        navigationController?.navigationBar.tintColor = UIColor.white
        
    }
    
    fileprivate func setupCollectionView() {
        collectionView?.contentInset = UIEdgeInsetsMake(8, 0, 8, 0)
        collectionView?.showsVerticalScrollIndicator = true
        collectionView?.backgroundColor = ColorCodes.backgroundGrey
        collectionView?.register(ChatMessageCell.self, forCellWithReuseIdentifier: cellId)
        collectionView?.alwaysBounceVertical = true
        
        collectionView?.keyboardDismissMode = .interactive
    }
    
    func setupNavBarButtons() {
        let menuButton = UIBarButtonItem(image: #imageLiteral(resourceName: "Gruppe 5").withRenderingMode(.alwaysTemplate), style: .plain, target: self, action: #selector(handleMenu))
        menuButton.tintColor = .white
        navigationItem.leftBarButtonItem = menuButton
    }
    
    @objc func handleMenu() {
        view.endEditing(true)
//        inputContainerView.resignFirstResponder()
        inputContainerView.isHidden = true
        menu?.showMenu()
        menu?.startController = self
        menu?.chatLogController = self
    }
    
    lazy var sendButton: UIButton = {
        let sendButton = UIButton(type: .system)
        sendButton.setTitle("Send", for: .normal)
        sendButton.backgroundColor = UIColor.white
        sendButton.tintColor = ColorCodes.clansportlerBlue
        sendButton.isEnabled = false
        sendButton.addTarget(self, action: #selector(handleSend), for: .touchUpInside)
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        sendButton.layer.cornerRadius = 4
        return sendButton
    }()
    
    lazy var inputContainerView: UIView = {
        let containerView = UIView()
        containerView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 50)
        containerView.backgroundColor = UIColor.white
        
        let uploadImageView = UIImageView()
        uploadImageView.image = UIImage(named: "upload_image_icon")
        uploadImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleUploadTap)))
        uploadImageView.isUserInteractionEnabled = true
        uploadImageView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(uploadImageView)
        //x,y,w,h
        uploadImageView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        uploadImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        uploadImageView.widthAnchor.constraint(equalToConstant: 44).isActive = true
        uploadImageView.heightAnchor.constraint(equalToConstant: 44).isActive = true
        
        containerView.addSubview(self.sendButton)
        
        //x,y,w,h
        self.sendButton.rightAnchor.constraint(equalTo: containerView.rightAnchor, constant: -16).isActive = true
        self.sendButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        self.sendButton.widthAnchor.constraint(equalToConstant: 65).isActive = true
        self.sendButton.heightAnchor.constraint(equalToConstant: 35).isActive = true
        
        containerView.addSubview(self.inputTextField)
        
        //x,y,w,h
        self.inputTextField.leftAnchor.constraint(equalTo: uploadImageView.rightAnchor, constant: 8).isActive = true
        self.inputTextField.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        self.inputTextField.rightAnchor.constraint(equalTo: self.sendButton.leftAnchor, constant: -8).isActive = true
        self.inputTextField.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true
        
        let seperatorLineView = UIView()
        seperatorLineView.backgroundColor = ColorCodes.lightGrey
        seperatorLineView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(seperatorLineView)
        
        //x,y,w,h
        seperatorLineView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        seperatorLineView.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        seperatorLineView.widthAnchor.constraint(equalTo: containerView.widthAnchor).isActive = true
        seperatorLineView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        return containerView
    }()
    
    @objc func handleUploadTap() {
        let imagePickerController = UIImagePickerController()
        
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = true
        imagePickerController.mediaTypes = [kUTTypeImage as String]
        
        present(imagePickerController, animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
        if let videoUrl = info[UIImagePickerControllerMediaURL] as? URL {
            //we selected a video
            handleVideoSelectedFor(url: videoUrl)
        } else {
            // we selected an image
            handleImageSelectedForInfoDicionaryFor(info: info)
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    private func handleVideoSelectedFor(url: URL) {
        let filename = NSUUID().uuidString
        let uploadTask = Storage.storage().reference().child("message_movies").child(filename).putFile(from: url, metadata: nil, completion: { (metadata, error) in
            
            if error != nil {
                print("failed to upload video")
                return
            }
            
            if let videoUrl = metadata?.downloadURL()?.absoluteString {
                
                if let thumbnailImage = self.thumbnailImageFor(fileUrl: url) {
                    
                    self.uploadToFirebaseStorageUsing(image: thumbnailImage, completion: { (imageUrl) in
                        let properties = ["imageUrl": imageUrl, "imageWidth": thumbnailImage.size.width, "imageHeight": thumbnailImage.size.height, "videoUrl": videoUrl]  as [String: AnyObject]
                        self.sendMessage(withProperties: properties)
                        
                    })
                }
            }
        })
        
        uploadTask.observe(.progress) { (snapshot) in
            if let completedUnitCount = snapshot.progress?.completedUnitCount {
                self.navigationItem.title = String(completedUnitCount)
            }
        }
        
        uploadTask.observe(.success) { (snapshot) in
            self.navigationItem.title = self.user?.username
        }
    }
    
    private func thumbnailImageFor(fileUrl: URL) -> UIImage? {
        let asset = AVAsset(url: fileUrl)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        
        do {
            
            let thumbnailCGImage = try imageGenerator.copyCGImage(at: CMTimeMake(1, 60), actualTime: nil)
            
            return UIImage(cgImage: thumbnailCGImage)
            
        } catch let err {
            print(err)
        }
        
        return nil
    }
    
    private func handleImageSelectedForInfoDicionaryFor(info: [String : AnyObject]) {
        var selectedImageFromPicker: UIImage?
        
        if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage {
            selectedImageFromPicker = editedImage
        }
        if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            selectedImageFromPicker = originalImage
        }
        
        if let selectedImage = selectedImageFromPicker {
            uploadToFirebaseStorageUsing(image: selectedImage, completion: { (imageUrl) in
                self.sendMessage(WithImageUrl: imageUrl, image: selectedImage)
            })
        }
    }
    
    private func uploadToFirebaseStorageUsing(image: UIImage, completion: @escaping (_ imageUrl: String) -> ()) {
        let imageName = NSUUID().uuidString
        let ref = Storage.storage().reference().child("message_images").child(imageName)
        
        if let uploadData = UIImageJPEGRepresentation(image, 0.2) {
            ref.putData(uploadData, metadata: nil, completion: { (metadata, error) in
                
                if error != nil {
                    print("Failed to upload image", error?.localizedDescription ?? "")
                    return
                }
                
                if let imageUrl = metadata?.downloadURL()?.absoluteString {
                    completion(imageUrl)
                }
            })
            
        }
    }
    
    override var inputAccessoryView: UIView? {
        get {
            return inputContainerView
        }
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardDidShow), name: NSNotification.Name.UIKeyboardDidShow, object: nil)
    }
    
    @objc func handleKeyboardDidShow() {
        if messages.count > 0 {
            let indexPath = IndexPath(item: messages.count - 1, section: 0)
            collectionView?.scrollToItem(at: indexPath, at: .top, animated: true)
        }
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        
        NotificationCenter.default.removeObserver(self)
    }
    
    func handleKeyboardWillShow(notification: NSNotification) {
        let keyboardFrame = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as AnyObject).cgRectValue
        let keyboardDuration = (notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue
        
        containerViewBottomAnchor?.constant = -keyboardFrame!.height
        UIView.animate(withDuration: keyboardDuration!) {
            self.view.layoutIfNeeded()
        }
        
    }
    
    func handleKeyboardWillHide(notification: NSNotification) {
        
        let keyboardDuration = (notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue
        
        containerViewBottomAnchor?.constant = 0
        UIView.animate(withDuration: keyboardDuration!) {
            self.view.layoutIfNeeded()
        }
        
        
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! ChatMessageCell
        
        cell.chatLogController = self
        
        let message = messages[indexPath.item]
        
        cell.message = message
        
        cell.textView.text = message.text
        
        setupCell(cell: cell, message: message)
        
        if let text = message.text {
            cell.bubbleWidthAnchor?.constant = estimateFrameForText(text: text).width + 32
            cell.textView.isHidden = false
        } else if message.imageUrl != nil {
            //fall in here if its an image message
            cell.bubbleWidthAnchor?.constant = 200
            cell.textView.isHidden = true
        }
        
        cell.playButton.isHidden = message.videoUrl == nil
        
        return cell
    }
    
    private func setupCell(cell: ChatMessageCell, message: Message) {
        if let messageImageUrl = message.imageUrl {
            cell.messageImageView.loadImage(urlString: messageImageUrl)
            cell.messageImageView.isHidden = false
            cell.bubbleView.backgroundColor = UIColor.clear
            
        } else {
            cell.messageImageView.isHidden = true
        }
        
        if message.fromId == Auth.auth().currentUser?.uid {
            //outgoing blue
            cell.bubbleView.backgroundColor = ChatMessageCell.blueColor
            cell.textView.textColor = UIColor.white
            cell.profileImageView.isHidden = true
            
            cell.bubbleViewRightAnchor?.isActive = true
            cell.bubbleViewLeftAnchor?.isActive = false
            
        } else {
            //incoming grey
            cell.bubbleView.backgroundColor = UIColor.white
            cell.textView.textColor = UIColor.black
            
            cell.bubbleViewRightAnchor?.isActive = false
            cell.bubbleViewLeftAnchor?.isActive = true
            cell.profileImageView.isHidden = false
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        collectionView?.collectionViewLayout.invalidateLayout()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        var height: CGFloat = 80
        let message = messages[indexPath.item]
        
        if let text = message.text {
            height = estimateFrameForText(text: text).height + 40
        } else if let imageWidth = message.imageWidth?.floatValue, let imageHeight = message.imageHeight?.floatValue {
            
            height = CGFloat(imageHeight / imageWidth * 200)
            
        }
        let width = UIScreen.main.bounds.width
        return CGSize(width: width, height: height)
    }
    
    private func estimateFrameForText(text: String) -> CGRect {
        let size = CGSize(width: 200, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        
        return NSString(string: text).boundingRect(with: size, options: options, attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 16)], context: nil)
    }
    
    var containerViewBottomAnchor: NSLayoutConstraint?
    
    @objc func handleSend() {
        let properties = ["text": inputTextField.text!] as [String : AnyObject]
        sendMessage(withProperties: properties)
        
        disableSendButton()
    }
    
    private func disableSendButton() {
        sendButton.isEnabled = false
        sendButton.tintColor = ColorCodes.clansportlerBlue
        sendButton.backgroundColor = UIColor.white
    }
    
    private func sendMessage(WithImageUrl: String, image: UIImage) {
        
        let properties = ["imageUrl": WithImageUrl, "imageWidth": image.size.width, "imageHeight": image.size.height] as [String: AnyObject]
        
        sendMessage(withProperties: properties)
        
        disableSendButton()
    }
    
    private func sendMessage(withProperties: [String: AnyObject]) {
        let childName = UUID().uuidString
        
        let ref = Database.database().reference().child("messages")
        let childRef = ref.child(childName)
        
        var toId = ""
        
        if let group = self.group {
            let groupId = group.id
            toId = groupId
        }
        
        if let user = self.user {
            let userId = user.id
            toId = userId
        }
        
        let fromId = Auth.auth().currentUser!.uid
        let timestamp: Int = Int(NSDate().timeIntervalSince1970)
        
        let seenValues: [String: Any] = [fromId: true, toId: false]
        var values = ["toId": toId, "fromId": fromId, "timestamp": timestamp, "hasSeen": seenValues] as [String: AnyObject]
        
        //append properties dictionary onto values somehow??
        withProperties.forEach({values[$0] = $1})
        
        childRef.updateChildValues(values) { (error, ref) in
            if error != nil {
                print(error?.localizedDescription ?? "")
                return
            }
            self.inputTextField.text = nil
            
            let userMessagesRef = Database.database().reference().child("user-messages").child(fromId).child(toId)
            
            let messageId = childRef.key
            userMessagesRef.updateChildValues([messageId: 1])
            
            if self.user != nil {
                let recipientUserMessagesRef = Database.database().reference().child("user-messages").child(toId).child(fromId)
                recipientUserMessagesRef.updateChildValues([messageId: 1])
            }
            
            if self.group != nil {
                let groupMessageRef = Database.database().reference().child("user-messages").child(toId)
                groupMessageRef.updateChildValues([messageId: 1])
            }
        }
        handlePutInNewMessages(uuidString: childName, toId: toId)
    }
    
    func handlePutInNewMessages(uuidString: String, toId: String) {
        let newMessagesRef = Database.database().reference().child("user-messages").child(toId).child("new-messages")
        
        let values: [String: Any] = [uuidString: 1]
        newMessagesRef.updateChildValues(values) { (err, _) in
            if let err = err {
                print("failed to post in new messages", err)
            }
        }
    }
    
    @objc func handleChangeSendButton() {
        if inputTextField.text?.characters.count ?? 0 > 0 {
            sendButton.isEnabled = true
            sendButton.backgroundColor = ColorCodes.clansportlerBlue
            sendButton.tintColor = UIColor.white
        } else {
            disableSendButton()
        }
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        handleSend()
        return true
    }
    
    var startingFrame: CGRect?
    var blackBackgroundView: UIView?
    var startingImageView: UIImageView?
    
    //custom zooming logic
    func performZoomInFor(startingImageView: UIImageView) {
        
        self.startingImageView = startingImageView
        self.startingImageView?.isHidden = true
        startingFrame = startingImageView.superview?.convert(startingImageView.frame, to: nil)
        
        let zoomingImageView = UIImageView(frame: startingFrame!)
        zoomingImageView.backgroundColor = UIColor.red
        zoomingImageView.image = startingImageView.image
        zoomingImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleZoomOut)))
        zoomingImageView.isUserInteractionEnabled = true
        
        if let keyWindow = UIApplication.shared.keyWindow {
            
            blackBackgroundView = UIView(frame: keyWindow.frame)
            blackBackgroundView?.alpha = 0
            blackBackgroundView?.backgroundColor = .black
            keyWindow.addSubview(blackBackgroundView!)
            
            keyWindow.addSubview(zoomingImageView)
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                
                self.blackBackgroundView?.alpha = 1
                self.inputContainerView.alpha = 0
                
                //math
                //h2 = h1 / w1 * w1
                let height = self.startingFrame!.height / self.startingFrame!.width * keyWindow.frame.width
                
                zoomingImageView.frame = CGRect(x: 0, y: 0, width: keyWindow.frame.width, height: height)
                
                zoomingImageView.center = keyWindow.center
                
            }, completion: nil)
        }
    }
    
    @objc func handleZoomOut(tapGesture: UITapGestureRecognizer) {
        if let zoomOutImageView = tapGesture.view {
            //need to animate back out to controller
            zoomOutImageView.layer.cornerRadius = 16
            zoomOutImageView.clipsToBounds = true
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                
                zoomOutImageView.frame = self.startingFrame!
                self.blackBackgroundView?.alpha = 0
                self.inputContainerView.alpha = 1
                
            }, completion: { (completed: Bool) in
                zoomOutImageView.removeFromSuperview()
                self.startingImageView?.isHidden = false
            })
        }
    }
}
