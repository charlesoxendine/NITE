//
//  AuthSplashScreenViewController.swift
//  NITE
//
//  Created by Charles Oxendine on 4/12/22.
//

import UIKit
import FirebaseAuth
import Lottie

class AuthSplashScreenViewController: UIViewController {

    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var animationView: AnimationView!
    @IBOutlet weak var signUpButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        animationView.loopMode = .autoReverse
        animationView.play()
        
        setUI()
    }
    
    func setUI() {
        self.view.backgroundColor = .white
        signUpButton.backgroundColor = .themeBlueGray()
        signUpButton.layer.cornerRadius = 15
        
        checkAuth()
    }
    
    private func checkAuth() {
        guard let fireUser = Auth.auth().currentUser else {
            return
        }
        
        FirebaseServices.shared.getUserProfile(_withUID: fireUser.uid) { error, publicProfile in
            if let error = error {
                FirebaseServices.shared.logoutUser()
                return
            }
            
            if publicProfile != nil {
                FirebaseServices.shared.setCurrentUserProfile(profile: publicProfile!)
                FirebaseServices.shared.initializeSendBirdUser()
                IAPServices.configureRevCatUser()
                
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let newVC = storyboard.instantiateViewController(withIdentifier: "MainNav")
                newVC.modalPresentationStyle = .fullScreen
                self.navigationController?.present(newVC, animated: true)
            }
        }
    }
    
    @IBAction func signInTapped(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Auth", bundle: nil)
        if let newVC = storyboard.instantiateViewController(withIdentifier: "SignInViewController") as? SignInViewController {
            self.navigationController?.pushViewController(newVC, animated: true)
        }
    }
    
    @IBAction func signUpTapped(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Auth", bundle: nil)
        if let newVC = storyboard.instantiateViewController(withIdentifier: "SignUpViewController") as? SignUpViewController {
            self.navigationController?.pushViewController(newVC, animated: true)
        }
    }
}
