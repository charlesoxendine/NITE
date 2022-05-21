//
//  UIViewController+EXT.swift
//  NITE
//
//  Created by Charles Oxendine on 4/12/22.
//

import Foundation
import UIKit
import JGProgressHUD
import SendBirdUIKit

let LOADING_HUD = JGProgressHUD()

extension UIViewController {
    
    func showErrorMessage(message: String) {
        let controller = UIAlertController(title: "Oops!", message: message, preferredStyle: .alert)
        let close = UIAlertAction(title: "Close", style: .default) { (true) in
            print("Error Message Closed")
        }
        
        controller.addAction(close)
        self.present(controller, animated: true)
    }
    
    func showOkMessage(title: String, message: String, completion: @escaping () -> ()) {
        let controller = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let close = UIAlertAction(title: "Ok", style: .default) { (true) in
            completion()
        }
        
        controller.addAction(close)
        self.present(controller, animated: true)
    }
    
    func showLoadingIndicator() {
        LOADING_HUD.textLabel.text = "Loading"
        LOADING_HUD.show(in: self.view)
    }
    
    func removeLoadingIndicator() {
        LOADING_HUD.dismiss()
    }
    
    func openChatList() {
        let listQuery = SBDGroupChannel.createMyGroupChannelListQuery()
        listQuery?.includeEmptyChannel = true
        listQuery?.includeFrozenChannel = true
        let channelListVC = ChannelListVC(channelListQuery: listQuery)
        let naviVC = UINavigationController(rootViewController: channelListVC)
        naviVC.modalPresentationStyle = .fullScreen
        present(naviVC, animated: true)
    }
}
