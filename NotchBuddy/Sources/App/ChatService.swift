// UI-facing dispatch; the existing Anthropic transport owns its multi-turn messages.
@MainActor
protocol ChatProvider {
    func chat(query: String, context: PromptContext?, state: AppState) async
    func clearConversation()
}

@MainActor
final class ChatService {
    static let shared = ChatService()
    private let anthropic = AnthropicChatProvider()

    private func provider(for id: ChatProviderID) -> any ChatProvider {
        switch id {
        case .anthropic: return anthropic
        }
    }

    func chat(query: String, context: PromptContext?, state: AppState) async {
        await provider(for: state.chatSelection.providerID).chat(query: query, context: context, state: state)
    }

    func clearConversation(state: AppState) {
        provider(for: state.chatSelection.providerID).clearConversation()
        state.chatHistory.removeAll()
        state.stateOverride = nil
    }
}
