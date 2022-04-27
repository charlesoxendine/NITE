//
//  ErrorStatus.swift
//  NITE
//
//  Created by Charles Oxendine on 4/16/22.
//

import Foundation

struct ErrorStatus {
    var errorMsg: String!
    var errorMessageType: ErrorMessageType!
}

enum ErrorMessageType: Int {
    case internalError
    case networkError
    case unknownError
    case authError
}
