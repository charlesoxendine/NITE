//
//  singleButtonFooterView.swift
//  Sizzle-Chef-App
//
//  Created by Charles Oxendine on 10/14/21.
//

import UIKit

protocol singleButtonFooterViewDelegate {
    func didTapButton()
}

class singleButtonFooterView: UIView {

    @IBOutlet weak var mainButton: UIButton!
    
    var delegate: singleButtonFooterViewDelegate?
    var customTitle: String? {
        didSet {
            mainButton.setTitle(customTitle, for: .normal)
            mainButton.backgroundColor = .red
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setUI()
    }
    
    func setUI() {
        mainButton.backgroundColor = UIColor.themeBlueGray()
        mainButton.setTitleColor(.white, for: .normal)
        mainButton.layer.cornerRadius = 10
    }

    @IBAction func buttonTapped(_ sender: Any) {
        delegate?.didTapButton()
    }
}
