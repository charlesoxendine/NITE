//
//  snapchatServices.swift
//  NITE
//
//  Created by Charles Oxendine on 4/27/22.
//

import Foundation
import SCSDKLoginKit

class SnapchatServices {
    
    static var shared = SnapchatServices()
    
    func getUpdatedBitmojiAvatarURL(completion: @escaping (URL?) -> ()) {
        /*let builder = SCSDKUserDataQueryBuilder().withDisplayName().withBitmojiTwoDAvatarUrl()
        let userDataQuery = builder.build()*/
        
        SCSDKLoginClient.fetchUserData(withQuery: "{me{displayName, bitmoji{avatar}}}", variables: nil) { userInfo in
            guard let bitmojiURLString = ((((userInfo?["data"] as? [String: Any])?["me"]) as? [String: Any])?["bitmoji"] as? [String: Any])?["avatar"] as? String else {
                return
            }
            
            guard let bitmojiURL = URL(string: bitmojiURLString) else {
                return
            }
            
            completion(bitmojiURL)
        } failure: { error, _ in
            print("Error: \(error?.localizedDescription ?? "")")
        }

        // TODO: THIS IS THE NEW VERSION...however this is kicking back 'unknown error' and we haven't resolved. Therefore we are using the older deprecated version.
        
        /*SCSDKLoginClient.fetchUserData(with:userDataQuery,
                                       success:{ (userData: SCSDKUserData?, partialError: Error?) in
            let bitmojiAvatarURL = userData?.bitmojiTwoDAvatarUrl;
            print("BITMOJI URL: \(bitmojiAvatarURL ?? "")")
        }, failure:{ (error: Error?, isUserLoggedOut: Bool) in
            // Handle error
        })*/
    }
    
}
