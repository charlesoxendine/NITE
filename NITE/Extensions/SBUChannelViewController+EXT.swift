//
//  SBUChannelViewController.swift
//  NITE
//
//  Created by Charles Oxendine on 5/12/22.
//

import Foundation
import SendBirdUIKit
import UIKit

extension SBUChannelViewController {
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        self.setHeader()
    }
    
    func setHeader() {
        self.title = "Chat"
        setHeaderProfileButton()
    }
    
    func setHeaderProfileButton() {
        var buttonConfig = UIButton.Configuration.plain()
        buttonConfig.imagePadding = -5
        let profileButton = UIButton(type: .custom)
        profileButton.configuration = buttonConfig
        let buttonIMG = UIImage(systemName: "person.circle")
        profileButton.setImage(buttonIMG, for: .normal)
        profileButton.setTitleColor(profileButton.tintColor, for: .normal)
        profileButton.addTarget(self, action: #selector(self.profileAction), for: .touchUpInside)
        profileButton.tintColor = .themeBlueGray()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: profileButton)
    }
    
    
    @objc private func profileAction() {
        print("HELLO")
    }
}
