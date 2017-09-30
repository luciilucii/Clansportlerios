//
//  ScrollController.swift
//  Clansportler
//
//  Created by Luca Kiedrowski on 09.08.17.
//  Copyright © 2017 LucaKiedrowski. All rights reserved.
//

import UIKit

class ScrollController: UIViewController, UIScrollViewDelegate {
    
    var scrollView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let textAttributes = [NSAttributedStringKey.foregroundColor:UIColor.white]
        navigationController?.navigationBar.titleTextAttributes = textAttributes
    }
    
    func setupController() {
        navigationController?.navigationBar.isTranslucent = false
        
        setupViews()
//        setupScrollView(height: 2500)
        
        view.backgroundColor = ColorCodes.backgroundGrey
    }
    
    func setupScrollView(height: CGFloat) {
        
        self.scrollView = UIScrollView()
        self.scrollView.delegate = self
        self.scrollView.contentSize = CGSize(width: view.frame.width, height: height)
        scrollView.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, 65, 0)
        
        
        scrollView.frame = view.bounds
        
        view.addSubview(scrollView)
        scrollView.addSubview(scrollContainerView)
        
        scrollContainerView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: scrollView.contentSize.height)
    }
    
    let scrollContainerView: UIView = {
        let view = UIView()
        return view
    }()
    
    func setupMenuBar() {
        let menuButton = UIBarButtonItem(image: #imageLiteral(resourceName: "Gruppe 5").withRenderingMode(.alwaysTemplate), style: .plain, target: self, action: #selector(handleMenu))
        menuButton.tintColor = UIColor.white
        navigationItem.leftBarButtonItem = menuButton
        
    }
    
    lazy var menu: Menu = {
        let menu = Menu()
        menu.startController = self
        return menu
    }()
    
    @objc func handleMenu() {
        menu.showMenu()
        
    }
    
    func setupViews() {
        
    }
    
}
