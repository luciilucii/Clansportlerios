//
//  NewTournamentController.swift
//  Clansportler
//
//  Created by Luca Kiedrowski on 28.09.17.
//  Copyright © 2017 LucaKiedrowski. All rights reserved.
//

import UIKit
import Firebase

class CreateTournamentController: ScrollController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    var games = [Game]()
    var pickerView = UIPickerView()
    
    var choosenGame: Game?
    
    let chooseGamesTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Choose a Game"
        label.textColor = UIColor.white
        label.font = UIFont.boldSystemFont(ofSize: 16)
        return label
    }()
    
    lazy var gameTextField: UITextField = {
        let tf = UITextField()
        tf.textColor = UIColor.white
        tf.backgroundColor = .clear
//        tf.layer.borderColor = UIColor.white.cgColor
//        tf.layer.borderWidth = 1
        tf.placeholder = "Game"
        tf.tintColor = UIColor.white
        tf.layer.cornerRadius = 5
        tf.setLeftPaddingPoints(5)
        tf.setRightPaddingPoints(5)
        tf.addTarget(self, action: #selector(handleInputChange), for: .editingChanged)
        return tf
    }()
    
    let shortTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Short Title"
        label.textColor = UIColor.white
        label.font = UIFont.boldSystemFont(ofSize: 16)
        return label
    }()
    
    lazy var shortTitleTextField: UITextField = {
        let tf = UITextField()
        tf.textColor = UIColor.white
        tf.backgroundColor = .clear
//        tf.layer.borderColor = UIColor.white.cgColor
//        tf.layer.borderWidth = 1
        tf.placeholder = "Short Title"
        tf.tintColor = UIColor.white
        tf.autocorrectionType = .no
        tf.layer.cornerRadius = 5
        tf.setLeftPaddingPoints(5)
        tf.setRightPaddingPoints(5)
        tf.addTarget(self, action: #selector(handleInputChange), for: .editingChanged)
        return tf
    }()
    
    let fullTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Full Name of the Tournament"
        label.textColor = UIColor.white
        label.font = UIFont.boldSystemFont(ofSize: 16)
        return label
    }()
    
    lazy var fullTitleTextField: UITextField = {
        let tf = UITextField()
        tf.textColor = UIColor.white
        tf.backgroundColor = .clear
//        tf.layer.borderColor = UIColor.white.cgColor
//        tf.layer.borderWidth = 1
        tf.placeholder = "Full Name"
        tf.tintColor = UIColor.white
        tf.autocorrectionType = .no
        tf.layer.cornerRadius = 5
        tf.setLeftPaddingPoints(5)
        tf.setRightPaddingPoints(5)
        tf.addTarget(self, action: #selector(handleInputChange), for: .editingChanged)
        return tf
    }()
    
    let playerLabel: UILabel = {
        let label = UILabel()
        label.text = "How many players/teams can participate?"
        label.textColor = UIColor.white
        label.font = UIFont.boldSystemFont(ofSize: 16)
        return label
    }()
    
    lazy var playerTextField: UITextField = {
        let tf = UITextField()
        tf.textColor = UIColor.white
        tf.backgroundColor = .clear
//        tf.layer.borderColor = UIColor.white.cgColor
//        tf.layer.borderWidth = 1
        tf.placeholder = "Number of Players/Teams"
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
        super.setupScrollView(height: view.frame.height)
        super.setupController()
        
        hideKeyboardWhenTappedAround(views: [view, scrollContainerView, scrollView])
        
        scrollView.backgroundColor = ColorCodes.clansportlerBlue
        scrollContainerView.backgroundColor = ColorCodes.clansportlerBlue
        
        fetchGames()
        setupViews()
    }
    
    override func setupViews() {
        pickerView.dataSource = self
        pickerView.delegate = self
        
        gameTextField.inputView = pickerView
        
        scrollContainerView.addSubview(chooseGamesTitleLabel)
        scrollContainerView.addSubview(gameTextField)
        scrollContainerView.addSubview(shortTitleLabel)
        scrollContainerView.addSubview(shortTitleTextField)
        scrollContainerView.addSubview(fullTitleLabel)
        scrollContainerView.addSubview(fullTitleTextField)
        scrollContainerView.addSubview(playerLabel)
        scrollContainerView.addSubview(playerTextField)
        scrollContainerView.addSubview(nextButton)
        
        chooseGamesTitleLabel.anchor(top: scrollContainerView.topAnchor, left: scrollContainerView.leftAnchor, bottom: nil, right: scrollContainerView.rightAnchor, paddingTop: 8, paddingLeft: 8, paddingBottom: 0, paddingRight: 8, width: 0, height: 25)
        
        gameTextField.anchor(top: chooseGamesTitleLabel.bottomAnchor, left: scrollContainerView.leftAnchor, bottom: nil, right: scrollContainerView.rightAnchor, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 8, width: 0, height: 35)
        
        shortTitleLabel.anchor(top: gameTextField.bottomAnchor, left: scrollContainerView.leftAnchor, bottom: nil, right: scrollContainerView.rightAnchor, paddingTop: 8, paddingLeft: 8, paddingBottom: 0, paddingRight: 8, width: 0, height: 25)
        
        shortTitleTextField.anchor(top: shortTitleLabel.bottomAnchor, left: scrollContainerView.leftAnchor, bottom: nil, right: scrollContainerView.rightAnchor, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 8, width: 0, height: 35)
        
        fullTitleLabel.anchor(top: shortTitleTextField.bottomAnchor, left: scrollContainerView.leftAnchor, bottom: nil, right: scrollContainerView.rightAnchor, paddingTop: 8, paddingLeft: 8, paddingBottom: 0, paddingRight: 8, width: 0, height: 25)
        
        fullTitleTextField.anchor(top: fullTitleLabel.bottomAnchor, left: scrollContainerView.leftAnchor, bottom: nil, right: scrollContainerView.rightAnchor, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 8, width: 0, height: 35)
        
        playerLabel.anchor(top: fullTitleTextField.bottomAnchor, left: scrollContainerView.leftAnchor, bottom: nil, right: scrollContainerView.rightAnchor, paddingTop: 8, paddingLeft: 8, paddingBottom: 0, paddingRight: 8, width: 0, height: 25)
        
        playerTextField.anchor(top: playerLabel.bottomAnchor, left: scrollContainerView.leftAnchor, bottom: nil, right: scrollContainerView.rightAnchor, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 8, width: 0, height: 35)
        
        nextButton.anchor(top: playerTextField.bottomAnchor, left: scrollContainerView.leftAnchor, bottom: nil, right: scrollContainerView.rightAnchor, paddingTop: 8, paddingLeft: 8, paddingBottom: 0, paddingRight: 8, width: 0, height: 50)
        
        
    }
    
    fileprivate func fetchGames() {
        let approveGamesRef = Database.database().reference().child("games").child("approvedGames")
        approveGamesRef.observeSingleEvent(of: .value, with: { (snapshot) in
            guard let dictionary = snapshot.value as? [String: Any] else { return }
            dictionary.forEach({ (key, value) in
                Database.fetchGameWithId(id: key, completion: { (game) in
                    self.games.append(game)
                    self.pickerView.reloadAllComponents()
                })
            })
        }) { (err) in
            print("failed to fetch approved Games", err)
        }
    }
    
    @objc func handleInputChange() {
        
        if gameTextField.text?.characters.count ?? 0 > 0 && shortTitleTextField.text?.characters.count ?? 0 > 0 && fullTitleTextField.text?.characters.count ?? 0 > 0 && playerTextField.text?.characters.count ?? 0 > 0 {
            nextButton.isEnabled = true
            nextButton.backgroundColor = ColorCodes.clansportlerRed
        } else {
            nextButton.isEnabled = false
            nextButton.backgroundColor = ColorCodes.disabledRed
        }
    }
    
    @objc func handleNext() {
        guard let playerCountString = playerTextField.text else { return }
        guard let playerCountDouble = Double(playerCountString) else { return }
        
        let exponent = log2(playerCountDouble)
        
        let isInteger = floor(exponent) == exponent
        if !isInteger || playerCountDouble > 257 {
            let alertController = UIAlertController(title: "We're Sorry", message: "Please make sure that the player count is possible for a bracket and/or under 256.", preferredStyle: .alert)
            
            alertController.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: { (_) in
                alertController.dismiss(animated: true, completion: {
                    //completion here
                })
            }))
            
            self.present(alertController, animated: true, completion: {
                //completion here
            })
        } else {
            guard let game = self.choosenGame else { return }
            guard let shortTitle = self.shortTitleTextField.text, let fullTitle = self.fullTitleTextField.text else { return }
            guard let gameImageUrl = game.imageUrl else { return }
            
            let values: [String: Any] = ["playerCount": playerCountDouble, "shortName": shortTitle, "fullName": fullTitle, "gameId": game.id, "gameImageUrl": gameImageUrl]
            
            let createTournamentPictureController = CreateTournamentPictureController()
            createTournamentPictureController.values = values
            self.show(createTournamentPictureController, sender: self)
        }
    }
    
    //MARK: PickerView
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        if row == 0 {
            return "No Selection"
        }
        
        let game = games[row - 1]
        guard let gamename = game.name else { return "" }
        
        return gamename
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return games.count + 1
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        if row == 0 {
            gameTextField.text = ""
            return
        }
        let game = games[row - 1]
        
        self.choosenGame = game
        guard let gamename = game.name else { return }
        
        gameTextField.text = gamename
    }
    
}














