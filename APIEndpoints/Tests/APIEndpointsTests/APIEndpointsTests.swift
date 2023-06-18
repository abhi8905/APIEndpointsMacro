import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest
import APIEndpointsMacroMacros

let testMacros: [String: Macro.Type] = [
    "APIEndpoints": APIEndpointsMacro.self,
]

final class APIEndpointsTests: XCTestCase {
    func testAPIEndpoints() {
        assertMacroExpansion(
            """
            @APIEndpoints()
                enum Paths: String {
                    case popular, topRated, upcoming, nowPlaying
                    
                }
            """,
            expandedSource: """
            
                enum Paths: String {
                            case popular, topRated, upcoming, nowPlaying
                    var endpointUrl: String {
                        switch self {
                        case .popular:
                            return "popular"
                        case .topRated:
                            return "top_rated"
                        case .upcoming:
                            return "upcoming"
                        case .nowPlaying:
                            return "now_playing"
                        }
                    }
                    
                }
            """,
            macros: testMacros
        )
    }

    func testAPIEndpointsExceptCase() {
        assertMacroExpansion(
            """
            @APIEndpoints(.except(["topRated"]))
                enum Paths: String {
                    case popular, topRated, upcoming, nowPlaying
                    
                }
            """,
            expandedSource: """
            
                enum Paths: String {
                            case popular, topRated, upcoming, nowPlaying
                    var endpointUrl: String {
                        switch self {
                        case .popular:
                            return "popular"
                        case .topRated:
                            return "topRated"
                        case .upcoming:
                            return "upcoming"
                        case .nowPlaying:
                            return "now_playing"
                        }
                    }
                    
                }
            """,
            macros: testMacros
        )
    }
    func testAPIEndpointsCustomCase() {
        assertMacroExpansion(
            """
            @APIEndpoints(.custom(["topRated":"movie/topRated"]))
                enum Paths: String {
                    case popular, topRated, upcoming, nowPlaying
                    
                }
            """,
            expandedSource: """
            
                enum Paths: String {
                            case popular, topRated, upcoming, nowPlaying
                    var endpointUrl: String {
                        switch self {
                        case .popular:
                            return "popular"
                        case .topRated:
                            return "movie/topRated"
                        case .upcoming:
                            return "upcoming"
                        case .nowPlaying:
                            return "now_playing"
                        }
                    }
                    
                }
            """,
            macros: testMacros
        )
    }
    func testAPIEndpointsOnStruct() throws {
        assertMacroExpansion(
            """
            @APIEndpoints()
                struct Paths {
                }
            """,
            expandedSource: """

                struct Paths {
                }
            """,
            diagnostics: [
                DiagnosticSpec(message: "@APIEndpoints can only be applied to an enum.", line: 1, column: 1)
            ],
            macros: testMacros
        )
    }
    func testInvalidAPIEndpoints() throws {
        assertMacroExpansion(
            """
            @APIEndpoints(.except())
                enum Paths: String {
                    case popular, topRated, upcoming, nowPlaying
                }
            """,
            expandedSource: """

                enum Paths: String {
                            case popular, topRated, upcoming, nowPlaying
                }
            """,
            diagnostics: [
                DiagnosticSpec(message: "Invalid SnakeCasedOptions", line: 1, column: 1)
            ],
            macros: testMacros
        )
    }
}
