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
import SendBirdSDK
import SendBirdUIKit

class FirebaseServices {
    private var currentUserProfile: PublicUserProfile?

    private let USER_COLLECTION = Firestore.firestore().collection("users")
    private let LIKE_DATA_COLLECTION = Firestore.firestore().collection("like_data")
    private let DISLIKE_DATA_COLLECTION = Firestore.firestore().collection("dislike_data")
    private let MATCH_DATA_COLLECTION = Firestore.firestore().collection("match_data")
    private let storage = Storage.storage()
    
    func getCurrentUserProfile() -> PublicUserProfile? {
        return currentUserProfile
    }
    
    func setCurrentUserProfile(profile: PublicUserProfile?) {
        currentUserProfile = profile
    }
    
    public static let shared = FirebaseServices()
    
    func createUser(email: String, password: String, newProfileData: PublicUserProfile, completion: @escaping (ErrorStatus?) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            guard error == nil else {
                completion(ErrorStatus(errorMsg: error?.localizedDescription, errorMessageType: nil))
                return
            }
            
            guard let newUserUID = authResult?.user.uid else {
                completion(ErrorStatus(errorMsg: "Error validating user", errorMessageType: nil))
                return
            }
            
            var newProfileObject =  newProfileData
            newProfileObject.id = newUserUID
            
            self.updateDataBaseUserProfile(_withUID: newUserUID, newProfileImages: nil, updatedProfileData: newProfileObject, deletedImagesURLS: nil) { error in
                if error != nil {
                    // delete user that was just created
                    completion(ErrorStatus(errorMsg: error!.errorMsg, errorMessageType: nil))
                    return
                }
                
                self.initializeSendBirdUser()
                completion(nil)
            }
        }
    }
    
    func loginUser(email: String, password: String, completion: @escaping (ErrorStatus?, Bool) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { auth, error in
            if let error = error {
                completion(ErrorStatus(errorMsg: error.localizedDescription, errorMessageType: .none), false)
                return
            }
            
            if let userUID = auth?.user.uid {
                self.getUserProfile(_withUID: userUID) { errorStatus, publicUser in
                    if let errorStatus = errorStatus {
                        completion(errorStatus, false)
                        try? Auth.auth().signOut()
                    } else {
                        if let publicUser = publicUser {
                            self.setCurrentUserProfile(profile: publicUser)
                            self.initializeSendBirdUser()
                            completion(nil, true)
                            return
                        }
                        
                        try? Auth.auth().signOut()
                        completion(nil, false)
                    }
                }
            }
        }
    }
    
    func updateDataBaseUserProfile(_withUID uid: String, newProfileImages: [UIImage]?, updatedProfileData: PublicUserProfile, deletedImagesURLS: [String]?, completion: @escaping (ErrorStatus?) -> Void) {
        do {
            var updatedProfile = updatedProfileData
            if let deletedImagesURLS = deletedImagesURLS {
                for deletedURLs in deletedImagesURLS {
                    updatedProfile.imageLocations?.removeAll(where: { $0 == deletedURLs })
                }
            }
            
            try USER_COLLECTION.document(uid).setData(from: updatedProfile, merge: true)
            self.setCurrentUserProfile(profile: updatedProfile)
            
            for image in newProfileImages ?? [] {
                addProfileImage(profileImage: image) { err in
                    if err != nil {
                        print("ERROR: \(err!.errorMsg ?? "")")
                    }
                }
            }
            
            for image in deletedImagesURLS ?? [] {
                deleteImage(url: image)
            }
            
            completion(nil)
        } catch let error {
            print("Error writing user to Firestore: \(error)")
            completion(ErrorStatus(errorMsg: "Error writing user to Firestore: \(error)", errorMessageType: .internalError))
        }
    }
    
    func deleteImage(url: String) {
        let ref = storage.reference(forURL: url)
        
        ref.delete { error in
          if let error = error {
            // Uh-oh, an error occurred!
          } else {
            // File deleted successfully
          }
        }
    }
    
    func getUserProfile(_withUID uid: String, completion: @escaping (ErrorStatus?, PublicUserProfile?) -> Void) {
        let docRef = USER_COLLECTION.document(uid)
        docRef.getDocument { (document, error) in
            _ = Result {
                document.flatMap {
                    let data = try? $0.data(as: PublicUserProfile.self)
                    completion(nil, data)
                }
            }
        }
    }
    
    func updateUserLocation(location: CLLocationCoordinate2D, completion: @escaping (ErrorStatus?) -> Void) {
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
    
    func getAvatarImage(_withUID uid: String, completion: @escaping (ErrorStatus?, UIImage?) -> Void) {
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
    
    func updateAvatarImage(_withUID uid: String, avatarIMG: UIImage, completion: @escaping (ErrorStatus?) -> Void) {
        let storageRef = storage.reference()
        let avatarImagesRef = storageRef.child("avatarIMGs/\(uid).png")
        
        if let data = avatarIMG.pngData() {
            avatarImagesRef.putData(data, metadata: nil) { (metadata, error) in
                guard metadata != nil else {
                    completion(ErrorStatus(errorMsg: error?.localizedDescription, errorMessageType: .internalError))
                    return
                }
            
                avatarImagesRef.downloadURL { (url, error) in
                    guard let downloadURL = url else {
                        completion(ErrorStatus(errorMsg: "Error getting download URL", errorMessageType: .internalError))
                        return
                    }
                    
                    self.currentUserProfile?.avatarImageLocation = downloadURL.absoluteString
                    guard let user = self.currentUserProfile else {
                        return
                    }
                    
                    self.updateDataBaseUserProfile(_withUID: user.id, newProfileImages: [], updatedProfileData: user, deletedImagesURLS: []) { errorStatus in
                        if let errorStatus = errorStatus {
                            completion(errorStatus)
                            return
                        }
                        
                        completion(nil)
                    }
                }
            }
        }
    }
    
    func addProfileImage(profileImage: UIImage, completion: @escaping (ErrorStatus?) -> Void) {
        let storageRef = storage.reference()
        
        if let uid = Auth.auth().currentUser?.uid {
            let imageUID = UUID().uuidString
            let profileImagesRef = storageRef.child("profileIMGs/\(uid)/\(imageUID).png")
            
            if let data = profileImage.pngData() {
                profileImagesRef.putData(data, metadata: nil) { (metadata, error) in
                    guard metadata != nil else {
                        completion(ErrorStatus(errorMsg: error?.localizedDescription, errorMessageType: .internalError))
                        return
                    }
                    
                    profileImagesRef.downloadURL { (url, error) in
                        guard let downloadURL = url else {
                            completion(ErrorStatus(errorMsg: "Error getting download URL", errorMessageType: .internalError))
                            return
                        }
                        
                        if self.getCurrentUserProfile()?.imageLocations == nil {
                            var tempUser = self.getCurrentUserProfile()
                            tempUser?.imageLocations = []
                            self.setCurrentUserProfile(profile: tempUser!)
                        }
                        
                        self.currentUserProfile?.imageLocations?.append(downloadURL.absoluteString)
                        self.updateDataBaseUserProfile(_withUID: uid, newProfileImages: nil, updatedProfileData: self.currentUserProfile!, deletedImagesURLS: nil) { errorObj in
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
    
    func getUserProfileImages(_withUID uid: String, _withImageIDs urls: [String], completion: @escaping (ErrorStatus?, [TaggedImageObject]?) -> Void) {
        var images: [TaggedImageObject] = []
        
        let group = DispatchGroup()
        
        for url in urls {
            group.enter()
            DispatchQueue.global().async {
                let data = try? Data(contentsOf: URL(string: url)!)
                DispatchQueue.main.async {
                    let image = UIImage(data: data!) ?? UIImage()
                    let imagePair = TaggedImageObject(url: url, image: image)
                    images.append(imagePair)
                    group.leave()
                }
            }
        }
        
        group.notify(queue: .main) {
            completion(nil, images)
        }
    }
    
    func logoutUser() {
        self.currentUserProfile = nil
        try? Auth.auth().signOut()
    }
    
    func logLikeData(likedUserUID: String, completion: @escaping (ErrorStatus?) -> Void) {
        do {
            let likeUUID = UUID().uuidString
            guard let userUID = Auth.auth().currentUser?.uid else {
                return
            }
            
            let likeObj = LikeData(likedUserUID: likedUserUID, likingUserUID: userUID, date: Timestamp(date: Date()))
            try LIKE_DATA_COLLECTION.document(likeUUID).setData(from: likeObj, merge: true)
            completion(nil)
        } catch let error {
            print("Error: \(error.localizedDescription)")
            completion(ErrorStatus(errorMsg: error.localizedDescription, errorMessageType: .none))
        }
    }
    
    func createMessageChannelForMatch(otherUserUID: String, completion: @escaping (ErrorStatus?) -> Void) {
        guard let userUID = Auth.auth().currentUser?.uid else {
            return
        }
        
        let groupMemberIDs = [userUID, otherUserUID]
        
        SBDGroupChannel.createChannel(withUserIds: groupMemberIDs, isDistinct: true, completionHandler: { (groupChannel, error) in
            guard error == nil else {
                completion(ErrorStatus(errorMsg: error!.localizedDescription, errorMessageType: .none))
                return
            }
            
            guard let channelURL = groupChannel?.channelUrl else {
                fatalError("Group channel object not Found")
                return
            }
            
            SendbirdServices.shared.registerOperators(channelURL: channelURL, operatorIDs: groupMemberIDs) { addingOperatorError in
                guard addingOperatorError == nil else {
                    completion(ErrorStatus(errorMsg: addingOperatorError!.errorMsg, errorMessageType: .none))
                    return
                }
                
                completion(nil)
            }
            
            completion(nil)
        })
    }

    func initializeSendBirdUser() {
        guard let userID = Auth.auth().currentUser?.uid else {
            return
        }
        
        SBDMain.connect(withUserId: userID) { user, error in
            guard user != nil, error == nil else {
                return
            }
            
            guard let currentUserProfile = self.currentUserProfile else {
                return
            }

            SBDMain.updateCurrentUserInfo(withNickname: currentUserProfile.fullName(), profileUrl: currentUserProfile.avatarImageLocation, completionHandler: { (error) in
                guard error == nil else {
                    // Handle error.
                    return
                }
                
                if let user = SBDMain.getCurrentUser() {
                    SBUGlobals.CurrentUser = SBUUser(user: user)
                    print("User with ID \(user.userId) connected to Sendbird")
                }
            })
        }
    }
    
    func logDislikeData(dislikedUserUID: String, completion: @escaping (ErrorStatus?) -> Void) {
        do {
            let dislikeUUID = UUID().uuidString
            guard let userUID = Auth.auth().currentUser?.uid else {
                return
            }
            
            let likeObj = DislikeData(dislikedUserUID: dislikedUserUID, dislikingUserUID: userUID, date: Timestamp(date: Date()))
            try DISLIKE_DATA_COLLECTION.document(dislikeUUID).setData(from: likeObj, merge: true)
            completion(nil)
        } catch let error {
            print("Error: \(error.localizedDescription)")
            completion(ErrorStatus(errorMsg: error.localizedDescription, errorMessageType: .none))
        }
    }
        
    func getMatchData(userID1: String, userID2: String, completion: @escaping (MatchData?) -> Void) {
        let docRef = MATCH_DATA_COLLECTION.whereField("users", arrayContains: userID1)
        docRef.getDocuments { snap, error in
            guard let snapshotDocuments = snap?.documents else {
                return
            }
            
            for document in snapshotDocuments {
                do {
                    if let matchDataObj = try? document.data(as: MatchData.self) {
                        print(matchDataObj.matchDate)
                        if matchDataObj.users.contains(where: { $0 == userID2 }) {
                            completion(matchDataObj)
                            return
                        }
                    }
                }
            }
        }
    }
    
    func logMatchData(otherUserMatchedWith: String, completion: @escaping (ErrorStatus?) -> Void) {
        do {
            guard let userUID = Auth.auth().currentUser?.uid else {
                return
            }
            
            let matchUUID = UUID().uuidString
            let matchObj = MatchData(users: [userUID, otherUserMatchedWith], matchDate: Timestamp(date: Date()))
            try MATCH_DATA_COLLECTION.document(matchUUID).setData(from: matchObj, merge: true)
            createMessageChannelForMatch(otherUserUID: otherUserMatchedWith) { errorStatus in
                completion(errorStatus)
            }
        } catch let error {
            print("Error: \(error.localizedDescription)")
            completion(ErrorStatus(errorMsg: error.localizedDescription, errorMessageType: .none))
        }
    }
    
    func logSeen(seenUID: String, completion: @escaping (ErrorStatus?) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        
        let seenProfileIDsRef = USER_COLLECTION.document(uid).collection("seen_profile_ids")
        seenProfileIDsRef.document(seenUID).setData([:], completion: { err in
            if let err = err {
                completion(ErrorStatus(errorMsg: err.localizedDescription, errorMessageType: .none))
                return
            }
            
            completion(nil)
        })
    }
    
    func checkIfSeen(seenUID: String, completion: @escaping (ErrorStatus?, Bool?) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        
        let seenProfileIDsRef = USER_COLLECTION.document(uid).collection("seen_profile_ids")
        seenProfileIDsRef.document(seenUID).getDocument { doc, error in
            if let error = error {
                completion(ErrorStatus(errorMsg: error.localizedDescription, errorMessageType: .none), nil)
                return
            }
            
            if let doc = doc, doc.exists {
                completion(nil, true)
            } else {
                completion(nil, false)
            }
        }
    }
    
    func checkForMatch(otherUserUID: String, completion: @escaping (ErrorStatus?, Bool?) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        
        let query = LIKE_DATA_COLLECTION.whereField("likedUserUID", isEqualTo: uid).whereField("likingUserUID", isEqualTo: otherUserUID)
        query.getDocuments { snap, error in
            if let error = error {
                completion(ErrorStatus(errorMsg: error.localizedDescription, errorMessageType: .none), nil)
                return
            }
            
            if snap?.documents.isEmpty == true {
                completion(nil, false)
            } else {
                completion(nil, true)
            }
        }
    }
    
    func getNextFiveProfiles(completion: @escaping (ErrorStatus?, [PublicUserProfile]?) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        
        guard let currentUserGenderPref = self.currentUserProfile?.genderPreference else {
            completion(ErrorStatus(errorMsg: "Finish setting up your profile with a gender preference before you can start swiping.", errorMessageType: .none), nil)
            return
        }
        
        guard let _ = self.currentUserProfile?.avatarImageLocation else {
            completion(ErrorStatus(errorMsg: "To start swiping, you have to login to your snapchat account! This way people can see that cool bitmoji", errorMessageType: .none), nil)
            return
        }
        
        var genderPreferenceIdentities: [GenderIdentity] = []
        switch currentUserGenderPref {
        case .male:
            genderPreferenceIdentities = [.male]
        case .female:
            genderPreferenceIdentities = [.female]
        case .maleFemale:
            genderPreferenceIdentities = [.male, .female]
        case .everyone:
            genderPreferenceIdentities = [.male, .female, .other]
        }
        
        let query = USER_COLLECTION.whereField("id", isNotEqualTo: uid).whereField("genderIdentity", in: genderPreferenceIdentities.map { $0.rawValue })
        
        query.getDocuments { snap, error in
            if let error = error {
                completion(ErrorStatus(errorMsg: error.localizedDescription, errorMessageType: .none), nil)
                return
            }
            
            var newProfiles: [PublicUserProfile] = []
            
            let group = DispatchGroup()
            
            for document in snap!.documents {
                group.enter()
                let result = Result {
                    try document.data(as: PublicUserProfile.self)
                }
                
                switch result {
                case .success(let profile):
                    print("Profile: \(profile.fullName())")
                    self.checkIfSeen(seenUID: profile.id) { errorStatus, seen in
                        if let errorStatus = errorStatus {
                            print("[getNextFiveProfiles] WARNING: \(errorStatus.errorMsg ?? "")")
                            // IGNORING THIS ERROR FOR NOW
                            // TODO: Put performance notif here of failure
                        }
                        
                        if seen == true {
                            print("Seen Profile")
                            group.leave()
                        } else {
                            newProfiles.append(profile)
                            group.leave()
                        }
                    }
                case .failure(let error):
                    print("Error decoding company: \(error)")
                    group.leave()
                }
            }
            
            group.notify(queue: .main) {
                completion(nil, newProfiles)
            }
        }
    }
    
    // returns true if user has likes left for the day
    func checkLikeCount(completion: @escaping (Bool) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        
        let startOfDay: Date = Calendar.current.startOfDay(for: Date())
        let query = LIKE_DATA_COLLECTION.whereField("likingUserUID", isEqualTo: uid).whereField("date", isGreaterThan: startOfDay)
        query.getDocuments { snap, error in
            if let error = error {
                completion(false)
                print(error.localizedDescription)
                return
            }
            
            if snap?.documents.count ?? 0 <= BASIC_PLAN_LIKE_LIMIT {
                completion(true)
            } else {
                completion(false)
            }
        }
    }
}
