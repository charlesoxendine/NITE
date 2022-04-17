//
//  FirebaseServices.swift
//  NITE
//
//  Created by Charles Oxendine on 4/16/22.
//

import Foundation
import FirebaseAuth
import FirebaseCore
import FirebaseFirestore
import FirebaseFirestoreSwift
import CoreLocation
import GeoFire

class FirebaseServices {
    
    private var currentUserProfile: PublicUserProfile?

    private let USER_COLLECTION = Firestore.firestore().collection("users")
    
    func getCurrentUserProfile() -> PublicUserProfile? {
        return currentUserProfile
    }
    
    func setCurrentUserProfile(profile: PublicUserProfile) {
        currentUserProfile = profile
    }
    
    public static let shared = FirebaseServices()
    
    func createUser(email: String, password: String, newProfileData: PublicUserProfile, completion: @escaping (ErrorStatus?) -> ()) {
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            guard error == nil else {
                completion(ErrorStatus(errorMsg: error?.localizedDescription, errorMessageType: nil))
                return
            }
            
            guard let newUserUID = authResult?.user.uid else {
                completion(ErrorStatus(errorMsg: "Error validating user", errorMessageType: nil))
                return
            }
            
            self.updateDataBaseUserProfile(_withUID: newUserUID, updatedProfileData: newProfileData) { error in
                if error != nil {
                    // delete user that was just created
                    completion(ErrorStatus(errorMsg: error!.errorMsg, errorMessageType: nil))
                    return
                }
                
                completion(nil)
            }
        }
    }
    
    func updateDataBaseUserProfile(_withUID uid: String, updatedProfileData: PublicUserProfile, completion: @escaping (ErrorStatus?) -> ()) {
        do {
            try USER_COLLECTION.document(uid).setData(from: updatedProfileData, merge: true)
            self.setCurrentUserProfile(profile: updatedProfileData)
            completion(nil)
        } catch let error {
            print("Error writing user to Firestore: \(error)")
            completion(ErrorStatus(errorMsg: "Error writing user to Firestore: \(error)", errorMessageType: .internalError))
        }
    }
    
    func getUserProfile(_withUID uid: String, completion: @escaping (ErrorStatus?, PublicUserProfile?) -> ()) {
        guard let uid = Auth.auth().currentUser?.uid else {
            completion(ErrorStatus(errorMsg: "User is not authenticated.", errorMessageType: .authError), nil)
            return
        }
        
        let docRef = USER_COLLECTION.document(uid)
        docRef.getDocument { (document, error) in
            let result = Result {
                try document.flatMap {
                    let data = try? $0.data(as: PublicUserProfile.self)
                    completion(nil, data)
                }
            }
        }
    }
    
    func updateUserLocation(location: CLLocationCoordinate2D, completion: @escaping (ErrorStatus?) -> ()) {
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }

        let hash = GFUtils.geoHash(forLocation: location)
        let updateData: [String: Any] = [
            "geohash": hash,
            "lat": location.latitude,
            "long": location.longitude
        ]
        
        let ref = USER_COLLECTION.document(uid)
        ref.updateData(updateData) { error in
            if error != nil {
                completion(ErrorStatus(errorMsg: error!.localizedDescription, errorMessageType: .unknownError))
                return
            }
            
            completion(nil)
            return
        }
    }
    
    func loginUser(email: String, password: String, completion: @escaping (ErrorStatus?) -> ()) {
        Auth.auth().signIn(withEmail: email, password: password) { autResults, error in
            if error != nil {
                completion(ErrorStatus(errorMsg: error!.localizedDescription, errorMessageType: .unknownError))
                return
            }
            
            completion(nil)
        }
    }
    
    func logoutUser() {
        self.currentUserProfile = nil
        try? Auth.auth().signOut()
    }
    
}
