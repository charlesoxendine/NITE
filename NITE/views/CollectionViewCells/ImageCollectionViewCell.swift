//
//  imageCollectionViewCell.swift
//  Sizzle-Chef-App
//
//  Created by Charles Oxendine on 10/14/21.
//

import UIKit

class ImageCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    
    var image: UIImage? {
        didSet {
            imageView.image = image
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.imageView.isHidden = false
        setView()
    }

    private func setView() {
        mainView.layer.cornerRadius = 15
        mainView.layer.borderWidth = 1
        mainView.layer.borderColor = UIColor.black.cgColor
        
        imageView.layer.cornerRadius = 15
    }

    func setAsAddButton() {
        self.imageView.isHidden = true
    }
}
