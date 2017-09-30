//
//  SearchMenuBar.swift
//  Clansportler
//
//  Created by Luca Kiedrowski on 16.09.17.
//  Copyright © 2017 LucaKiedrowski. All rights reserved.
//

import UIKit

protocol SearchMenuBarDelegate {
    
    func didSelectorMenuBarCell(searchMenuBarTitle: SearchMenuBarTitle)
    
}

enum SearchMenuBarTitle: String {
    case user = "Player"
    case clans = "Clans"
    case tournaments = "Tournaments"
}

class SearchMenuBar: CustomView , UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    let cellId = "cellId"
    
    var delegate: SearchMenuBarDelegate?
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.dataSource = self
        cv.delegate = self
        cv.backgroundColor = ColorCodes.backgroundGrey
        return cv
    }()
    
    override func setupCustomView() {
        super.setupCustomView()
        
        collectionView.register(SearchMenuBarCell.self, forCellWithReuseIdentifier: cellId)
        
        setupViews()
    }
    
    func setupViews() {
        addSubview(collectionView)
        
        collectionView.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        
        let seperatorView = UIView()
        seperatorView.backgroundColor = UIColor.white
        
        addSubview(seperatorView)
        seperatorView.anchor(top: nil, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0.5)
        
        setupHorizontalBar()
    }
    
    var horizontalBarLeftAnchorConstraint: NSLayoutConstraint?
    
    func setupHorizontalBar() {
        let horizontalBarView = UIView()
        horizontalBarView.backgroundColor = UIColor(white: 0.95, alpha: 1)
        addSubview(horizontalBarView)
        
        
        
        horizontalBarView.anchor(top: nil, left: nil, bottom: bottomAnchor, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 2)
        
        horizontalBarView.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 1/3).isActive = true
        
        horizontalBarLeftAnchorConstraint = horizontalBarView.leftAnchor.constraint(equalTo: self.leftAnchor)
        horizontalBarLeftAnchorConstraint?.isActive = true
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! SearchMenuBarCell
        
        switch indexPath.item {
        case 0:
            cell.titleLabel.text = SearchMenuBarTitle.user.rawValue
        case 1:
            cell.titleLabel.text = SearchMenuBarTitle.clans.rawValue
        case 2:
            cell.titleLabel.text = SearchMenuBarTitle.tournaments.rawValue
        default:
            break
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width: CGFloat = collectionView.frame.width/3
        let height: CGFloat = collectionView.frame.height
        
        
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let x = CGFloat(indexPath.item) * frame.width / 3
        horizontalBarLeftAnchorConstraint?.constant = x
        
        UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            
            self.layoutIfNeeded()
            
        }, completion: nil)
        
        switch indexPath.item {
        case 0:
            delegate?.didSelectorMenuBarCell(searchMenuBarTitle: .user)
        case 1:
            delegate?.didSelectorMenuBarCell(searchMenuBarTitle: .clans)
        case 2:
            delegate?.didSelectorMenuBarCell(searchMenuBarTitle: .tournaments)
        default:
            break
        }
    }
    
}

class SearchMenuBarCell: BaseCell {
    
    override var isSelected: Bool {
        didSet {
            titleLabel.font = isSelected ? UIFont.boldSystemFont(ofSize: 14) : UIFont.systemFont(ofSize: 14)
        }
    }
    
    override var isHighlighted: Bool {
        didSet {
            titleLabel.font = isHighlighted ? UIFont.boldSystemFont(ofSize: 14) : UIFont.systemFont(ofSize: 14)
        }
    }
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.white
        label.text = "Username"
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()
    
    override func setupCell() {
        super.setupCell()
        
        addSubview(titleLabel)
        
        titleLabel.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 2, paddingBottom: 0, paddingRight: 2, width: 0, height: 0)
    }
    
}















