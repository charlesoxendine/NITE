//
//  FieldEntryTableViewCell.swift
//  ProjectChef
//
//  Created by Charles Oxendine on 6/21/21.
//

import UIKit

protocol FieldEntryTableViewCellDelegate {
    func cellsNeedReload()
}

class FieldEntryTableViewCell: UITableViewCell {

    @IBOutlet weak var captionLabel: UILabel!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var lineView: UIView!
    @IBOutlet weak var showPwd: UIImageView!
    
    var delegate: UITextViewDelegate? {
        didSet {
            textView.delegate = delegate
        }
    }
        
    var CellDelegate: FieldEntryTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

}
