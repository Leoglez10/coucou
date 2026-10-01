#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
TEST_DIR="$(mktemp -d "${TMPDIR:-/tmp}/coucou-chat-provider.XXXXXX")"
swiftc -swift-version 6 NotchBuddy/Sources/App/ChatProvider.swift \
    tests/ChatProviderSelectionTests.swift -o "$TEST_DIR/chat-provider-tests"
"$TEST_DIR/chat-provider-tests"
