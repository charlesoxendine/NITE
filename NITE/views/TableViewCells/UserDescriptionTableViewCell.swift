//
//  UserDescriptionTableViewCell.swift
//  NITE
//
//  Created by Charles Oxendine on 5/23/22.
//

import UIKit

class UserDescriptionTableViewCell: UITableViewCell {

    @IBOutlet weak var captionLbl: UILabel!
    @IBOutlet weak var descriptionLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        captionLbl.font = UIFont.systemFont(ofSize: 18, weight: .light)
        captionLbl.textColor = UIColor.black
        descriptionLbl.font = UIFont.systemFont(ofSize: 18, weight: .light)
        descriptionLbl.textColor = UIColor.black
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
