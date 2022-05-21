//
//  SBUChannelViewController.swift
//  NITE
//
//  Created by Charles Oxendine on 5/12/22.
//

import Foundation
import SendBirdUIKit
import UIKit
import FirebaseFirestoreSwift

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
        self.showLoadingIndicator()
        
        SendbirdServices.shared.getMemberList(channelURL: self.channelUrl ?? "") { error, memberList in
            if let error = error {
                self.removeLoadingIndicator()
                self.showErrorMessage(message: error.errorMsg)
                return
            }
            
            guard let currentUserUID = FirebaseServices.shared.getCurrentUserProfile()?.id else {
                self.removeLoadingIndicator()
                return
            }
            
            guard let profileUserID = memberList?.first(where: { $0.user_id != currentUserUID })?.user_id else {
                self.removeLoadingIndicator()
                return
            }
            
            FirebaseServices.shared.getUserProfile(_withUID: profileUserID) { errorStatus, profile in
                self.removeLoadingIndicator()
                if let errorStatus = errorStatus {
                    self.showErrorMessage(message: error.errorMsg)
                    return
                }
                
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let newVC = storyboard.instantiateViewController(withIdentifier: "UserProfileViewController") as? UserProfileViewController
                newVC?.profileUserObj = profile
                self.navigationController?.pushViewController(newVC!, animated: true)
            }
        }
    }
}
