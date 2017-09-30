//
//  JoinGroupModalController.swift
//  Clansportler
//
//  Created by Luca Kiedrowski on 10.09.17.
//  Copyright © 2017 LucaKiedrowski. All rights reserved.
//

import UIKit
import Firebase

protocol JoinGroupModalControllerDelegate {
    func didTapJoin(joinGroupModalController: JoinGroupModalController)
    func didTapCancel(joinGroupModalController: JoinGroupModalController)
}

class JoinGroupModalController: UIViewController {
    
    var delegate: JoinGroupModalControllerDelegate?
    
    let whiteView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 5
        return view
    }()
    
    lazy var joinButton: ClansportlerRedButton = {
        let button = ClansportlerRedButton(title: "Join")
        button.addTarget(self, action: #selector(joinGroup), for: .touchUpInside)
        return button
    }()
    
    lazy var cancelButton: ClansportlerBorderButton = {
        let button = ClansportlerBorderButton(title: "Cancel", tintColor: ColorCodes.clansportlerBlue)
        button.addTarget(self, action: #selector(handleCancel), for: .touchUpInside)
        return button
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Join Group"
        label.textColor = ColorCodes.middleGrey
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.textAlignment = .center
        return label
    }()
    
    let textLabel: UILabel = {
        let label = UILabel()
        label.text = "Do you want to join the group?"
        label.textColor = ColorCodes.middleGrey
        label.font = UIFont.systemFont(ofSize: 16)
        label.textAlignment = .center
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        
        view.backgroundColor = UIColor(white: 0, alpha: 0.5)
        view.isOpaque = false
        
        view.addSubview(whiteView)
        
        whiteView.anchor(top: nil, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 0, paddingLeft: 16, paddingBottom: 0, paddingRight: 16, width: 0, height: 150)
        whiteView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
        whiteView.addSubview(joinButton)
        whiteView.addSubview(cancelButton)
        whiteView.addSubview(titleLabel)
        whiteView.addSubview(textLabel)
        
        joinButton.anchor(top: nil, left: whiteView.centerXAnchor, bottom: whiteView.bottomAnchor, right: whiteView.rightAnchor, paddingTop: 0, paddingLeft: 4, paddingBottom: 8, paddingRight: 8, width: 0, height: 45)
        
        cancelButton.anchor(top: nil, left: whiteView.leftAnchor, bottom: whiteView.bottomAnchor, right: whiteView.centerXAnchor, paddingTop: 0, paddingLeft: 8, paddingBottom: 8, paddingRight: 4, width: 0, height: 45)
        
        titleLabel.anchor(top: whiteView.topAnchor, left: whiteView.leftAnchor, bottom: nil, right: whiteView.rightAnchor, paddingTop: 12, paddingLeft: 8, paddingBottom: 0, paddingRight: 8, width: 0, height: 30)
        
        textLabel.anchor(top: titleLabel.bottomAnchor, left: whiteView.leftAnchor, bottom: cancelButton.topAnchor, right: whiteView.rightAnchor, paddingTop: 0, paddingLeft: 8, paddingBottom: 8, paddingRight: 8, width: 0, height: 0)
        
        
    }
    
    @objc func joinGroup() {
        delegate?.didTapJoin(joinGroupModalController: self)
    }
    
    @objc func handleCancel() {
        delegate?.didTapCancel(joinGroupModalController: self)
    }
    
}
