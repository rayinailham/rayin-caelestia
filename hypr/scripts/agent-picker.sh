#!/usr/bin/env bash
set -euo pipefail

# If modal is currently visible on screen -> Toggle CLOSE
if hyprctl clients -j 2>/dev/null | jq -e '.[] | select(.class == "agent-picker")' >/dev/null 2>&1; then
    pkill -f agent-picker.py || true
    exit 0
fi

exec /home/rayin/.config/hypr/scripts/agent-picker.py "$@"
