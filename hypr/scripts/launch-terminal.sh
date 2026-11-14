#!/usr/bin/env bash
set -euo pipefail

TARGET_DIR=$(/home/rayin/.config/hypr/scripts/get-workspace-dir.py 2>/dev/null || echo "$HOME")
if [[ -z "$TARGET_DIR" || ! -d "$TARGET_DIR" ]]; then
    TARGET_DIR="$HOME"
fi

# Change working directory directly instead of passing -D to foot,
# because foot -D fails on paths containing colons (e.g. "RE:type-garden")
# by misinterpreting colons as remote SSH hostname syntax.
cd "$TARGET_DIR" || cd "$HOME"
exec foot
