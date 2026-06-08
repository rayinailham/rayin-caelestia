#!/usr/bin/env bash
set -euo pipefail

# Give Hyprland, window rules, and the shell a moment to settle before warming
# heavyweight special-workspace apps in the background.
sleep 4



if ! hyprctl clients -j | jq -e 'any(.[]; (.class // "") | test("app\\.zen_browser\\.zen|zen"; "i"))' >/dev/null; then
    hyprctl dispatch exec "flatpak run app.zen_browser.zen" >/dev/null
fi
