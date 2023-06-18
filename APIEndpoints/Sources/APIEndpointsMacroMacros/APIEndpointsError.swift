//
//  APIEndpointsError.swift
//
//
//  Created by Abhinav Jha on 17/06/23.
//

import Foundation
import SwiftSyntax
import SwiftDiagnostics

public enum APIEndpointsError {
    case onlyApplicableToEnum
    case invalidSnakeCasedOptions
}

extension APIEndpointsError: CustomStringConvertible, Error {

    public var description: String {
        switch self {
        case .onlyApplicableToEnum:
            return "@APIEndpoints can only be applied to an enum."

        case .invalidSnakeCasedOptions:
            return "Invalid SnakeCasedOptions"
        }
    }
}
