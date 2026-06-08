#!/usr/bin/env bash
set -u

INTERVAL="${FOCUS_IDLE_INHIBIT_INTERVAL:-2}"
QS_CONFIG="${FOCUS_IDLE_INHIBIT_QS_CONFIG:-caelestia}"

CLASS_RE="${FOCUS_IDLE_INHIBIT_CLASS_RE:-^(app\.zen_browser\.zen|zen|zen-browser|firefox|chromium|google-chrome|brave-browser)$}"

APP_RE="${FOCUS_IDLE_INHIBIT_APP_RE:-^(Zen|Firefox|Chromium|Google Chrome|Brave)$}"

log() {
    printf '[focus-idle-inhibit] %s\n' "$*" >&2
}

qs_call() {
    qs -c "$QS_CONFIG" ipc call idleInhibitor "$1" >/dev/null 2>&1
}

inhibitor_enabled() {
    qs -c "$QS_CONFIG" ipc call idleInhibitor isEnabled 2>/dev/null | grep -qx 'true'
}

set_inhibit() {
    local want="$1"

    if [[ "$want" == true ]]; then
        inhibitor_enabled || qs_call enable
    else
        inhibitor_enabled && qs_call disable
    fi
}

active_class() {
    hyprctl activewindow -j 2>/dev/null | jq -r '.class // empty' 2>/dev/null
}

matching_focus() {
    local class
    class="$(active_class)"
    [[ "$class" =~ $CLASS_RE ]]
}

active_playback() {
    pactl list sink-inputs 2>/dev/null | awk -v app_re="$APP_RE" '
        /^Sink Input/ { corked=""; app="" }
        /^[[:space:]]*Corked:/ { corked=$2 }
        /application.name = / {
            app=$0
            sub(/^.*application.name = "/, "", app)
            sub(/".*$/, "", app)
        }
        app ~ app_re && corked == "no" { found=1 }
        END { exit found ? 0 : 1 }
    '
}

active_capture() {
    pactl list source-outputs 2>/dev/null | awk -v app_re="$APP_RE" '
        /^Source Output/ { app="" }
        /application.name = / {
            app=$0
            sub(/^.*application.name = "/, "", app)
            sub(/".*$/, "", app)
        }
        app ~ app_re { found=1 }
        END { exit found ? 0 : 1 }
    '
}

should_inhibit() {
    matching_focus && { active_playback || active_capture; }
}

main() {
    command -v hyprctl >/dev/null || { log 'missing hyprctl'; exit 1; }
    command -v jq >/dev/null || { log 'missing jq'; exit 1; }
    command -v pactl >/dev/null || { log 'missing pactl'; exit 1; }
    command -v qs >/dev/null || { log 'missing qs'; exit 1; }

    trap 'set_inhibit false; exit 0' INT TERM EXIT

    local last=""
    while true; do
        if should_inhibit; then
            [[ "$last" == true ]] || log 'focused media/meeting active -> inhibit idle'
            set_inhibit true
            last=true
        else
            [[ "$last" == false ]] || log 'no focused media/meeting -> allow idle'
            set_inhibit false
            last=false
        fi

        sleep "$INTERVAL"
    done
}

main "$@"
