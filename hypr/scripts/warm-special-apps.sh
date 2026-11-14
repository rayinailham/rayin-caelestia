#!/usr/bin/env bash
set -euo pipefail

sleep 4

browser_re='app\.zen_browser\.zen|zen'

hide_visible_special() {
    hyprctl monitors -j | jq -r '.[].specialWorkspace.name | select(. != "")' | while read -r ws; do
        hyprctl dispatch "hl.dsp.workspace.toggle_special(\"${ws#special:}\")" >/dev/null || true
    done
}

if ! hyprctl clients -j | jq -e --arg re "$browser_re" 'any(.[]; (.class // "") | test($re; "i"))' >/dev/null; then
    active_ws=$(hyprctl activeworkspace -j | jq -r '.name // .id')
    hyprctl dispatch 'hl.dsp.exec_cmd("/home/rayin/.local/opt/zen-bridge/zen-rdp.sh")' >/dev/null

    for _ in {1..60}; do
        addr=$(hyprctl clients -j | jq -r --arg re "$browser_re" '.[] | select((.class // "") | test($re; "i")) | .address' | head -n1)
        if [[ -n "${addr:-}" ]]; then
            hyprctl dispatch "hl.dsp.window.move({ workspace = \"special:browser\", window = \"address:$addr\", follow = false })" >/dev/null || true
            [[ -n "${active_ws:-}" ]] && hyprctl dispatch "hl.dsp.focus({ workspace = \"$active_ws\" })" >/dev/null || true
            hide_visible_special
            break
        fi
        sleep 0.25
    done
fi
