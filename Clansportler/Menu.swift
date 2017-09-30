//
//  Menu.swift
//  Clansportler
//
//  Created by Luca Kiedrowski on 30.07.17.
//  Copyright © 2017 LucaKiedrowski. All rights reserved.
//

import UIKit
import Firebase

class Menu: NSObject, UICollectionViewDelegate, UITextFieldDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    let blackView = UIView()
    
    var currentUser: User?
    
    var startController: UIViewController?
    var endController: UIViewController?
    
    var homeController: HomeController?
    
    var chatLogController: ChatLogController?
    
    let menuView: UIView = {
        let view = UIView()
        view.backgroundColor = ColorCodes.darkestGrey
        return view
    }()
    
    let teamCellId = "teamCellId"
    let chatCellId = "chatCellId"
    let tournamentCellId = "tournamentCellId"
    
    override init() {
        super.init()
        
        setupCollectionView()
    }
    
    fileprivate func setupCollectionView() {
        
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.allowsMultipleSelection = false
        collectionView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0)
        
        collectionView.register(TeamMenuCell.self, forCellWithReuseIdentifier: teamCellId)
        collectionView.register(ChatMenuCell.self, forCellWithReuseIdentifier: chatCellId)
        collectionView.register(TournamentMenuCell.self, forCellWithReuseIdentifier: tournamentCellId)
        
    }
    
    func showMenu() {
        
        if let window = UIApplication.shared.keyWindow {
            
            blackView.backgroundColor = UIColor(white: 0, alpha: 0.5)
            blackView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleDismiss)))
            
            window.addSubview(blackView)
            window.addSubview(menuView)
            
            setupMenu()
            
            NotificationCenter.default.post(name: MessagesCell.resetBadgesNotification, object: nil)
            
            //x,y,w,h
            let menuWidth = window.frame.width / 1.33
            menuView.frame = CGRect(x: -menuWidth, y: 0, width: menuWidth, height: window.frame.height)
            
            
            blackView.frame = window.frame
            blackView.alpha = 0
            
            collectionView.reloadData()
            
            UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                
                self.blackView.alpha = 1
                self.menuView.frame = CGRect(x: 0, y: 0, width: menuWidth, height: window.frame.height)
                
                window.windowLevel = UIWindowLevelStatusBar
                
            }, completion: { (_) in
                
                let startIndexPath = IndexPath(item: 1, section: 0)
                self.collectionView.scrollToItem(at: startIndexPath, at: .top, animated: false)
                
                self.chatLogController?.inputContainerView.endEditing(true)
                self.chatLogController?.inputTextField.resignFirstResponder()
                self.chatLogController?.inputContainerView.isHidden = true
            })
            
        }
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        
        guard let window = UIApplication.shared.keyWindow else { return }
        let pageNumber = targetContentOffset.pointee.x / (window.frame.width / 1.33)
        let roundedPageNumber = Int(pageNumber.rounded())
        
        pageControl.currentPage = roundedPageNumber
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        
        switch (indexPath.item) {
        case 0:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: teamCellId, for: indexPath) as! TeamMenuCell
            
            cell.menu = self
            cell.currentUser = currentUser
            
            return cell
        case 1:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: chatCellId, for: indexPath) as! ChatMenuCell
            
            cell.menu = self
            cell.currentUser = currentUser
            
            return cell
        default:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: tournamentCellId, for: indexPath) as! TournamentMenuCell
            
            
            
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        guard let window = UIApplication.shared.keyWindow else {
            return CGSize(width: 0, height: 0)
        }
        
        let width = window.frame.width / 1.33
        let height = window.frame.height
        
        return CGSize(width: width, height: height)
    }
    
    func showMenuController(controller: UIViewController) {
        startController?.present(controller, animated: false, completion: nil)
    }
    
    @objc func handleDismiss() {
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            
            self.blackView.alpha = 0
            
            if let window = UIApplication.shared.keyWindow {
                
                let menuWidth = window.frame.width / 1.5
                self.menuView.frame = CGRect(x: -menuWidth, y: 0, width: menuWidth, height: window.frame.height)
                window.windowLevel = UIWindowLevelNormal
            }
            
        }, completion: { (_) in
            if let chatLogController = self.chatLogController {
                chatLogController.inputContainerView.isHidden = false
                chatLogController.inputTextField.resignFirstResponder()
            }
        })
    }
    
    let pageControl: UIPageControl = {
        let pc = UIPageControl()
        pc.pageIndicatorTintColor = UIColor(white: 1, alpha: 0.5)
        pc.currentPageIndicatorTintColor = UIColor.white
        pc.numberOfPages = 3
        return pc
    }()
    
    let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = ColorCodes.darkestGrey
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.isPagingEnabled = true
        cv.showsHorizontalScrollIndicator = false
        return cv
    }()
    
    func setupMenu() {
        
        menuView.addSubview(collectionView)
        menuView.addSubview(pageControl)
        
        //x,y,w,h
        collectionView.topAnchor.constraint(equalTo: menuView.topAnchor).isActive = true
        collectionView.leftAnchor.constraint(equalTo: menuView.leftAnchor).isActive = true
        collectionView.rightAnchor.constraint(equalTo: menuView.rightAnchor).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: menuView.bottomAnchor).isActive = true
        
        pageControl.anchor(top: nil, left: nil, bottom: menuView.bottomAnchor, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 100, height: 30)
        pageControl.centerXAnchor.constraint(equalTo: menuView.centerXAnchor).isActive = true
        
    }
    
}



