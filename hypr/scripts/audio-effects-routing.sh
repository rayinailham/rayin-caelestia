#!/usr/bin/env bash
set -euo pipefail

easyeffects_config="$HOME/.config/easyeffects/db/easyeffectsrc"
jamesdsp_config="$HOME/.var/app/me.timschneeberger.jdsp4linux/config/jamesdsp/application.conf"

pick_sink() {
  local sink
  for sink in \
    "${AUDIO_EFFECTS_OUTPUT_DEVICE:-}" \
    alsa_output.usb-TTGK_Technology_Co._Ltd_CX31993_384Khz_HIFI_AUDIO-00.analog-stereo \
    alsa_output.pci-0000_00_1f.3-platform-skl_hda_dsp_generic.HiFi__Headphones__sink \
    alsa_output.pci-0000_00_1f.3-platform-skl_hda_dsp_generic.HiFi__Speaker__sink; do
    [[ -n "$sink" ]] && pactl list short sinks | cut -f2 | grep -Fxq "$sink" && {
      printf '%s\n' "$sink"
      return 0
    }
  done

  pactl list short sinks | cut -f2 | grep -Ev '^(jamesdsp_sink|easyeffects_sink)$' | head -n1
}

pick_source() {
  local source
  for source in \
    "${AUDIO_EFFECTS_INPUT_DEVICE:-}" \
    alsa_input.usb-TTGK_Technology_Co._Ltd_CX31993_384Khz_HIFI_AUDIO-00.mono-fallback \
    alsa_input.pci-0000_00_1f.3-platform-skl_hda_dsp_generic.HiFi__Mic1__source \
    alsa_input.pci-0000_00_1f.3-platform-skl_hda_dsp_generic.HiFi__Mic2__source; do
    [[ -n "$source" ]] && pactl list short sources | cut -f2 | grep -Fxq "$source" && {
      printf '%s\n' "$source"
      return 0
    }
  done

  pactl list short sources | cut -f2 | grep -Ev '^(easyeffects_source|.*\.monitor)$' | head -n1
}

set_key() {
  local file="$1" key="$2" value="$3"

  mkdir -p "$(dirname "$file")"
  touch "$file"

  if grep -q "^${key}=" "$file"; then
    perl -0pi -e "s/^\Q${key}\E=.*/${key}=${value}/m" "$file"
  else
    printf '%s=%s\n' "$key" "$value" >>"$file"
  fi
}

set_group_key() {
  local file="$1" group="$2" key="$3" value="$4"

  mkdir -p "$(dirname "$file")"
  touch "$file"

  if ! grep -q "^\[${group}\]$" "$file"; then
    printf '\n[%s]\n%s=%s\n' "$group" "$key" "$value" >>"$file"
  elif perl -0ne "exit(/\[\Q${group}\E\]\n(?:(?!\n\[).)*^\Q${key}\E=/ms ? 0 : 1)" "$file"; then
    perl -0pi -e "s/(\[\Q${group}\E\]\n(?:(?!\n\[).)*?)^\Q${key}\E=.*/\${1}${key}=${value}/ms" "$file"
  else
    perl -0pi -e "s/(\[\Q${group}\E\]\n)/\${1}${key}=${value}\n/ms" "$file"
  fi
}

physical_sink="$(pick_sink)"
physical_source="$(pick_source)"

[[ -n "$physical_sink" ]] && set_key "$jamesdsp_config" AudioOutputDevice "$physical_sink"
[[ -n "$physical_source" ]] && set_group_key "$easyeffects_config" StreamInputs inputDevice "$physical_source"

if ! pactl list short sources | grep -q '^.*easyeffects_source'; then
  easyeffects --gapplication-service >/tmp/easyeffects.log 2>&1 &
fi

if ! pactl list short sinks | grep -q '^.*jamesdsp_sink'; then
  flatpak run --command=jamesdsp me.timschneeberger.jdsp4linux >/tmp/jamesdsp.log 2>&1 &
fi

for _ in {1..50}; do
  pactl list short sources | grep -q '^.*easyeffects_source' && \
    pactl list short sinks | grep -q '^.*jamesdsp_sink' && \
    break
  sleep 0.2
done

pactl set-default-source easyeffects_source
pactl set-default-sink jamesdsp_sink

for input in $(pactl list short sink-inputs | cut -f1); do
  pactl move-sink-input "$input" jamesdsp_sink || true
done

for output in $(pactl list short source-outputs | cut -f1); do
  pactl move-source-output "$output" easyeffects_source || true
done
