
@attached(member, names: arbitrary)
public macro APIEndpoints(_ type: SnakeCasedOptions = .all) = #externalMacro(module: "APIEndpointsMacroMacros", type: "APIEndpointsMacro")


public enum SnakeCasedOptions {
    case all
    case custom([String: String])
    case except([String])
}
