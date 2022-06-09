//
//  AvatarServices.swift
//  NITE
//
//  Created by Charles Oxendine on 4/18/22.
//

import Foundation
import UIKit

class AvatarServices {
    
    public static let shared = AvatarServices()
    
    func getAPIToken(completion: @escaping (ErrorStatus?, String?) -> ()) {
        let headers = [
            "X-RapidAPI-Host": "mirror-ai.p.rapidapi.com",
            "X-RapidAPI-Key": "bc4c5d36d3msha9ab1b507dbc5c6p1921cbjsn411efbebf1ce"
        ]

        let request = NSMutableURLRequest(url: NSURL(string: "https://mirror-ai.p.rapidapi.com/token")! as URL,
                                                cachePolicy: .useProtocolCachePolicy,
                                            timeoutInterval: 10.0)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = headers

        let session = URLSession.shared
        let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
            guard error == nil else {
                print(error!.localizedDescription)
                return
            }
            
            guard response != nil else {
                return
            }

            if let jsonString = String(data: data!, encoding: .utf8) {
                if let jsonDict = self.convertToDictionary(text: jsonString) {
                    if let token = jsonDict["token"] as? String {
                        completion(nil, token)
                    }
                }
            }
        })

        dataTask.resume()
    }
    
    func convertImageToAvatar(image: UIImage, completion: @escaping (ErrorStatus?, UIImage?) -> Void) {
        getAPIToken { error, token in
            if token != nil {
                guard let imageURL = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("TempImage\(UUID().uuidString).png") else {
                    return
                }

                let pngData = image.pngData()
                do {
                    try pngData?.write(to: imageURL)
                    
                    let parameters = [
                        [
                            "name": "photo",
                            "fileName": imageURL,
                            "contentType": "application/octet-stream",
                            "file": "[object File]"
                        ]
                    ]

                    let headers = [
                        "content-type": "multipart/form-data; boundary=---011000010111000001101001",
                        "X-Token": token,
                        "X-RapidAPI-Host": "mirror-ai.p.rapidapi.com",
                        "X-RapidAPI-Key": "bc4c5d36d3msha9ab1b507dbc5c6p1921cbjsn411efbebf1ce"
                    ]
                    let boundary = "---011000010111000001101001"

                    var body = ""
                    var error: NSError? = nil
                    for param in parameters {
                        let paramName = param["name"]!
                        body += "--\(boundary)\r\n"
                        body += "Content-Disposition:form-data; name=\"\(paramName)\""
                        if let filename = param["fileName"] {
                            let contentType = param["content-type"] ?? ""
                            let fileContent = (try? String(contentsOfFile: (filename as? String) ?? "", encoding: String.Encoding.utf8)) ?? ""
                            if (error != nil) {
                                print(error)
                            }
                            body += "; filename=\"\(filename)\"\r\n"
                            body += "Content-Type: \(contentType)\r\n\r\n"
                            body += fileContent
                        } else if let paramValue = param["value"] {
                            body += "\r\n\r\n\(paramValue)"
                        }
                    }

                    let request = NSMutableURLRequest(url: NSURL(string: "https://mirror-ai.p.rapidapi.com/generate?style=anime")! as URL,
                                                            cachePolicy: .useProtocolCachePolicy,
                                                        timeoutInterval: 10.0)
                    
                    let postData = NSMutableData(data: body.data(using: String.Encoding.utf8)!)
                    
                    request.httpMethod = "POST"
                    request.allHTTPHeaderFields = headers as? [String: String]
                    request.httpBody = postData as Data

                    let session = URLSession.shared
                    let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
                        if (error != nil) {
                            print(error)
                        } else {
                            let httpResponse = response as? HTTPURLResponse
                            if let jsonString = String(data: data!, encoding: .utf8) {
                                if let jsonDict = self.convertToDictionary(text: jsonString) {
                                    print("dict")
                                }
                            }
                        }
                    })

                    dataTask.resume()
                } catch {
                    print("CAUGHT ERROR")
                }
            }
        }
    }
    
    private func convertToDictionary(text: String) -> [String: Any]? {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }
    
}
