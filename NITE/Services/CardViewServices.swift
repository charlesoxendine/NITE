//
//  CardViewServices.swift
//  NITE
//
//  Created by Charles Oxendine on 4/12/22.
//

import Foundation
import Shuffle_iOS

class CardViewServices {
    
    public static func createCard(_withProfile profile: PublicUserProfile, cardStack: SwipeCardStack) -> SwipeCard {
        let card = SwipeCard()
        card.swipeDirections = [.left, .right]
        let contentView = cardView(frame: cardStack.bounds)
        contentView.clipsToBounds = true
        contentView.cardProfile = profile
        card.content = contentView
        
        let leftOverlay = UIView()
        leftOverlay.layer.cornerRadius = 15
        leftOverlay.backgroundColor = .red
        
        let rightOverlay = UIView()
        rightOverlay.layer.cornerRadius = 15
        rightOverlay.backgroundColor = .green
        
        card.setOverlays([.left: leftOverlay, .right: rightOverlay])
        return card
    }
    
}
