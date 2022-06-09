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
    func didTapImageCell(image: TaggedImageObject?) // When a user taps to update an old image
}

class AddImagesTableViewCell: UITableViewCell {

    @IBOutlet weak var collectionView: UICollectionView!
    
    var delegate: addImagesTableViewCellDelegate?
    
    private var profileUpdate: Bool?
    
    var cellImagesTagged: [TaggedImageObject] = [] {
        didSet {
            profileUpdate = true
            collectionView.reloadData()
        }
    }
    
    var cellImages: [UIImage] = [] {
        didSet {
            profileUpdate = false
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

extension AddImagesTableViewCell: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageCollectionViewCell", for: indexPath) as? ImageCollectionViewCell
        cell?.imageView.isHidden = false
        
        if self.profileUpdate == true {
            if indexPath.row < cellImagesTagged.count {
                cell?.imageView.image = cellImagesTagged[indexPath.row].image
            } else {
                if indexPath.row >= cellImagesTagged.count {
                    cell?.setAsAddButton()
                    return cell!
                }
                
                cell?.image = cellImagesTagged[indexPath.row].image
            }
        } else {
            if indexPath.row < cellImages.count {
                cell?.imageView.image = cellImages[indexPath.row]
            } else {
                cell?.image = cellImages[indexPath.row]
            }
        }
        
        return cell!
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if self.profileUpdate == true {
            return (self.cellImagesTagged.count + 1)
        } else {
            return self.cellImages.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row >= (self.cellImagesTagged.count) {
            delegate?.didTapAddImageCell()
        } else {
            self.delegate?.didTapImageCell(image: self.cellImagesTagged[indexPath.row])
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let collectionViewHeight = collectionView.bounds.height
        return CGSize(width: collectionViewHeight/1.7, height: collectionViewHeight)
    }
}
