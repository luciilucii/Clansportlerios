//
//  OnboardingController.swift
//  Clansportler
//
//  Created by Luca Kiedrowski on 24.09.17.
//  Copyright © 2017 LucaKiedrowski. All rights reserved.
//

import UIKit



class OnboardingController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    let cellId = "cellId"
    
    let onboardingPoints: [OnboardingPoint] = {
        
        let welcomePoint = OnboardingPoint(name: .onboardingWelcome, image: #imageLiteral(resourceName: "FireWork"), subtitle: "Awesome that you joined Clansportler! Let us show you really quick how to use this app. It's super easy...")
        let groupPoint = OnboardingPoint(name: .onboardingGroups, image: #imageLiteral(resourceName: "onboarding_groups"), subtitle: "Groups are for the players, who search other players with whom they can play. Just choose your game, type in a short description and other players can join already!")
        let clanPoint = OnboardingPoint(name: .onboardingClans, image: nil, subtitle: "Stay updated about your Clan-Member. If you joined a clan, you can just swipe to the left in the menu and start texting. How cool is that?!")
        clanPoint.gifname = "ChatGif_schneller"
        let tournamentPoint = OnboardingPoint(name: .tournaments, image: #imageLiteral(resourceName: "onboarding_tournaments"), subtitle: "With our tournaments you are going to become a gazillionaire! Just kidding ;) You can participate in tournaments, win every game and you'll be the king! Time to play now :)")
        
        let points = [welcomePoint, groupPoint, clanPoint, tournamentPoint]
        return points
    }()
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.delegate = self
        cv.dataSource = self
        cv.isPagingEnabled = true
        return cv
    }()
    
    let pageControl: UIPageControl = {
        let pc = UIPageControl()
        pc.pageIndicatorTintColor = ColorCodes.disabledBlue
        pc.currentPageIndicatorTintColor = ColorCodes.clansportlerBlue
        pc.numberOfPages = 4
        return pc
    }()
    
    lazy var doneButton: ClansportlerRedButton = {
        let button = ClansportlerRedButton(title: "Let's go!")
        button.addTarget(self, action: #selector(handleDismiss), for: .touchUpInside)
        button.isHidden = true
        return button
    }()
    
    @objc func handleDismiss() {
        self.dismiss(animated: true) {
            //completion here
            UIApplication.shared.statusBarStyle = .lightContent
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        collectionView.backgroundColor = .white
        collectionView.register(OnboardingCell.self, forCellWithReuseIdentifier: cellId)
        collectionView.showsHorizontalScrollIndicator = false
        
        setupViews()
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let pageNumber = targetContentOffset.pointee.x / view.frame.width
        
        let currentPageInt = Int(pageNumber)
        pageControl.currentPage = currentPageInt
        
        if currentPageInt == 3 {
            doneButton.isHidden = false
        }
    }
    
    fileprivate func setupViews() {
        view.addSubview(collectionView)
        
        
        if #available(iOS 11.0, *) {
            collectionView.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 100, paddingRight: 0, width: 0, height: 0)
        } else {
            // Fallback on earlier versions
            collectionView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 100, paddingRight: 0, width: 0, height: 0)
        }
        
        view.addSubview(pageControl)
        pageControl.anchor(top: collectionView.bottomAnchor, left: nil, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 8, paddingRight: 0, width: 100, height: 32)
        pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        view.addSubview(doneButton)
        if #available(iOS 11.0, *) {
            doneButton.anchor(top: nil, left: view.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 8, paddingBottom: 8, paddingRight: 8, width: 0, height: 50)
        } else {
            // Fallback on earlier versions
            doneButton.anchor(top: nil, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 8, paddingBottom: 8, paddingRight: 8, width: 0, height: 50)
        }
        
        collectionView.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return onboardingPoints.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let height = collectionView.frame.height
        let width = collectionView.frame.width
        
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! OnboardingCell
        
        let onboarding = onboardingPoints[indexPath.item]
        cell.onboardingPoint = onboarding
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
}














