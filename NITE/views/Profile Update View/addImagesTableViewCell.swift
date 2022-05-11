//
//  addImagesTableViewCell.swift
//  Sizzle-Chef-App
//
//  Created by Charles Oxendine on 10/14/21.
//

import UIKit
import CryptoKit
import FirebaseAuth

protocol addImagesTableViewCellDelegate {
    func didTapAddImageCell() // User wants to add new image
    func didTapImageCell(image: taggedImageObject?) // When a user taps to update an old image
}

class addImagesTableViewCell: UITableViewCell {

    @IBOutlet weak var collectionView: UICollectionView!
    
    var delegate: addImagesTableViewCellDelegate?
    
    var cellImages: [taggedImageObject] = [] {
        didSet {
            collectionView.reloadData()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        collectionView.delegate = self
        collectionView.dataSource = self
   
        collectionView.register(UINib.init(nibName: "imageCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "imageCollectionViewCell")
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}

extension addImagesTableViewCell: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageCollectionViewCell", for: indexPath) as? imageCollectionViewCell
        cell?.imageView.isHidden = false
        
        if indexPath.row < cellImages.count {
            cell?.imageView.image = cellImages[indexPath.row].image
        } else {
            if indexPath.row >= cellImages.count {
                cell?.setAsAddButton()
                return cell!
            }
            
            cell?.image = cellImages[indexPath.row].image
        }
        
        return cell!
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (self.cellImages.count + 1)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row >= (self.cellImages.count) {
            delegate?.didTapAddImageCell()
        } else {
            self.delegate?.didTapImageCell(image: self.cellImages[indexPath.row])
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let collectionViewHeight = collectionView.bounds.height
        return CGSize(width: collectionViewHeight/1.7, height: collectionViewHeight)
    }
}
