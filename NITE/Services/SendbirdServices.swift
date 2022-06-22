//
//  SendbirdServices.swift
//  NITE
//
//  Created by Charles Oxendine on 5/16/22.
//

import Foundation
import Alamofire

class SendbirdServices {

    public static let shared = SendbirdServices()
    
    private let sendBirdAppID: String = "29E0A5DC-4102-454D-ACB0-59EC1403BC17"
    private let sendBirdMasterToken: String = "36e64c6bdb52038a1780fbf849e4596de3b7d742"
    
    func registerOperators(channelURL: String, operatorIDs: [String], completion: @escaping (ErrorStatus?) -> ()) {
        guard let url = URL(string: "https://api-\(sendBirdAppID).sendbird.com/v3/group_channels/\(channelURL)/operators") else {
            return
        }
        
        let body: [String: Any] = [
            "operator_ids": operatorIDs
        ]
        
        let headers: HTTPHeaders = [
            "Api-Token": sendBirdMasterToken,
            "Content-Type": "application/json; charset=utf8"
        ]
        
        AF.request(url, method: .post, parameters: body, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            if 200...299 ~= (response.response?.statusCode ?? 0) {
                print("SUCCESSFULLY MADE USERS OPERATORS")
                completion(nil)
            } else {
                completion(ErrorStatus(errorMsg: "Error adding operators", errorMessageType: .none))
            }
        }
    }
    
    func getMemberList(channelURL: String, completion: @escaping (ErrorStatus?, [SendbirdMemberObject]?) -> Void) {
        guard let url = URL(string: "https://api-\(sendBirdAppID).sendbird.com/v3/group_channels/\(channelURL)/members")
        else {
            return
        }
                
        let headers: HTTPHeaders = [
            "Api-Token": sendBirdMasterToken,
            "Content-Type": "application/json; charset=utf8"
        ]
        
        AF.request(url, method: .get, encoding: JSONEncoding.default, headers: headers).responseDecodable(of: SendbirdMemberListResponse.self) { (response) in
            switch response.result {
            case .success(let channelResponse):
                completion(nil, channelResponse.members ?? [])
            case .failure(let error):
                print(error.localizedDescription)
                completion(ErrorStatus(errorMsg: "Error getting member list", errorMessageType: .none), nil)
            }
        }
    }
}
