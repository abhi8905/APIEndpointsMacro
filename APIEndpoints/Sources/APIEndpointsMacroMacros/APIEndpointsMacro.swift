import SwiftCompilerPlugin
import Foundation
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public struct APIEndpointsMacro: MemberMacro {
    public static func expansion<
        Declaration: DeclGroupSyntax, Context: MacroExpansionContext>(
        of node: AttributeSyntax,
        providingMembersOf declaration: Declaration,
        in context: Context) throws -> [DeclSyntax] {
            guard let enumDecl = declaration.as(EnumDeclSyntax.self) else {
                throw APIEndpointsError.onlyApplicableToEnum
            }
            let members = enumDecl.memberBlock.members
            let caseDecls = members.compactMap { $0.decl.as(EnumCaseDeclSyntax.self) }
            let elements = caseDecls.flatMap { $0.elements }
            var snakeCasedOptions: SnakeCasedOptions? = .all
            if case let .argumentList(arguments) = node.argument,
               let firstElement = arguments.first?.expression,let functionCallExpr = firstElement.as(FunctionCallExprSyntax.self){
                snakeCasedOptions = getSnakeCasedOptions(fromExpr: functionCallExpr)
            }
            guard let snakeCasedOptions = snakeCasedOptions else{
                throw APIEndpointsError.invalidSnakeCasedOptions
            }
            let variable = try VariableDeclSyntax("var endpointUrl: String") {
                try SwitchExprSyntax("switch self") {
                    for element in elements {
                        SwitchCaseSyntax(
                            """
                            case .\(element.identifier):
                                return "\(raw: get(rawvalue: element.identifier.text, basedOn: snakeCasedOptions))"
                            """
                        )
                    }
                }
            }

        return [DeclSyntax(variable)]
    }
    private static func get(rawvalue: String, basedOn snakeCasedOptions: SnakeCasedOptions) -> String {
        switch snakeCasedOptions {
        case .all:
            return rawvalue.camelToSnakeCase()
        case let .except(excludedProperties):
            if excludedProperties.contains(rawvalue) {
                return rawvalue
            } else {
                return rawvalue.camelToSnakeCase()
            }
        case let .custom(customNamePair):
            if customNamePair.map(\.key).contains(rawvalue),
               let value = customNamePair[rawvalue]
            {
                return value
            } else {
                return rawvalue.camelToSnakeCase()
            }
        }
    }
    
    private static func getSnakeCasedOptions(
        fromExpr functionCallExpr: FunctionCallExprSyntax
    ) -> SnakeCasedOptions? {
        guard let caseName = functionCallExpr.calledExpression.as(MemberAccessExprSyntax.self)?.name.text,
              let expr = functionCallExpr.argumentList.first?.expression else
        {
            return nil
        }

        if let arrayExpr = expr.as(ArrayExprSyntax.self),
           let stringArray = arrayExpr.stringArray
        {
            return .associatedValueArray(caseName, associatedValue: stringArray)
        }
        else if let dictionaryElements = expr.as(DictionaryExprSyntax.self),
                let stringDictionary = dictionaryElements.stringDictionary
        {
            return .associatedValueDictionary(caseName, associatedValue: stringDictionary)
        }
        else {
            return nil
        }
    }
}



@main
struct APIEndpointsPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        APIEndpointsMacro.self,
    ]
}

extension String {
    func camelToSnakeCase() -> String {
        let regex = try! NSRegularExpression(pattern: "([a-z0-9])([A-Z])", options: [])
        let range = NSRange(location: 0, length: self.count)
        let snakeCase = regex.stringByReplacingMatches(in: self, options: [], range: range, withTemplate: "$1_$2")
        return snakeCase.lowercased()
    }
}
