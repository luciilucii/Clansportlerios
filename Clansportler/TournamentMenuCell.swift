//
//  TournamentMenuCell.swift
//  Clansportler
//
//  Created by Luca Kiedrowski on 30.07.17.
//  Copyright © 2017 LucaKiedrowski. All rights reserved.
//

import UIKit

class TournamentMenuCell: BaseCell {
    
    let comingLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.white
        label.text = "Tournaments are coming..."
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 16)
        return label
    }()
    
    let navBarContainer: UIView = {
        let view = UIView()
        
        view.backgroundColor = ColorCodes.darkestGrey
        
        let seperatorView = UIView()
        seperatorView.backgroundColor = UIColor.white
        
        view.addSubview(seperatorView)
        seperatorView.anchor(top: nil, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0.5)
        
        return view
    }()
    
    let chatTitlelabel: UILabel = {
        let label = UILabel()
        label.text = "Tournaments"
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.textColor = UIColor.white
        return label
    }()
    
    func setupNavBarContainer() {
        navBarContainer.addSubview(chatTitlelabel)
        
        chatTitlelabel.anchor(top: navBarContainer.topAnchor, left: navBarContainer.leftAnchor, bottom: navBarContainer.bottomAnchor, right: navBarContainer.rightAnchor, paddingTop: 2, paddingLeft: 8, paddingBottom: 2, paddingRight: 8, width: 0, height: 0)
        
    }
    
    override func setupCell() {
        super.setupCell()
        
        backgroundColor = ColorCodes.darkestGrey
        
        addSubview(comingLabel)
        comingLabel.anchor(top: nil, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 4, paddingBottom: 0, paddingRight: 4, width: 0, height: 30)
        comingLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
        addSubview(navBarContainer)
        
        navBarContainer.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 45)
        
        setupNavBarContainer()
    }
    
}
