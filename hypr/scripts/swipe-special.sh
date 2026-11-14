#!/usr/bin/env bash
set -euo pipefail

shown=$(hyprctl monitors -j | jq -r '.[] | select(.focused) | .specialWorkspace.name')

[ -z "$shown" ] && exit 0

hyprctl dispatch "hl.dsp.workspace.toggle_special(\"${shown#special:}\")" >/dev/null
