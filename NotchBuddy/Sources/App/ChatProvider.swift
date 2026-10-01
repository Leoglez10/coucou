import Foundation

// Selection metadata stays independent of SwiftUI and the transport.
enum ChatProviderID: String, Sendable {
    case anthropic
}

enum ChatProviderSetupID: String, Sendable {
    case anthropic
    case opencodeGo = "opencode-go"
    case codex
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

// Setup visibility and saved configuration do not imply a working chat transport.
struct ChatProviderSetupDescriptor: Identifiable, Sendable {
    let id: ChatProviderSetupID
    let label: String
    let apiKeyKey: String?
    let modelPreferenceKey: String?

    var supportsAPIKeyConfiguration: Bool { apiKeyKey != nil }
    var isChatImplemented: Bool {
        ChatProviderCatalog.providers.contains { $0.id.rawValue == id.rawValue }
    }

    /// A saved key is not a verification result or a promise of chat availability.
    func isConfigured(hasSavedKey: Bool) -> Bool {
        supportsAPIKeyConfiguration && hasSavedKey
    }
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

    // Only implemented transports belong in the dispatchable catalog.
    static let providers = [anthropic]

    static let opencodeGoSetup = ChatProviderSetupDescriptor(
        id: .opencodeGo, label: "OpenCode Go",
        apiKeyKey: "opencode-go-api-key", modelPreferenceKey: "opencodeGoModel"
    )
    static let setupProviders = [
        ChatProviderSetupDescriptor(
            id: .anthropic, label: anthropic.label,
            apiKeyKey: "anthropic-api-key", modelPreferenceKey: anthropic.modelPreferenceKey
        ),
        opencodeGoSetup,
        ChatProviderSetupDescriptor(
            id: .codex, label: "Codex", apiKeyKey: nil, modelPreferenceKey: nil
        ),
    ]

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
