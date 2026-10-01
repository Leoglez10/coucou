import Foundation

// Selection metadata stays independent of SwiftUI and the transport.
enum ChatProviderID: String, Sendable {
    case anthropic
}

struct ChatModel: Identifiable, Sendable {
    let id: String
    let label: String
}

struct ChatProviderDescriptor: Identifiable, Sendable {
    let id: ChatProviderID
    let label: String
    let modelPreferenceKey: String
    let defaultModelID: String
    let models: [ChatModel]
}

enum ChatProviderCatalog {
    static let anthropic = ChatProviderDescriptor(
        id: .anthropic,
        label: "Anthropic",
        modelPreferenceKey: "claudeModel",
        defaultModelID: "claude-sonnet-4-6",
        models: [
            ChatModel(id: "claude-sonnet-4-6", label: "Claude Sonnet 4.6"),
            ChatModel(id: "claude-sonnet-5-5", label: "Claude Sonnet 5.5"),
            ChatModel(id: "claude-opus-5-5", label: "Claude Opus 5.5"),
            ChatModel(id: "claude-haiku-4-5-20251001", label: "Claude Haiku 4.5"),
        ]
    )

    // Do not list providers until a working transport is available.
    static let providers = [anthropic]

    static func resolve(_ rawID: String?) -> ChatProviderDescriptor {
        providers.first { $0.id.rawValue == rawID } ?? anthropic
    }
}

struct ChatProviderSelection: Equatable, Sendable {
    private(set) var providerID: ChatProviderID
    private(set) var modelID: String

    var provider: ChatProviderDescriptor { ChatProviderCatalog.resolve(providerID.rawValue) }

    init(providerID: String? = nil, modelID: String? = nil) {
        let provider = ChatProviderCatalog.resolve(providerID)
        self.providerID = provider.id
        self.modelID = Self.resolveModel(modelID, provider: provider)
    }

    /// True only for an accepted change; callers then clear both display and transport history.
    @discardableResult
    mutating func selectProvider(_ rawID: String) -> Bool {
        guard let next = ChatProviderCatalog.providers.first(where: { $0.id.rawValue == rawID }),
              next.id != providerID else { return false }
        providerID = next.id
        modelID = next.defaultModelID
        return true
    }

    mutating func selectModel(_ rawID: String) {
        modelID = Self.resolveModel(rawID, provider: provider)
    }

    private static func resolveModel(_ rawID: String?, provider: ChatProviderDescriptor) -> String {
        let model = rawID?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        // Account-specific/custom IDs must not be discarded by the offline catalog.
        return model.isEmpty ? provider.defaultModelID : model
    }
}
