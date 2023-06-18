//
//  Utility.swift
//
//
//  Created by Abhinav Jha on 17/06/23.
//

import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

extension ArrayExprSyntax {
    var stringArray: [String]? {
        elements.reduce(into: [String]()) { result, element in
            guard let string = element.expression.as(StringLiteralExprSyntax.self) else {
                return
            }
            result.append(string.rawValue)
        }
    }
}

extension StringLiteralExprSyntax {
    var rawValue: String {
        segments
            .compactMap { $0.as(StringSegmentSyntax.self) }
            .map(\.content.text)
            .joined()
    }
}
extension DictionaryExprSyntax {
    var stringDictionary: [String: String]? {
        guard let elements = content.as(DictionaryElementListSyntax.self) else {
            return nil
        }

        return elements.reduce(into: [String: String]()) { result, element in
            guard let key = element.keyExpression.as(StringLiteralExprSyntax.self),
                  let value = element.valueExpression.as(StringLiteralExprSyntax.self)
            else {
                return
            }
            result.updateValue(value.rawValue, forKey: key.rawValue)
        }
    }
}
