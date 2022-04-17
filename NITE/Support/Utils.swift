//
//  Utils.swift
//  NITE
//
//  Created by Charles Oxendine on 4/12/22.
//

import Foundation

class Utils {
    
    static public func isValidPassword(password: String!) -> Bool {
        let passwordRegex = "^(?=.*\\d)(?=.*[a-z])(?=.*[A-Z])[0-9a-zA-Z!@#$%^&*()\\-_=+{}|?>.<,:;~`’]{8,}$"
        return NSPredicate(format: "SELF MATCHES %@", passwordRegex).evaluate(with: password)
    }
    
}
