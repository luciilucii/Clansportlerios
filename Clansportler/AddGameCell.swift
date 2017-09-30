//
//  AddGameCell.swift
//  Clansportler
//
//  Created by Luca Kiedrowski on 15.08.17.
//  Copyright © 2017 LucaKiedrowski. All rights reserved.
//

import UIKit

class AddGameCell: BaseCell {
    
    var chooseGamesController: ChooseGamesController?
    
    lazy var plusButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("+", for: .normal)
        button.tintColor = ColorCodes.clansportlerBlue
        button.backgroundColor = ColorCodes.disabledBlue
        button.layer.borderColor = ColorCodes.clansportlerBlue.cgColor
        button.layer.borderWidth = 2
        button.layer.cornerRadius = 5
        button.titleLabel?.font = UIFont.systemFont(ofSize: 75)
        button.addTarget(self, action: #selector(handleAddGame), for: .touchUpInside)
        return button
    }()
    
    override func setupCell() {
        super.setupCell()
        
        self.layer.cornerRadius = 5
        self.backgroundColor = ColorCodes.disabledBlue
        
        addSubview(plusButton)
        plusButton.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
    }
    
    @objc func handleAddGame() {
        let addGameController = AddGameController()
        
        chooseGamesController?.navigationController?.pushViewController(addGameController, animated: true)
        
    }
    
}
