//
//  cardView.swift
//  NITE
//
//  Created by Charles Oxendine on 4/16/22.
//

import UIKit

class CardView: UIView {

    @IBOutlet weak var contentView: UIView!
    
    @IBOutlet weak var profileImgView: UIImageView!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var descriptionLbl: UILabel!
    @IBOutlet weak var textBackground: UIView!
    
    var cardProfile: PublicUserProfile? {
        didSet {
            if cardProfile != nil {
                setProfileData()
            }
        }
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        initSubviews()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initSubviews()
    }

    func initSubviews() {
        let nib = UINib(nibName: "CardView", bundle: nil)
        nib.instantiate(withOwner: self, options: nil)
        contentView.frame = frame
        contentView.layer.cornerRadius = 15
        contentView.clipsToBounds = true
        addSubview(contentView)
    }
    
    func setProfileData() {
        textBackground.layer.cornerRadius = 15
        nameLbl.text = cardProfile?.fullName()
        descriptionLbl.text = cardProfile?.description ?? ""
        DispatchQueue.global().async {
            if let url = URL(string: self.cardProfile?.avatarImageLocation ?? "") {
                let data = try? Data(contentsOf: url)
                DispatchQueue.main.async {
                    self.profileImgView.image = UIImage(data: data!)
                }
            }
        }
    }
}
