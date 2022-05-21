//
//  CustomeUserMessageCell.swift
//  NITE
//
//  Created by Charles Oxendine on 5/13/22.
//

import Foundation
import SendBirdUIKit
import FirebaseAuth
import UIKit

class CustomUserMessageCell: SBUUserMessageCell {
    override func setupStyles() {
        super.setupStyles()
        
        guard let currentUserUID = Auth.auth().currentUser?.uid else {
            return
        }
        
        if self.message.sender?.userId == currentUserUID {
            self.position = .right
        }
    }
}


