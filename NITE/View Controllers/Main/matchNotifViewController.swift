//
//  matchNotifViewController.swift
//  NITE
//
//  Created by Charles Oxendine on 5/12/22.
//

import UIKit

class matchNotifViewController: UIViewController {

    @IBOutlet weak var messageMatchButton: UIButton!
    @IBOutlet weak var matchProfileImage: UIImageView!
    @IBOutlet weak var messageMatchText: UILabel!
    @IBOutlet weak var closeButton: UIButton!
    
    var matchProfile: PublicUserProfile?
    var parentView: MainViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setUI()
    }

    func setUI() {
        self.messageMatchButton.layer.cornerRadius = self.messageMatchButton.frame.height/2
        self.messageMatchButton.backgroundColor = .themeBlueGray()
        
        self.closeButton.tintColor = .themeBlueGray()
        
        messageMatchText.text = "Don't leave your match hanging...say something interesting!"
        
        if let url = URL(string: self.matchProfile?.avatarImageLocation ?? "") {
            let data = try? Data(contentsOf: url)
            DispatchQueue.main.async {
                self.matchProfileImage.image = UIImage(data: data!)
            }
        }
    }
    
    @IBAction func messageMatchButtonTapped(_ sender: Any) {
        self.dismiss(animated: false) {
            self.parentView?.matchesAction()
        }
    }
    
    @IBAction func closeButtonTapped(_ sender: Any) {
        self.dismiss(animated: true)
    }
}
