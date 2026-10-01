#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."

# Fresh DerivedData on every run prevents incremental builds from hiding warnings.
BUILD_DIR="$(mktemp -d /tmp/coucou-swift-warning-fixes.XXXXXX)"
LOG="$BUILD_DIR/build.log"
TARGETED="$BUILD_DIR/targeted-warnings.log"
printf 'Build directory: %s\nBuild log: %s\n' "$BUILD_DIR" "$LOG"

build_status=0
xcodebuild -project NotchBuddy/NotchBuddy.xcodeproj \
    -scheme NotchBuddy -configuration Debug -destination 'platform=macOS' \
    -derivedDataPath "$BUILD_DIR/DerivedData" \
    -disableAutomaticPackageResolution \
    CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO \
    clean build >"$LOG" 2>&1 || build_status=$?

# Match compiler diagnostics only, not destination or other Xcode warnings.
# Keep this gate scoped to the warning families and source files in SW-01.
awk '
    /\/Sources\/App\/(GreetingCanvasView|IslandRootView|IslandViewContent|IslandWindowController|IslandStateMachine|AppDelegate)\.swift:[0-9]+:[0-9]+: warning:/ {
        diagnostic = tolower($0)
        if (diagnostic ~ /actor.isolat|main actor|sendable|never mutated/ ||
            (diagnostic ~ /deprecated/ && diagnostic ~ /activat/)) {
            if (!seen[$0]++) print
        }
    }
' "$LOG" >"$TARGETED"

warning_count="$(awk 'END { print NR + 0 }' "$TARGETED")"
printf 'Targeted warning diagnostics: %s\n' "$warning_count"
if [[ "$warning_count" -gt 0 ]]; then
    while IFS= read -r diagnostic; do
        printf '%s\n' "$diagnostic"
    done <"$TARGETED"
fi

# Surface unrelated diagnostics as evidence without treating them as failures.
awk '
    /(^warning:|:[0-9]+:[0-9]+: warning:|^[0-9].* warning:)/ && !seen[$0]++ { print }
' "$LOG" >"$BUILD_DIR/all-warnings.log"
printf 'All warning diagnostics: %s\n' "$(awk 'END { print NR + 0 }' "$BUILD_DIR/all-warnings.log")"

if [[ "$build_status" -ne 0 ]]; then
    printf 'FAIL: clean Debug build exited %s\n' "$build_status" >&2
    awk '/: error:/ && !seen[$0]++ { print }' "$LOG" >&2
    tail -n 20 "$LOG" >&2
    exit "$build_status"
fi
if ! grep -q '\*\* BUILD SUCCEEDED \*\*' "$LOG"; then
    printf 'FAIL: clean Debug build success marker missing\n' >&2
    exit 1
fi
if [[ "$warning_count" -gt 0 ]]; then
    printf 'FAIL: targeted Swift warnings remain\n' >&2
    exit 1
fi
printf 'PASS: clean Debug build has no targeted Swift warnings\n'
