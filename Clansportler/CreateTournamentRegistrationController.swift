//
//  CreateTournamentRegistrationController.swift
//  Clansportler
//
//  Created by Luca Kiedrowski on 30.09.17.
//  Copyright © 2017 LucaKiedrowski. All rights reserved.
//

import UIKit
import Firebase

enum MatchFormat: String {
    case one = "One"
    case bo3 = "Best of 3"
    case bo5 = "Best of 5"
    case bo7 = "Best of 7"
    case bo9 = "Best of 9"
    case bo11 = "Best of 11"
}

class CreateTournamentRegistrationController: ScrollController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    var values: [String: Any]? {
        didSet {
            if let imageUrl = values?["tournamentImageUrl"] as? String {
                gameImageView.loadImage(urlString: imageUrl)
            }
            
            guard let values = values else { return }
            let tournamentId = UUID().uuidString
            let tournament = Tournament(id: tournamentId, values: values)
            self.tournament = tournament
        }
    }
    
    var tournament: Tournament? {
        didSet {
            tournamentBasicsView.tournament = tournament
        }
    }
    
    var choosenDate: Date? {
        didSet {
            if choosenMatchFormat != nil {
                self.nextButton.isEnabled = true
                self.nextButton.backgroundColor = ColorCodes.clansportlerRed
            }
        }
    }
    
    var choosenMatchFormat: MatchFormat? {
        didSet {
            if choosenDate != nil {
                self.nextButton.isEnabled = true
                self.nextButton.backgroundColor = ColorCodes.clansportlerRed
            }
        }
    }
    
    let matchFormats: [MatchFormat] = {
        return [.one, .bo3, .bo5, .bo7, .bo9, .bo11]
    }()
    
    lazy var matchFormatPicker: UIPickerView = {
        let pickerView = UIPickerView()
        pickerView.delegate = self
        pickerView.dataSource = self
        return pickerView
    }()
    
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
    
    let tournamentBasicsView: TournamentBasicsView = {
        let view = TournamentBasicsView()
        view.backgroundColor = ColorCodes.clansportlerPurple 
        return view
    }()
    
    let registrationTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Registration Date"
        label.textColor = UIColor.white
        label.font = UIFont.boldSystemFont(ofSize: 16)
        return label
    }()
    
    lazy var registrationTextField: UITextField = {
        let tf = UITextField()
        tf.textColor = UIColor.white
        tf.backgroundColor = .clear
        tf.placeholder = "Date"
        tf.tintColor = UIColor.white
        tf.autocorrectionType = .no
        tf.layer.cornerRadius = 5
        tf.setLeftPaddingPoints(5)
        tf.setRightPaddingPoints(5)
        return tf
    }()
    
    let matchFormatLabel: UILabel = {
        let label = UILabel()
        label.text = "Match Format"
        label.textColor = UIColor.white
        label.font = UIFont.boldSystemFont(ofSize: 16)
        return label
    }()
    
    lazy var matchFormatTextField: UITextField = {
        let tf = UITextField()
        tf.textColor = UIColor.white
        tf.backgroundColor = .clear
        tf.placeholder = "Format"
        tf.tintColor = UIColor.white
        tf.autocorrectionType = .no
        tf.layer.cornerRadius = 5
        tf.setLeftPaddingPoints(5)
        tf.setRightPaddingPoints(5)
        return tf
    }()
    
    lazy var nextButton: ClansportlerRedButton = {
        let button = ClansportlerRedButton(title: "Upload")
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
        scrollContainerView.addSubview(tournamentBasicsView)
        scrollContainerView.addSubview(registrationTitleLabel)
        scrollContainerView.addSubview(registrationTextField)
        scrollContainerView.addSubview(matchFormatLabel)
        scrollContainerView.addSubview(matchFormatTextField)
        scrollContainerView.addSubview(nextButton)
        
        registrationTextField.inputView = datePickerView
        matchFormatTextField.inputView = matchFormatPicker
        
        gameImageView.anchor(top: scrollContainerView.topAnchor, left: scrollContainerView.leftAnchor, bottom: nil, right: scrollContainerView.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 175)
        
        tournamentBasicsView.anchor(top: gameImageView.bottomAnchor, left: scrollContainerView.leftAnchor, bottom: nil, right: scrollContainerView.rightAnchor, paddingTop: 8, paddingLeft: 8, paddingBottom: 0, paddingRight: 8, width: 0, height: 166)
        
        registrationTitleLabel.anchor(top: tournamentBasicsView.bottomAnchor, left: scrollContainerView.leftAnchor, bottom: nil, right: scrollContainerView.rightAnchor, paddingTop: 8, paddingLeft: 8, paddingBottom: 0, paddingRight: 8, width: 0, height: 25)
        
        registrationTextField.anchor(top: registrationTitleLabel.bottomAnchor, left: scrollContainerView.leftAnchor, bottom: nil, right: scrollContainerView.rightAnchor, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 8, width: 0, height: 35)
        
        matchFormatLabel.anchor(top: registrationTextField.bottomAnchor, left: scrollContainerView.leftAnchor, bottom: nil, right: scrollContainerView.rightAnchor, paddingTop: 8, paddingLeft: 8, paddingBottom: 0, paddingRight: 8, width: 0, height: 25)
        
        matchFormatTextField.anchor(top: matchFormatLabel.bottomAnchor, left: scrollContainerView.leftAnchor, bottom: nil, right: scrollContainerView.rightAnchor, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 8, width: 0, height: 35)
        
        nextButton.anchor(top: matchFormatTextField.bottomAnchor, left: scrollContainerView.leftAnchor, bottom: nil, right: scrollContainerView.rightAnchor, paddingTop: 8, paddingLeft: 8, paddingBottom: 0, paddingRight: 8, width: 0, height: 50)
        
        
    }
    
    @objc func handlePickerChange() {
        let dateFormatter: DateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy hh:mm"
        
        let selectedDate: String = dateFormatter.string(from: datePickerView.date)
        self.choosenDate = datePickerView.date
        registrationTextField.text = selectedDate
    }
    
    @objc func handleNext() {
        let tournamentId = UUID().uuidString
        guard let registrationTimestamp = self.choosenDate?.timeIntervalSince1970 else { return }
        guard let matchFormat = self.choosenMatchFormat else { return }
        self.values?["registrationTimestamp"] = registrationTimestamp
        self.values?["matchFormat"] = matchFormat.rawValue
        
        guard let tournamentValues = self.values else { return }
        
        let tournamentRef = Database.database().reference().child("tournaments").child(tournamentId)
        tournamentRef.updateChildValues(tournamentValues) { (err, _) in
            if let err = err {
                print("failed to upload tournament", err)
            } else {
                self.dismiss(animated: true, completion: {
                    //completion here
                })
            }
        }
    }
    
    //MARK: PickerView
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let matchFormat = matchFormats[row]
        
        return matchFormat.rawValue
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return matchFormats.count
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let matchFormat = matchFormats[row]
        self.choosenMatchFormat = matchFormat
        self.matchFormatTextField.text = matchFormat.rawValue
        
    }
    
}













