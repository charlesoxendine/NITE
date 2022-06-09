//
//  InAppPurchasesViewController.swift
//  NITE
//
//  Created by Charles Oxendine on 5/28/22.
//

import UIKit
import RevenueCat
import Lottie

class InAppPurchasesViewController: UIViewController {

    @IBOutlet weak var continueButton: UIButton!
    @IBOutlet weak var offerDescriptionButton: UILabel!
    @IBOutlet weak var costLabel: UILabel!
    @IBOutlet weak var animationUIView: AnimationView!
    
    private var moreLikesPackage: Package? {
        didSet {
            setOfferData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setUI()
        getProduct()
        
        animationUIView.play()
    }
    
    func setUI() {
        self.continueButton.layer.cornerRadius = self.continueButton.frame.height/2
        self.continueButton.backgroundColor = .themeBlueGray()
    }
    
    func getProduct() {
        Purchases.shared.getOfferings { offerings, error in
            if error != nil {
                return
            }
            
            guard let packages = offerings?.current?.availablePackages else {
                return
            }
            
            var moreLikesPackage: Package?
            for package in packages {
                if package.offeringIdentifier == IAPServices.doubleLikesPackageID {
                    moreLikesPackage = package
                    break
                }
            }
            
            self.moreLikesPackage = moreLikesPackage
        }
    }
    
    func setOfferData() {
        guard let moreLikesPackage = moreLikesPackage else {
            return
        }
        
        let priceString = moreLikesPackage.storeProduct.localizedPriceString
        
        self.continueButton.setTitle("\(priceString) / Month", for: .normal)
        self.costLabel.text = "Your subscription renews automatically. Every month, \(priceString) will be charged to your account. It can also be canceled (or auto-renew turned off) in Account Settings. Cancellations must be made at least 24 hours before the next renewal date."
    }
    
    @IBAction func continueTapped(_ sender: Any) {
        guard let moreLikesPackage = moreLikesPackage else {
            return
        }

        IAPServices.makePurchase(package: moreLikesPackage) {
            print("HERE")
        }
    }
    
    @IBAction func closeViewTapped(_ sender: Any) {
        self.dismiss(animated: true)
    }
}
