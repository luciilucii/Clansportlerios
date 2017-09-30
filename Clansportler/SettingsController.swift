//
//  SettingsController.swift
//  Clansportler
//
//  Created by Luca Kiedrowski on 20.08.17.
//  Copyright © 2017 LucaKiedrowski. All rights reserved.
//

import UIKit
import Firebase

class SingleSetting {
    
    var name: SettingName
    var controller: UIViewController
    var icon: UIImage?
    
    init(name: SettingName, controller: UIViewController, icon: UIImage?) {
        self.name = name
        self.controller = controller
        
        self.icon = icon?.withRenderingMode(.alwaysTemplate)
    }
    
}

enum SettingName: String {
    case approveGames = "Approve Games"
    case personalSettings = "Personal Settings"
    case payment = "Credit Card"
    case password = "Change Password"
    case playernames = "Connected Game Accounts"
    case deactivate = "Deactivate Account"
    case newTournament = "New Tournament"
}

class SettingsController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    let cellId = "cellId"
    var isAdmin = false {
        didSet {
            collectionView?.reloadData()
        }
    }
    
    let settingPoints: [SingleSetting] = {
        let personalSetting = SingleSetting(name: .personalSettings, controller: PersonalSettingsController(), icon: #imageLiteral(resourceName: "profile_settings_psd"))
        let paymentSetting = SingleSetting(name: .payment, controller: PaymentSettingsController(), icon: #imageLiteral(resourceName: "creditcard_psd"))
        let passwordSetting = SingleSetting(name: .password, controller: PasswordSettingController(), icon: #imageLiteral(resourceName: "password_settings_psd"))
        let playernameSetting = SingleSetting(name: .playernames, controller: GameAccountsSettingController(), icon: #imageLiteral(resourceName: "playernames_settings_psd"))
        let deactivateSetting = SingleSetting(name: .deactivate, controller: DeactivateAccountController(), icon: #imageLiteral(resourceName: "deactive_settings_psd"))
        
        let layout = UICollectionViewFlowLayout()
        let approveGameSetting = SingleSetting(name: .approveGames, controller: ApproveGamesController(collectionViewLayout: layout), icon: nil)
        let createTournamentSetting = SingleSetting(name: .newTournament, controller: CreateTournamentController(), icon: #imageLiteral(resourceName: "tournament_icon_new"))
        
        var points = [personalSetting, paymentSetting, passwordSetting, playernameSetting, deactivateSetting]
        
        if Auth.auth().currentUser?.uid == "JITuXtb8bldMKAiJXr1aPnjfgn92" {
            points.append(approveGameSetting)
            points.append(createTournamentSetting)
        }
        
        return points
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCollectionView()
        checkIfAdmin()
        setupWhiteTitle(title: "Settings")
    }
    
    func checkIfAdmin() {
        if Auth.auth().currentUser?.uid == "JITuXtb8bldMKAiJXr1aPnjfgn92" {
            self.isAdmin = true
        }
    }
    
    func setupCollectionView() {
        collectionView?.backgroundColor = ColorCodes.backgroundGrey
        collectionView?.register(SettingsCell.self, forCellWithReuseIdentifier: cellId)
        collectionView?.alwaysBounceVertical = true
        collectionView?.contentInset = UIEdgeInsetsMake(4, 0, 4, 0)
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return settingPoints.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width: CGFloat = view.frame.width - 16
        let height: CGFloat = 66
        
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 4
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! SettingsCell
        
        let settingPoint = settingPoints[indexPath.item]
        cell.singleSetting = settingPoint
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let settingPoint = settingPoints[indexPath.item]
        let controller = settingPoint.controller
        
        show(controller, sender: self)
    }
    
}















