//
//  ChannelListVC.swift
//  NITE
//
//  Created by Charles Oxendine on 5/15/22.
//

import Foundation
import UIKit
import SendBirdUIKit
import SendBirdSDK

class ChannelListVC: SBUChannelListViewController {
    
    override init(channelListQuery: SBDGroupChannelListQuery? = nil) {
        super.init(channelListQuery: channelListQuery)
    }
    
    override open func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let index = indexPath.row
        let channel = self.channelList[index]
        let size = tableView.visibleCells[0].frame.height
        let iconSize: CGFloat = 40.0
        
        let leaveAction = UIContextualAction(
            style: .normal,
            title: ""
        ) { action, view, actionHandler in
            self.unmatchButtonTapped(channel: channel) { error in
                if error != nil {
                    actionHandler(false)
                } else {
                    actionHandler(true)
                }
            }
        }
        
        let leaveTypeView = UIImageView(
            frame: CGRect(
                x: (size-iconSize)/2,
                y: (size-iconSize)/2,
                width: iconSize,
                height: iconSize
            ))
        leaveTypeView.layer.cornerRadius = iconSize/2
        leaveTypeView.backgroundColor = .red
        leaveTypeView.image = UIImage(systemName: "person.crop.circle.badge.xmark.fill")
        leaveTypeView.contentMode = .center
        
        leaveAction.image = UIImage(systemName: "person.crop.circle.badge.xmark.fill")
        leaveAction.backgroundColor = .red
                
        return UISwipeActionsConfiguration(actions: [leaveAction])
    }
    
    func unmatchButtonTapped(channel: SBDGroupChannel, completion: @escaping (ErrorStatus?) -> ()) {
        let alert = UIAlertController(title: "Are you sure?", message: "If you unmatch, you will not see each other again and this action cannot be undone.", preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: "Confirm", style: .default) { action in
            self.deleteChannel(channel: channel)
        }
        
        let exitAction = UIAlertAction(title: "Close", style: .default)
        
        alert.addAction(confirmAction)
        alert.addAction(exitAction)
        self.present(alert, animated: true)
    }
    
    private func deleteChannel(channel: SBDGroupChannel) {
        channel.delete { error in
            if let error = error {
                self.showErrorMessage(message: error.localizedDescription)
                return
            }
            
            self.showOkMessage(title: "Success", message: "Successfully unmatched...I guess it's back to looking!") {
                print("success")
            }
        }
    }
}
