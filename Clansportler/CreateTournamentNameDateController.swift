//
//  CreateTeamNameAddressController.swift
//  Clansportler
//
//  Created by Luca Kiedrowski on 29.09.17.
//  Copyright © 2017 LucaKiedrowski. All rights reserved.
//

import UIKit
import Firebase

class CreateTournamentNameDateController: ScrollController/*, UIPickerViewDelegate, UIPickerViewDataSource*/ {
    
    var values: [String: Any]? {
        didSet {
            guard let imageUrl = values?["tournamentImageUrl"] as? String else { return }
            gameImageView.loadImage(urlString: imageUrl)
        }
    }
    
    var timestampDate: Date?
    
    lazy var datePickerView: UIDatePicker = {
        let picker = UIDatePicker()
        picker.backgroundColor = UIColor.white
        picker.addTarget(self, action: #selector(handlePickerChange), for: .valueChanged)
        return picker
    }()
    
    let gameImageView: CustomImageView = {
        let iv = CustomImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        return iv
    }()
    
    let dateTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Choose the Date"
        label.textColor = UIColor.white
        label.font = UIFont.boldSystemFont(ofSize: 16)
        return label
    }()
    
    lazy var dateTextField: UITextField = {
        let tf = UITextField()
        tf.textColor = UIColor.white
        tf.backgroundColor = .clear
        tf.placeholder = "Date"
        tf.tintColor = UIColor.white
        tf.autocorrectionType = .no
        tf.layer.cornerRadius = 5
        tf.setLeftPaddingPoints(5)
        tf.setRightPaddingPoints(5)
        tf.addTarget(self, action: #selector(handleInputChange), for: .editingChanged)
        return tf
    }()
    
    let organizerTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Organizer"
        label.textColor = UIColor.white
        label.font = UIFont.boldSystemFont(ofSize: 16)
        return label
    }()
    
    lazy var organizerTextField: UITextField = {
        let tf = UITextField()
        tf.textColor = UIColor.white
        tf.backgroundColor = .clear
        tf.placeholder = "Organizer"
        tf.tintColor = UIColor.white
        tf.autocorrectionType = .no
        tf.layer.cornerRadius = 5
        tf.setLeftPaddingPoints(5)
        tf.setRightPaddingPoints(5)
        tf.addTarget(self, action: #selector(handleInputChange), for: .editingChanged)
        return tf
    }()
    
    let teamTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Team Size (Between 1-5)"
        label.textColor = UIColor.white
        label.font = UIFont.boldSystemFont(ofSize: 16)
        return label
    }()
    
    lazy var teamTextField: UITextField = {
        let tf = UITextField()
        tf.textColor = UIColor.white
        tf.backgroundColor = .clear
        tf.placeholder = "Size"
        tf.tintColor = UIColor.white
        tf.autocorrectionType = .no
        tf.layer.cornerRadius = 5
        tf.setLeftPaddingPoints(5)
        tf.setRightPaddingPoints(5)
        tf.keyboardType = .numberPad
        tf.addTarget(self, action: #selector(handleInputChange), for: .editingChanged)
        return tf
    }()
    
    lazy var nextButton: ClansportlerRedButton = {
        let button = ClansportlerRedButton(title: "Next")
        button.backgroundColor = ColorCodes.disabledRed
        button.isEnabled = false
        button.addTarget(self, action: #selector(handleNext), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        super.setupScrollView(height: 1500)
        super.setupController()
        
        hideKeyboardWhenTappedAround(views: [view, scrollContainerView, scrollView])
        
        scrollView.backgroundColor = ColorCodes.clansportlerBlue
        scrollContainerView.backgroundColor = ColorCodes.clansportlerBlue
        
        setupViews()
    }
    
    override func setupViews() {
        
        scrollContainerView.addSubview(gameImageView)
        scrollContainerView.addSubview(dateTitleLabel)
        scrollContainerView.addSubview(dateTextField)
        scrollContainerView.addSubview(organizerTitleLabel)
        scrollContainerView.addSubview(organizerTextField)
        scrollContainerView.addSubview(teamTitleLabel)
        scrollContainerView.addSubview(teamTextField)
        scrollContainerView.addSubview(nextButton)
        
        dateTextField.inputView = datePickerView
        
        gameImageView.anchor(top: scrollContainerView.topAnchor, left: scrollContainerView.leftAnchor, bottom: nil, right: scrollContainerView.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 175)
        
        dateTitleLabel.anchor(top: gameImageView.bottomAnchor, left: scrollContainerView.leftAnchor, bottom: nil, right: scrollContainerView.rightAnchor, paddingTop: 8, paddingLeft: 8, paddingBottom: 0, paddingRight: 8, width: 0, height: 25)
        
        dateTextField.anchor(top: dateTitleLabel.bottomAnchor, left: scrollContainerView.leftAnchor, bottom: nil, right: scrollContainerView.rightAnchor, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 8, width: 0, height: 35)
        
        organizerTitleLabel.anchor(top: dateTextField.bottomAnchor, left: scrollContainerView.leftAnchor, bottom: nil, right: scrollContainerView.rightAnchor, paddingTop: 8, paddingLeft: 8, paddingBottom: 0, paddingRight: 8, width: 0, height: 25)
        
        organizerTextField.anchor(top: organizerTitleLabel.bottomAnchor, left: scrollContainerView.leftAnchor, bottom: nil, right: scrollContainerView.rightAnchor, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 8, width: 0, height: 35)
        
        teamTitleLabel.anchor(top: organizerTextField.bottomAnchor, left: scrollContainerView.leftAnchor, bottom: nil, right: scrollContainerView.rightAnchor, paddingTop: 8, paddingLeft: 8, paddingBottom: 0, paddingRight: 8, width: 0, height: 25)
        
        teamTextField.anchor(top: teamTitleLabel.bottomAnchor, left: scrollContainerView.leftAnchor, bottom: nil, right: scrollContainerView.rightAnchor, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 8, width: 0, height: 35)
        
        nextButton.anchor(top: teamTextField.bottomAnchor, left: scrollContainerView.leftAnchor, bottom: nil, right: scrollContainerView.rightAnchor, paddingTop: 8, paddingLeft: 8, paddingBottom: 0, paddingRight: 8, width: 0, height: 50)
        
    }
    
    @objc func handlePickerChange() {
        let dateFormatter: DateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy hh:mm"
        
        let selectedDate: String = dateFormatter.string(from: datePickerView.date)
        self.timestampDate = datePickerView.date
        dateTextField.text = selectedDate
    }
    
    @objc func handleNext() {
        guard let date = self.timestampDate else { return }
        let timestamp = date.timeIntervalSince1970
        
        let organizer = self.organizerTextField.text ?? ""
        guard let teamSizeString = teamTextField.text else { return }
        guard let teamSize = Int(teamSizeString) else { return }
        
        var values = self.values
        values?["tournamentTimestamp"] = timestamp
        values?["organizer"] = organizer
        values?["teamSize"] = teamSize
        
        let createTournamentRegistrationController = CreateTournamentRegistrationController()
        createTournamentRegistrationController.values = values
        self.show(createTournamentRegistrationController, sender: self)
    }
    
    @objc func handleInputChange() {
        if dateTextField.text?.characters.count ?? 0 > 0 && organizerTextField.text?.characters.count ?? 0 > 0 && teamTextField.text?.characters.count ?? 0 > 0 {
            nextButton.isEnabled = true
            nextButton.backgroundColor = ColorCodes.clansportlerRed
        } else {
            nextButton.isEnabled = false
            nextButton.backgroundColor = ColorCodes.disabledRed
        }
    }
    
}














