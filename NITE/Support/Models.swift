//
//  Models.swift
//  NITE
//
//  Created by Charles Oxendine on 4/15/22.
//

import Foundation
import FirebaseFirestoreSwift

struct PublicUserProfile: Codable {
    var id: String!
    var firstName: String?
    var lastName: String?
    var description: String?
    var imageLocations: [String]? // array of URL strings
    var avatarImageLocation: String? // URL string
    var interests: [Interest]?
    var geohash: String?
    var lat: Float?
    var long: Float?
    var genderIdentity: GenderIdentity?
    var genderPreference: GenderPreference? 
    
    func fullName() -> String {
        return "\(firstName ?? "") \(lastName ?? "")"
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case firstName
        case lastName
        case description
        case imageLocations
        case avatarImageLocation
        case interests
        case geohash
        case lat
        case long
        case genderIdentity
        case genderPreference
    }
}

struct Interest: Codable {
    var id: String!
    var name: String!
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
    }
}

// MARK: Gender Identity and Preferences
// Enum for each preference (who people want to match with) and each gender Identity (How the user identifies themselves. Also two methods for retrieving the title for each.
enum GenderPreference: Int, Codable {
    case male
    case female
    case maleFemale
    case everyone
    
    func getGenderPreferenceName() -> String {
        switch self.rawValue {
        case GenderPreference.male.rawValue:
            return "Men"
        case GenderPreference.female.rawValue:
            return "Women"
        case GenderPreference.maleFemale.rawValue:
            return "Men & Woman"
        case GenderPreference.everyone.rawValue:
            return "Everyone"
        default:
            fatalError("Out of range of available Gender Pref options")
        }
    }
}

enum GenderIdentity: Int, Codable {
    case male
    case female
    case other
    
    func getGenderIdentityName() -> String {
        switch self.rawValue {
        case GenderIdentity.male.rawValue:
            return "Man"
        case GenderIdentity.female.rawValue:
            return "Female"
        case GenderIdentity.other.rawValue:
            return "Other"
        default:
            fatalError("Out of range of available Gender Identity options")
        }
    }
}
