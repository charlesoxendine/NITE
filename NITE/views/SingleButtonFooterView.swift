//
//  singleButtonFooterView.swift
//  Sizzle-Chef-App
//
//  Created by Charles Oxendine on 10/14/21.
//

import UIKit

protocol singleButtonFooterViewDelegate {
    func didTapButton()
    func termsTapped()
}

class SingleButtonFooterView: UIView {

    @IBOutlet weak var mainButton: UIButton!
    @IBOutlet weak var termsButton: UIButton!
    
    var delegate: singleButtonFooterViewDelegate?
    var customTitle: String? {
        didSet {
            mainButton.setTitle(customTitle, for: .normal)
            mainButton.backgroundColor = .red
        }
    }
    
    var hideTermsButton: Bool = false {
        didSet {
            self.termsButton.isHidden = hideTermsButton
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
    
    @IBAction func termsOfServiceTapped(_ sender: Any) {
        delegate?.termsTapped()
    }
}
