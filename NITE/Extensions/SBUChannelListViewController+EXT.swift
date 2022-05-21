//
//  SBUCreateChannelViewController+EXT.swift
//  NITE
//
//  Created by Charles Oxendine on 5/12/22.
//

import SendBirdUIKit
import SendBirdSDK
import Foundation

extension SBUChannelListViewController {
    
    override open func viewWillLayoutSubviews() {
        self.rightBarButton?.isEnabled = false
        self.rightBarButton?.tintColor = .clear
    }
    
    override open func viewDidAppear(_ animated: Bool) {
        self.rightBarButton?.isEnabled = false
        self.rightBarButton?.tintColor = .clear
    }
}

