@MainActor
struct AnthropicChatProvider: ChatProvider {
    func chat(query: String, context: PromptContext?, state: AppState) async {
        await ClaudeService.shared.chat(query: query, context: context, state: state)
    }

    func clearConversation() {
        ClaudeService.shared.clearConversation()
    }
}
