//
//  ViewController.swift
//  NITE
//
//  Created by Charles Oxendine on 4/11/22.
//

import UIKit
import Shuffle_iOS
import FirebaseAuth
import FirebaseFirestoreSwift
import SendBirdSDK
import SendBirdUIKit
import RevenueCat
import SCSDKLoginKit

class MainViewController: UIViewController {

    @IBOutlet weak var cardStack: SwipeCardStack!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var dislikeButton: UIButton!
    
    var cardData: [PublicUserProfile] = []
    var nextUpCardData: [PublicUserProfile] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
            
        setView()
        
        cardStack.dataSource = self
        cardStack.delegate = self
        
        getData()
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
    
    func getData() {
        FirebaseServices.shared.getNextFiveProfiles { error, profileData in
            if let error = error {
                self.showErrorMessage(message: error.errorMsg)
                return
            }
            
            guard let profileData = profileData else {
                return
            }

            self.cardData = profileData
            self.cardStack.reloadData()
        }
    }
    
    func checkSwipeEligibility(completion: (()->(Void))?) {
        guard FirebaseServices.shared.getCurrentUserProfile()?.avatarImageLocation != nil else {
            return
        }
        
        guard SCSDKLoginClient.isUserLoggedIn == true else {
            self.showSnapReauthScreen()
            return
        }
        
        completion?()
    }
    
    func showSnapReauthScreen() {
        let alert = UIAlertController(title: "Oops!", message: "It seems you're logged out of Snapchat! Lets get you reconnected to start scrolling!", preferredStyle: .alert)
        let reconnectAction = UIAlertAction(title: "Reconnect", style: .default) { action in
            SCSDKLoginClient.login(from: self) { (success: Bool, error: Error?) in
                if success == true {
                    return
                }
            }
        }
        let closeAction = UIAlertAction(title: "Close", style: .cancel)
        alert.addAction(closeAction)
        alert.addAction(reconnectAction)
        self.present(alert, animated: true)
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
        navBarAppearance.largeTitleTextAttributes = [
            .foregroundColor: UIColor.themeBlueGray(),
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 25)
        ]
        
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
    
    private func toMatchView(matchUserProfile: PublicUserProfile) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let newVC = storyboard.instantiateViewController(withIdentifier: "matchNotifViewController") as? MatchNotifViewController
        newVC?.modalPresentationStyle = .fullScreen
        newVC?.matchProfile = matchUserProfile
        self.present(newVC!, animated: true)
    }
    
    @objc private func profileAction() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let newVC = storyboard.instantiateViewController(withIdentifier: "ProfileUpdateViewController") as? ProfileUpdateViewController
        self.navigationController?.pushViewController(newVC!, animated: true)
    }
    
    @objc func matchesAction() {
        self.openChatList()
    }
    
    @IBAction func likeButtonTapped(_ sender: Any) {
        self.cardStack.swipe(.right, animated: true)
    }
    
    @IBAction func dislikeButtonTapped(_ sender: Any) {
        self.cardStack.swipe(.left, animated: true)
    }
    
}

extension MainViewController: SwipeCardStackDataSource, SwipeCardStackDelegate {
    func cardStack(_ cardStack: SwipeCardStack, cardForIndexAt index: Int) -> SwipeCard {
        let userData = cardData[index]
        let testCard = CardViewServices.createCard(_withProfile: userData, cardStack: self.cardStack)
        return testCard
    }
    
    func numberOfCards(in cardStack: SwipeCardStack) -> Int {
        return self.cardData.count
    }
    
    func cardStack(_ cardStack: SwipeCardStack, didSwipeCardAt index: Int, with direction: SwipeDirection) {
        let userData = cardData[index]
        
        self.checkSwipeEligibility {
            FirebaseServices.shared.checkLikeCount { likesLeft in
                guard likesLeft == true else {
                    IAPServices.presentIAPViewController(vc: self)
                    return
                }
                
                FirebaseServices.shared.logSeen(seenUID: userData.id) { error in
                    if let error = error {
                        self.showErrorMessage(message: error.errorMsg)
                        return
                        
                    }
                    
                    if direction == .left {
                        FirebaseServices.shared.logDislikeData(dislikedUserUID: userData.id) { errorStatus in
                            if errorStatus != nil {
                                self.showErrorMessage(message: errorStatus!.errorMsg)
                                return
                            }
                        }
                    } else {
                        FirebaseServices.shared.checkForMatch(otherUserUID: userData.id) { error, match in
                            if error != nil {
                                self.showErrorMessage(message: error!.errorMsg)
                                return
                            }
                            
                            if match == true {
                                // SHOW MATCH VIEW AND LOG MATCH
                                print("It's a match!!")
                                self.showLoadingIndicator()
                                FirebaseServices.shared.logMatchData(otherUserMatchedWith: userData.id) { errorStatus in
                                    self.removeLoadingIndicator()
                                    if errorStatus != nil {
                                        self.showErrorMessage(message: errorStatus!.errorMsg)
                                        return
                                    }
                                    
                                    self.toMatchView(matchUserProfile: userData)
                                }
                                
                                return
                            }
                            
                            FirebaseServices.shared.logLikeData(likedUserUID: userData.id) { errorStatus in
                                if errorStatus != nil {
                                    self.showErrorMessage(message: errorStatus!.errorMsg)
                                    return
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
