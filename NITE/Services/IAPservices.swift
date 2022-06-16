//
//  IAPservices.swift
//  NITE
//
//  Created by Charles Oxendine on 6/8/22.
//

import Foundation
import RevenueCat
import FirebaseAuth

let BASIC_PLAN_LIKE_LIMIT = 5

struct IAPServices {
    
    public static let doubleLikesPackageID = "more_likes_offering"
    public static let doubleLikesEntitlementID = "doubleLikesEntitlement"
    
    private static let apiKey = "appl_WPhwpBwyfvsqbyNJLMxHknoEIwy"
    
    public static func checkSubscriptionStatus(alreadySubscribed: Bool, completion: @escaping (Bool) -> Void) {
        Purchases.shared.getCustomerInfo { (customerInfo, error) in
            if let error = error {
                print(error.localizedDescription)
                return
            }

            if customerInfo?.entitlements.all[doubleLikesPackageID]?.isActive == true {
                completion(true)
            } else {
                completion(false)
            }
        }
    }
    
    public static func configureRevCatUser() {
        Purchases.configure(withAPIKey: apiKey, appUserID: Auth.auth().currentUser?.uid ?? "")
    }
    
    public static func presentIAPViewController(vc: UIViewController) {
        let storyboard = UIStoryboard(name: "Utility", bundle: nil)
        let newVC = storyboard.instantiateViewController(withIdentifier: "InAppPurchasesViewController") as? InAppPurchasesViewController
        if let newVC = newVC {
            newVC.modalPresentationStyle = .fullScreen
            vc.present(newVC, animated: true)
        }
    }
    
    static func makePurchase(package: Package, completion: @escaping () -> Void) {
        Purchases.shared.purchase(package: package) { (_/*transaction*/, customerInfo, error, userCancelled) in
            guard let customerInfo = customerInfo,
                error == nil else {
                return
            }
            
            if userCancelled == true {
                // TODO: handle user canceled
                return
            }
            
            if customerInfo.entitlements[self.doubleLikesPackageID]?.isActive == true {
                print("NEW SUBRSCRIBERERGONERGNERIGNR")
            }
        }
    }
}
