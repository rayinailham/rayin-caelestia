#!/bin/bash

# Update Antigravity CLI settings.json based on Caelestia scheme mode
SETTINGS_FILE="$HOME/.gemini/antigravity-cli/settings.json"

if [ -f "$SETTINGS_FILE" ]; then
    if [ "$SCHEME_MODE" = "light" ]; then
        jq '.colorScheme = "light"' "$SETTINGS_FILE" > "$SETTINGS_FILE.tmp" && mv "$SETTINGS_FILE.tmp" "$SETTINGS_FILE"
    else
        # You can use "dark" or "terminal" here. We default to "dark" to match your previous setup.
        jq '.colorScheme = "dark"' "$SETTINGS_FILE" > "$SETTINGS_FILE.tmp" && mv "$SETTINGS_FILE.tmp" "$SETTINGS_FILE"
    fi
fi
