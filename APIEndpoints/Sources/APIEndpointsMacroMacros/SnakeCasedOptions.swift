//
//  SnakeCasedOptions.swift
//  
//
//  Created by Abhinav Jha on 17/06/23.
//

import Foundation

public enum SnakeCasedOptions {
    case all
    case except([String])
    case custom([String: String])

    var necessaryProperties: [String] {
        switch self {
        case .all:
            []
        case .except(let array):
            array
        case .custom(let dictionary):
            .init(dictionary.keys)
        }
    }

    static func associatedValueArray(
        _ caseName: String,
        associatedValue: [String]
    ) -> Self? {
        switch caseName {
        case "except":
            return .except(associatedValue)

        default:
            return nil
        }
    }

    static func associatedValueDictionary(
        _ caseName: String,
        associatedValue: [String: String]
    ) -> Self? {
        if caseName == "custom" {
            return .custom(associatedValue)
        } else {
            return nil
        }
    }
}
