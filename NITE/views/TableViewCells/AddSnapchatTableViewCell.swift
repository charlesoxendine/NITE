//
//  addSnapchatTableViewCell.swift
//  NITE
//
//  Created by Charles Oxendine on 6/11/22.
//

import UIKit
import SCSDKLoginKit

protocol addSnapchatTableViewCellDelegate {
    func disconnectedSnapchat()
    func connectSnapchat()
}

class AddSnapchatTableViewCell: UITableViewCell {

    @IBOutlet weak var avatarView: UIImageView!
    @IBOutlet weak var connectToggleButton: UIButton!
    
    var delegate: addSnapchatTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        avatarView.layer.cornerRadius = avatarView.frame.height/2
        connectToggleButton.backgroundColor = UIColor.themeBlueGray()
        connectToggleButton.setTitleColor(.white, for: .normal)
        connectToggleButton.layer.cornerRadius = 10
        
        if SCSDKLoginClient.isUserLoggedIn == true {
            connectToggleButton.setTitle("Disconnect", for: .normal)
        } else {
            connectToggleButton.setTitle("Connect", for: .normal)
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @IBAction func connectSnapchatToggleButton(_ sender: Any) {
        if SCSDKLoginClient.isUserLoggedIn == true {
            self.disconnectSnapAccount()
        } else {
            self.connectSnapchatAccount()
        }
    }
    
    func connectSnapchatAccount() {
        delegate?.connectSnapchat()
    }
    
    func disconnectSnapAccount() {
        guard var user = FirebaseServices.shared.getCurrentUserProfile() else {
            return
        }
        
        FirebaseServices.shared.updateDataBaseUserProfile(_withUID: user.id ?? "", newProfileImages: nil, updatedProfileData: user, deletedImagesURLS: []) { errorStatus in
            if errorStatus != nil {
                print("ERROR: \(errorStatus!.errorMsg ?? "")")
                return
            }
            
            user.avatarImageLocation = nil
            SCSDKLoginClient.clearToken()
            self.delegate?.disconnectedSnapchat()
            print("Successsfully disconnected snapchat OAuth session")
            return
        }
    }
}
