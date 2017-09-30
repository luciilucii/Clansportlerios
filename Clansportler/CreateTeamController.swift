//
//  CreateTeamController.swift
//  Clansportler
//
//  Created by Luca Kiedrowski on 06.08.17.
//  Copyright © 2017 LucaKiedrowski. All rights reserved.
//

import UIKit

class CreateTeamController: UIViewController, UITextFieldDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDelegate, UICollectionViewDataSource {
    
    let cellId = "cellId"
    
    var homeController: HomeController?
    
    var selectedMembers = [User]() {
        didSet {
            if selectedMembers.count > 0 {
                chooseMembersButton.isHidden = true
                collectionView.isHidden = false
                collectionView.reloadData()
                
                if teamnameTextField.textField.text != "" {
                    continueButton.isEnabled = true
                    continueButton.backgroundColor = ColorCodes.clansportlerBlue
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.white
        
        setupKeyboardObservers()
        setupBarCancelButton()
        setupViews()
        setupCollectionView()
        
        hideKeyboardWhenTappedAround(views: [view])
    }
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Choose a Clan Name"
        label.font = UIFont.boldSystemFont(ofSize: 22)
        label.textColor = ColorCodes.darkestGrey
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    lazy var continueButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Continue", for: .normal)
        button.backgroundColor = ColorCodes.disabledBlue
        button.isEnabled = false
        button.tintColor = UIColor.white
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.addTarget(self, action: #selector(handleContinue), for: .touchUpInside)
        return button
    }()
    
    lazy var teamnameTextField: CustomAnimatedTextField = {
        let tf = CustomAnimatedTextField()
        tf.textField.addTarget(self, action: #selector(handleDidBeginEditingTeamname), for: .editingChanged)
        tf.animatedLabel.text = "Clan Name"
        tf.backgroundColor = .white
        tf.textField.delegate = self
        tf.textField.autocorrectionType = .no
        return tf
    }()
    
    let chooseMembersLabel: UILabel = {
        let label = UILabel()
        label.text = "Choose Members"
        label.font = UIFont.boldSystemFont(ofSize: 22)
        label.textColor = ColorCodes.darkestGrey
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    lazy var chooseMembersButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .white
        button.setTitle("Add Members", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.tintColor = ColorCodes.clansportlerBlue
        button.layer.borderWidth = 2
        button.layer.borderColor = ColorCodes.clansportlerBlue.cgColor
        button.layer.cornerRadius = 5
        button.addTarget(self, action: #selector(handleChooseMembers), for: .touchUpInside)
        return button
    }()
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.delegate = self
        cv.dataSource = self
        cv.isHidden = true
        cv.alwaysBounceHorizontal = true
        return cv
    }()
    
    var continueButtonBottomAnchor: NSLayoutConstraint?
    
    func setupViews() {
        
        view.addSubview(titleLabel)
        titleLabel.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 81, paddingLeft: 16, paddingBottom: 0, paddingRight: 16, width: 0, height: 35)
        
        view.addSubview(teamnameTextField)
        teamnameTextField.anchor(top: titleLabel.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 8, paddingLeft: 16, paddingBottom: 0, paddingRight: 16, width: 0, height: 50)
        
        view.addSubview(chooseMembersLabel)
        chooseMembersLabel.anchor(top: teamnameTextField.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 16, paddingLeft: 16, paddingBottom: 0, paddingRight: 16, width: 0, height: 35)
        
        view.addSubview(chooseMembersButton)
        chooseMembersButton.anchor(top: chooseMembersLabel.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 8, paddingLeft: 16, paddingBottom: 0, paddingRight: 16, width: 0, height: 50)
        
        view.addSubview(collectionView)
        collectionView.anchor(top: chooseMembersButton.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 125)
        
        view.addSubview(continueButton)
        
        continueButton.anchor(top: nil, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 44)
        
        continueButtonBottomAnchor = continueButton.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        continueButtonBottomAnchor?.isActive = true
        
    }
    
    func setupCollectionView() {
        collectionView.register(MemberCell.self, forCellWithReuseIdentifier: cellId)
        collectionView.backgroundColor = .white
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.contentInset = UIEdgeInsetsMake(0, 8, 0, 8)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return selectedMembers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! MemberCell
        
        cell.user = selectedMembers[indexPath.item]
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width: CGFloat = 100
        let height: CGFloat = 125
        
        return CGSize(width: width, height: height)
    }
    
    @objc func handleDidBeginEditingTeamname() {
        if teamnameTextField.textField.text != nil && selectedMembers.count > 0 {
            continueButton.isEnabled = true
            continueButton.backgroundColor = ColorCodes.clansportlerBlue
        }
    }
    
    @objc func handleChooseMembers() {
        let layout = UICollectionViewFlowLayout()
        let selectUserController = SelectUserCollectionViewController(collectionViewLayout: layout)
        
        navigationController?.pushViewController(selectUserController, animated: true)
        
        selectUserController.createTeamController = self
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
    
    @objc func handleContinue() {
        let teamImageController = TeamImageController()
        teamImageController.teamMember = selectedMembers
        teamImageController.homeController = homeController
        
        guard let teamname = teamnameTextField.textField.text else { return }
        teamImageController.teamname = teamname.lowercased()
        navigationController?.pushViewController(teamImageController, animated: true)
    }
    
}





