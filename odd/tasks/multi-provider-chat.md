# Multi-provider chat foundation

## Intent and authorized scope
User authorized a macOS provider-neutral chat foundation and provider/model selector, retaining Anthropic. Actual OpenCode Go/Codex transports and terminal/repository actions are deferred. Only implemented providers are selectable. Preserve legacy `claudeModel`, `anthropic-api-key`, attachment/window context, web search, and multi-turn behavior. Never inspect credentials/home auth or change the bundle identifier.

User separately confirmed existing auto-close edits are theirs and explicitly authorized commits of both units on `performance`. No push/PR/merge. Preserve `.gitignore`, `.codegraph/`, and untracked shared schemes outside commits. The tracked generated Xcode project may include only the 18-line delta registering three new provider files; no manual project edits.

## Tasks and routing
- [ ] MP-01: Provider-neutral chat facade, catalog, settings, neutral labels, tests and README. Delegated direct because preparation and multiple non-trivial files are involved. Implementation present; functional checks passed. Strict initial RED evidence unavailable after writer timeout; do not claim compliant RED/GREEN completion. Commit pending. Native committed-range assessment was unavailable because untracked scope required a declaration; START then rejected target projection before creating a lineage. No native approval is claimed. Independent verification passed.
- [x] MP-02: Commit the user's auto-close changes as a separate work unit. Commit `140f11777e93e8c65339d37fc42bfe2f97f89d81` (`fix(island): close after the pointer leaves`), 18 additions/13 deletions across five files. Delegated read-only verification and parent exact-hunk staging preserved worktree bytes. Build verified; live UI timing not tested. Static caveat: changing delay does not reschedule an already armed collapse timer. No automatic scope expansion to fix this behavior. Native review unavailable; independent checks passed, no approval claimed.

## Verification evidence
Strict TDD enabled by `/Users/leoglez/AGENTS.md`; standalone Swift script harness. Initial RED required but no observed evidence available. GREEN checks observed by independent verifier:
- `bash scripts/test-chat-provider-selection.sh`: 33 assertions passed; repeated parent-requested spot check passed.
- `bash scripts/test-screen-geometry.sh`: 13 cases passed.
- `bash scripts/test-safe-links.sh`: 15 cases passed.
- Debug `xcodebuild` with signing disabled and `/tmp/coucou-multi-provider-verify` DerivedData: BUILD SUCCEEDED, Swift 6/arm64. Existing actor-isolation/deprecation warnings remain.
- `git diff --check`: passed.
Source/project hashes unchanged during verification. No live inference, app launch, actual credential access, or UI lifecycle test. Tests cover selection metadata, not in-flight response handling/persistence/display clearing. Build additionally invoked execution-policy/Launch Services registration; no cleanup or OS-state probing performed.

## Delivery and rollback
Strategy: ask-on-risk; ~350-line original forecast, advisory only. Confirmed counts: auto-close 31 authored lines; provider 296 including task document at verification time, plus 18 generated project lines. Refresh final counts after this task-document update. RDD on, decided globally; never toggle it. Native assessment/review unavailable for the attempted committed range; no lineage created, no reset/recovery or mode changes. Independent verification is the checking evidence, not a native receipt. Preserve source bytes while staging; rollback each committed unit independently, not overlapping whole files. Auto-close commit recorded above; provider commit pending.

## Next step
Final verification handoff received, user ownership resolved, and auto-close committed. Stage only provider paths/new files/documentation/generated registrations and commit. Record its identity in the recovery observation. Initial RED remains unavailable, so MP-01 stays explicitly partial against strict TDD despite passing functional checks. No OpenCode Go/Codex backend or terminal actions are included.
