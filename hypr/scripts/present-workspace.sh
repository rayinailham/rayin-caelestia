#!/usr/bin/env bash
set -euo pipefail

monitors=$(hyprctl monitors -j)
internal=$(jq -r '[.[] | select(.name | startswith("eDP"))][0].name // .[0].name' <<<"$monitors")
external=$(jq -r --arg internal "$internal" '[.[] | select(.name != $internal)] | sort_by(if (.name | startswith("HDMI")) then 0 elif (.name | startswith("DP")) then 1 else 2 end) | .[0].name // empty' <<<"$monitors")

if [[ -z "$external" ]]; then
    notify-send -u normal -i video-display "Presentasi" "Tidak ada monitor eksternal yang terdeteksi."
    exit 1
fi

internal_workspace=$(jq -r --arg internal "$internal" '.[] | select(.name == $internal) | .activeWorkspace.id' <<<"$monitors")
workspaces=$(hyprctl workspaces -j)
options=$(
    for workspace in {1..10}; do
        windows=$(jq -r --argjson workspace "$workspace" '[.[] | select(.id == $workspace)][0].windows // 0' <<<"$workspaces")
        monitor=$(jq -r --argjson workspace "$workspace" '[.[] | select(.id == $workspace)][0].monitor // empty' <<<"$workspaces")
        status="$windows jendela"
        [[ -n "$monitor" ]] && status+=" • $monitor"
        printf '%s  Workspace %s • %s\n' "$workspace" "$workspace" "$status"
    done
)

choice=$(fuzzel --dmenu --prompt="Tampilkan di $external: " --placeholder="Pilih workspace 1–10" <<<"$options") || exit 0
workspace=${choice%% *}

if [[ ! "$workspace" =~ ^([1-9]|10)$ ]]; then
    notify-send -u normal -i dialog-error "Presentasi" "Workspace harus berupa angka 1–10."
    exit 1
fi

if [[ "$workspace" == "$internal_workspace" ]]; then
    notify-send -u normal -i video-display "Presentasi" "Workspace $workspace sedang tampil di layar laptop. Pilih workspace lain."
    exit 1
fi

hyprctl dispatch "hl.dsp.workspace.move({ workspace = \"$workspace\", monitor = \"$external\" })" >/dev/null
hyprctl dispatch "hl.dsp.focus({ monitor = \"$external\" })" >/dev/null
hyprctl dispatch "hl.dsp.focus({ workspace = \"$workspace\" })" >/dev/null
hyprctl dispatch "hl.dsp.focus({ monitor = \"$internal\" })" >/dev/null
hyprctl dispatch "hl.dsp.focus({ workspace = \"$internal_workspace\" })" >/dev/null

notify-send -u low -i video-display "Presentasi" "Workspace $workspace ditampilkan di $external."
