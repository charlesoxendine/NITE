//
//  SBUChannelViewController.swift
//  NITE
//
//  Created by Charles Oxendine on 5/12/22.
//

import Foundation
import SendBirdUIKit

extension SBUChannelViewController {
    
    override open func viewWillLayoutSubviews() {
        self.rightBarButton?.isEnabled = false
        self.rightBarButton?.tintColor = .clear
    }
    
    override open func viewDidAppear(_ animated: Bool) {
        self.rightBarButton?.isEnabled = false
        self.rightBarButton?.tintColor = .clear
    }
    
}
