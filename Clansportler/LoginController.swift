//
//  LoginController.swift
//  Clansportler
//
//  Created by Luca Kiedrowski on 02.08.17.
//  Copyright © 2017 LucaKiedrowski. All rights reserved.
//

import UIKit

class OnboardingPoint {
    
    var name: OnboardingTitle
    var subtitle: String
    var image: UIImage?
    var gifname: String?
    
    init(name: OnboardingTitle, image: UIImage?, subtitle: String, gifname: String? = nil) {
        self.name = name
        self.subtitle = subtitle
        self.image = image
        
        self.gifname = gifname
    }
}

enum OnboardingTitle: String {
    
    case groups = "Play in Groups"
    case clans = "Join a Clan"
    case tournaments = "Win Tournaments"
    
    
    case onboardingWelcome = "Welcome"
    case onboardingGroups = "Open a Group"
    case onboardingClans = "Communicate with your Clan"
//    case onboardingTournaments = "Win Tournaments"
}

class LoginController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    let cellId = "cellId"
    
    var onboardings: [OnboardingPoint] = {
        let groupPoint = OnboardingPoint(name: .groups, image: #imageLiteral(resourceName: "onboarding_groups"), subtitle: "Join a group and play your favorite games with others together.")
        let clanPoint = OnboardingPoint(name: .clans, image: #imageLiteral(resourceName: "keyboard_onboarding"), subtitle: "Create or join a clan and stay updated about your friends.")
        let tournamentsPoint = OnboardingPoint(name: .tournaments, image: #imageLiteral(resourceName: "Onboarding_grid-1"), subtitle: "Play Tournaments and win prizes, earn some money and get rewards.")
        
        return [groupPoint, clanPoint, tournamentsPoint]
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        setupCollectionView()
    }
    
    func setupViews() {
        
        view.addSubview(signUpButton)
        if #available(iOS 11.0, *) {
            signUpButton.anchor(top: nil, left: view.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 16, paddingBottom: 16, paddingRight: 16, width: 0, height: 50)
        } else {
            // Fallback on earlier versions
            signUpButton.anchor(top: nil, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 16, paddingBottom: 16, paddingRight: 16, width: 0, height: 50)
        }
        
        view.addSubview(loginButton)
        loginButton.anchor(top: nil, left: signUpButton.leftAnchor, bottom: signUpButton.topAnchor, right: signUpButton.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 16, paddingRight: 0, width: 0, height: 50)
        
        view.addSubview(pageControl)
        pageControl.anchor(top: nil, left: nil, bottom: loginButton.topAnchor, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 8, paddingRight: 0, width: 100, height: 32)
        pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
    }

    override func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let pageNumber = targetContentOffset.pointee.x / view.frame.width
        pageControl.currentPage = Int(pageNumber)
    }
    
    let backgroundImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.image = #imageLiteral(resourceName: "Gaming_esport")
        return iv
    }()
    
    let blueView: UIView = {
        let view = UIView()
        view.backgroundColor = ColorCodes.clansportlerDarkBlue
        view.alpha = 0.75
        return view
    }()
    
    lazy var loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .clear
        button.layer.borderWidth = 2
        button.layer.borderColor = UIColor.white.cgColor
        button.layer.cornerRadius = 5
        button.tintColor = UIColor.white
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 19)
        button.setTitle("Login", for: .normal)
        button.addTarget(self, action: #selector(handleUserLogin), for: .touchUpInside)
        return button
    }()
    
    lazy var signUpButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = ColorCodes.clansportlerRed
        button.setTitle("Sign Up", for: .normal)
        button.tintColor = UIColor.white
        button.layer.cornerRadius = 5
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 19)
        button.addTarget(self, action: #selector(handleUserRegistration), for: .touchUpInside)
        return button
    }()
    
    let pageControl: UIPageControl = {
        let pc = UIPageControl()
        pc.pageIndicatorTintColor = UIColor(white: 1, alpha: 0.5)
        pc.currentPageIndicatorTintColor = UIColor.white
        pc.numberOfPages = 3
        return pc
    }()
    
    func setupCollectionView() {
        if let flowLayout = collectionView?.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.scrollDirection = .horizontal
            flowLayout.minimumLineSpacing = 0
        }
        
        let backgroundWhiteView = UIView()
        backgroundWhiteView.backgroundColor = UIColor.white
        backgroundWhiteView.frame = view.frame
        
        backgroundWhiteView.addSubview(backgroundImageView)
        backgroundImageView.frame = view.frame
        
        backgroundWhiteView.addSubview(blueView)
        blueView.frame = view.frame
        
        
        collectionView?.backgroundView = backgroundWhiteView
        
        collectionView?.register(LoginCell.self, forCellWithReuseIdentifier: cellId)
        
        collectionView?.contentInset = UIEdgeInsetsMake(0, 0, 164, 0)
        
        collectionView?.isPagingEnabled = true
        collectionView?.showsHorizontalScrollIndicator = false
    }
    
    @objc func handleUserLogin() {
        let userLoginController = UserLoginController()
        userLoginController.startController = self
        present(userLoginController, animated: true) { 
            //Here completion
            UIApplication.shared.statusBarStyle = .default
        }
    }
    
    @objc func handleUserRegistration() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let animatedUserRegistrationController = AnimatedUserRegistrationController()
        animatedUserRegistrationController.loginController = self
        present(animatedUserRegistrationController, animated: true) {
            //Here completion
            UIApplication.shared.statusBarStyle = .default
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width = view.frame.width
        let height = view.frame.height - 164
        return CGSize(width: width, height: height)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return onboardings.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! LoginCell
        
        cell.onboardingPoint = onboardings[indexPath.item]
        
        return cell
    }
    
}
