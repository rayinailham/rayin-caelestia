#!/usr/bin/env bash
# Close (hide) every special workspace currently shown on any monitor.
# Hyprland only shows one special workspace per monitor at a time, so we
# loop over all monitors and toggle off whatever special ws is visible.
set -euo pipefail

# Toggle off the special workspace visible on each monitor.
# .specialWorkspace.name is "" when none is shown, or "special:NAME".
mapfile -t open < <(hyprctl monitors -j | jq -r '.[].specialWorkspace.name | select(. != "")')

for ws in "${open[@]}"; do
    # togglespecialworkspace expects the bare name (without "special:" prefix).
    # The default workspace's bare name is literally "special".
    name="${ws#special:}"
    hyprctl dispatch "hl.dsp.workspace.toggle_special(\"$name\")" >/dev/null
done
