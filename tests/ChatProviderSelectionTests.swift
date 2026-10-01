import Foundation

@main
enum ChatProviderSelectionTests {
    static func main() {
        var assertions = 0
        func check(_ condition: Bool, _ message: String) {
            precondition(condition, message)
            assertions += 1
        }

        let catalog = ChatProviderCatalog.providers
        check(catalog.map(\.id) == [.anthropic], "Only the implemented provider is selectable")
        check(catalog[0].modelPreferenceKey == "claudeModel", "Keep the legacy preference key")
        check(catalog[0].models.contains { $0.id == catalog[0].defaultModelID }, "Default model is listed")

        let defaults = ChatProviderSelection()
        check(defaults.providerID == .anthropic, "Anthropic is the default provider")
        check(defaults.modelID == "claude-sonnet-4-6", "Keep the existing default model")
        for unavailable in ["opencode-go", "codex", "unknown", "", "Anthropic"] {
            let restored = ChatProviderSelection(providerID: unavailable, modelID: "claude-opus-5-5")
            check(restored.providerID == .anthropic, "Unavailable saved providers fall back")
            check(restored.modelID == "claude-opus-5-5", "Fallback retains the Anthropic model")
        }

        for empty in [nil, "", " \n\t"] as [String?] {
            check(ChatProviderSelection(modelID: empty).modelID == defaults.modelID,
                  "Missing or blank models fall back")
        }
        check(ChatProviderSelection(modelID: " claude-haiku-4-5-20251001 \n").modelID
              == "claude-haiku-4-5-20251001", "Trim model IDs")
        check(ChatProviderSelection(modelID: "custom-account-model").modelID
              == "custom-account-model", "Custom legacy model IDs remain usable")

        var selection = ChatProviderSelection(modelID: "custom-account-model")
        for unavailable in ["codex", "opencode-go", "unknown", ""] {
            let before = selection
            check(!selection.selectProvider(unavailable), "Reject unavailable providers without a reset")
            check(selection == before, "Rejected selection preserves provider and model")
        }
        check(!selection.selectProvider("anthropic"), "Reselecting the provider does not reset history")
        check(selection.modelID == "custom-account-model", "Reselecting preserves the model")
        selection.selectModel("claude-opus-5-5")
        check(selection.modelID == "claude-opus-5-5", "Model changes update the selection")
        check(selection.providerID == .anthropic, "Model changes preserve the provider")
        selection.selectModel(" \n ")
        check(selection.modelID == defaults.modelID, "Blank model updates use the default")

        print("Chat provider selection: \(assertions) assertions passed")
    }
}
