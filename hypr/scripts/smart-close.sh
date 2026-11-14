#!/usr/bin/env bash
set -euo pipefail

win=$(hyprctl activewindow -j 2>/dev/null || echo "{}")
cls=$(echo "$win" | jq -r '.class // ""')
pid=$(echo "$win" | jq -r '.pid // 0')

if [[ "$cls" =~ (cz\.viceverse\.serein|serein) ]]; then
    flatpak kill cz.viceverse.serein >/dev/null 2>&1 || ( [[ "$pid" -gt 0 ]] && kill -9 "$pid" >/dev/null 2>&1 ) || true
else
    hyprctl dispatch 'hl.dsp.window.close()'
fi
