//
//  ViewController.swift
//  NITE
//
//  Created by Charles Oxendine on 4/11/22.
//

import UIKit
import Shuffle_iOS

class MainViewController: UIViewController {

    @IBOutlet weak var cardStack: SwipeCardStack!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var dislikeButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
            
        setView()
        
        cardStack.dataSource = self
        cardStack.delegate = self
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        fatalError("DID RECIEVE MEMORY WARNING!")
    }
    
    func setView() {
        setHeader()
        
        self.view.backgroundColor = .white
        cardStack.backgroundColor = .themeLight()
        cardStack.layer.cornerRadius = 15
        
        likeButton.setBackgroundImage(UIImage(systemName: "arrow.right.circle.fill")!, for: .normal)
        likeButton.tintColor = .systemGreen
        
        dislikeButton.setBackgroundImage(UIImage(systemName: "arrow.left.circle.fill")!, for: .normal)
        dislikeButton.tintColor = .systemRed
    }
    
    func addShadowTo(_view view: UIView) {
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 1
        view.layer.shadowOffset = .zero
        view.layer.shadowRadius = 1
    }
    
    func setHeader() {
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.configureWithTransparentBackground()
        navBarAppearance.backgroundColor = .white
        navBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.themeBlueGray(), NSAttributedString.Key.font: UIFont.systemFont(ofSize: 25)]
        navBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.themeBlueGray(), NSAttributedString.Key.font: UIFont.systemFont(ofSize: 25)]
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.navigationBar.standardAppearance = navBarAppearance
        self.navigationController?.navigationBar.scrollEdgeAppearance = navBarAppearance
        self.title = "NITE"

        setNavBarButtons()
    }
    
    private func setNavBarButtons() {
        var configuration = UIButton.Configuration.filled()
        configuration.imagePadding = -10
        configuration.baseBackgroundColor = .clear
        configuration.baseForegroundColor = .themeBlueGray()
        
        let profileButton = UIButton(type: .custom)
        let profileIcon = UIImage(systemName: "person.circle")!
        configuration.image = profileIcon
        profileButton.configuration = configuration
        profileButton.addTarget(self, action: #selector(self.profileAction), for: .touchUpInside)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: profileButton)
        
        let matchesButton = UIButton(type: .custom)
        let matchesIcon = UIImage(systemName: "heart.fill")!
        configuration.image = matchesIcon
        matchesButton.configuration = configuration
        matchesButton.addTarget(self, action: #selector(self.matchesAction), for: .touchUpInside)
        matchesButton.tintColor = .themeRed()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: matchesButton)
    }
    
    @objc private func profileAction() -> Void {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let newVC = storyboard.instantiateViewController(withIdentifier: "ProfileUpdateViewController") as? ProfileUpdateViewController
        self.navigationController?.pushViewController(newVC!, animated: true)
    }
    
    @objc private func matchesAction() -> Void {
       // Navigate to user matches
    }
    
}

extension MainViewController: SwipeCardStackDataSource, SwipeCardStackDelegate {
    func cardStack(_ cardStack: SwipeCardStack, cardForIndexAt index: Int) -> SwipeCard {
        let testCardProfile = PublicUserProfile(id: "", firstName: "Jenna", lastName: "Lire", description: "I am a big outdoorsy person. Come on a hike with me!! :)", imageLocations: [], avatarImageLocation: "", interests: [])
        let testCard = CardViewServices.createCard(_withProfile: testCardProfile, cardStack: self.cardStack)
        return testCard
    }
    
    func numberOfCards(in cardStack: SwipeCardStack) -> Int {
        return 1
    }
    
    func cardStack(_ cardStack: SwipeCardStack, didSwipeCardAt index: Int, with direction: SwipeDirection) {
        if direction == .left {
            // Like
            // Log in likes and seen
        } else {
            // Dislike
            // Logged as seen
        }
    }
}
