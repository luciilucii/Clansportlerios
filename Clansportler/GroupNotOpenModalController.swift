//
//  GroupNotOpenModalController.swift
//  Clansportler
//
//  Created by Luca Kiedrowski on 13.09.17.
//  Copyright © 2017 LucaKiedrowski. All rights reserved.
//

import UIKit

class GroupNotOpenModalController: UIViewController {
    
    var openGroupController: OpenGroupController?
    
    let whiteView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 5
        return view
    }()
    
    lazy var cancelButton: ClansportlerBorderButton = {
        let button = ClansportlerBorderButton(title: "Dismiss", tintColor: ColorCodes.clansportlerBlue)
        button.addTarget(self, action: #selector(handleCancel), for: .touchUpInside)
        return button
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Group is closed"
        label.textColor = ColorCodes.middleGrey
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.textAlignment = .center
        return label
    }()
    
    let textLabel: UILabel = {
        let label = UILabel()
        label.text = "Sorry, but the group is closed now."
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
        
        whiteView.addSubview(cancelButton)
        whiteView.addSubview(titleLabel)
        whiteView.addSubview(textLabel)
        
        cancelButton.anchor(top: nil, left: whiteView.leftAnchor, bottom: whiteView.bottomAnchor, right: whiteView.rightAnchor, paddingTop: 0, paddingLeft: 8, paddingBottom: 8, paddingRight: 8, width: 0, height: 45)
        
        titleLabel.anchor(top: whiteView.topAnchor, left: whiteView.leftAnchor, bottom: nil, right: whiteView.rightAnchor, paddingTop: 12, paddingLeft: 8, paddingBottom: 0, paddingRight: 8, width: 0, height: 30)
        
        textLabel.anchor(top: titleLabel.bottomAnchor, left: whiteView.leftAnchor, bottom: cancelButton.topAnchor, right: whiteView.rightAnchor, paddingTop: 0, paddingLeft: 8, paddingBottom: 8, paddingRight: 8, width: 0, height: 0)
        
    }
    
    @objc func handleCancel() {
        self.dismiss(animated: true) { 
            //completion here
            self.openGroupController?.dismiss(animated: true, completion: nil)
        }
    }
    
}
