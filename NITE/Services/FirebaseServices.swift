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
import FirebaseStorage
import CoreLocation
import GeoFire

class FirebaseServices {
    
    private var currentUserProfile: PublicUserProfile?

    private let USER_COLLECTION = Firestore.firestore().collection("users")
    private let storage = Storage.storage()
    
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
            
            self.updateDataBaseUserProfile(_withUID: newUserUID, newProfileImages: nil, updatedProfileData: newProfileData) { error in
                if error != nil {
                    // delete user that was just created
                    completion(ErrorStatus(errorMsg: error!.errorMsg, errorMessageType: nil))
                    return
                }
                
                completion(nil)
            }
        }
    }
    
    func updateDataBaseUserProfile(_withUID uid: String, newProfileImages: [UIImage]?, updatedProfileData: PublicUserProfile, completion: @escaping (ErrorStatus?) -> ()) {
        do {
            try USER_COLLECTION.document(uid).setData(from: updatedProfileData, merge: true)
            self.setCurrentUserProfile(profile: updatedProfileData)
            
            for image in newProfileImages ?? [] {
                addProfileImage(profileImage: image) { err in
                    if err != nil {
                        print("ERROR: \(err!.errorMsg)")
                    }
                }
            }
            
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
    
    func getAvatarImage(_withUID uid: String, completion: @escaping (ErrorStatus?, UIImage?) -> ()) {
        let storageRef = storage.reference()
        let avatarImagesRef = storageRef.child("avatarIMGs/\(uid).png")
        
        avatarImagesRef.getData(maxSize: 1 * 1024 * 1024) { data, error in
            if let error = error {
                completion(ErrorStatus(errorMsg: error.localizedDescription, errorMessageType: .internalError), nil )
            } else {
                let image = UIImage(data: data!)
                completion(nil, image)
            }
        }
    }
    
    func updateAvatarImage(_withUID uid: String, avatarIMG: UIImage, completion: @escaping (ErrorStatus?) -> ()) {
        let storageRef = storage.reference()
        let avatarImagesRef = storageRef.child("avatarIMGs/\(uid).png")
        
        if let data = avatarIMG.pngData() {
            avatarImagesRef.putData(data, metadata: nil) { (metadata, error) in
                guard let _ = metadata else {
                    completion(ErrorStatus(errorMsg: error?.localizedDescription, errorMessageType: .internalError))
                    return
                }
            
                avatarImagesRef.downloadURL { (url, error) in
                    guard let downloadURL = url else {
                        completion(ErrorStatus(errorMsg: "Error getting download URL", errorMessageType: .internalError))
                        return
                    }
                    
                    self.currentUserProfile?.avatarImageLocation = downloadURL.absoluteString
                    completion(nil)
                }
            }
        }
    }
    
    func addProfileImage(profileImage: UIImage, completion: @escaping (ErrorStatus?) -> ()) {
        let storageRef = storage.reference()
        
        if let uid = Auth.auth().currentUser?.uid {
            let imageUID = UUID().uuidString
            let profileImagesRef = storageRef.child("profileIMGs/\(uid)/\(imageUID).png")
            
            if let data = profileImage.pngData() {
                profileImagesRef.putData(data, metadata: nil) { (metadata, error) in
                    guard let _ = metadata else {
                        completion(ErrorStatus(errorMsg: error?.localizedDescription, errorMessageType: .internalError))
                        return
                    }
                    
                    profileImagesRef.downloadURL { (url, error) in
                        guard let downloadURL = url else {
                            completion(ErrorStatus(errorMsg: "Error getting download URL", errorMessageType: .internalError))
                            return
                        }
                        
                        self.currentUserProfile?.imageLocations?.append(downloadURL.absoluteString)
                        self.updateDataBaseUserProfile(_withUID: uid, newProfileImages: nil, updatedProfileData: self.currentUserProfile!) { errorObj in
                            if errorObj != nil {
                                completion(ErrorStatus(errorMsg: errorObj!.errorMsg, errorMessageType: .unknownError))
                                return
                            }
                            
                            completion(nil)
                        }
                        
                    }
                }
            }
        }
    }
    
    func getUserProfileImages(_withUID uid: String,_withImageIDs ids: [String], completion: @escaping (ErrorStatus?, [UIImage]?) -> ()) {
        let storageRef = storage.reference()
        var images: [UIImage] = []
        
        let group = DispatchGroup()
        
        group.enter()
        for id in ids {
            let avatarImagesRef = storageRef.child("profileIMGs/\(uid)/\(id).png")
            
            avatarImagesRef.getData(maxSize: 1 * 1024 * 1024) { data, error in
                if let error = error {
                    completion(ErrorStatus(errorMsg: error.localizedDescription, errorMessageType: .internalError), nil)
                } else {
                    if let image = UIImage(data: data!) {
                        images.append(image)
                    }
                    
                    group.leave()
                }
            }
        }
        
        completion(nil, images)
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
