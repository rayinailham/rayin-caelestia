-- Ported from variables.conf (Hyprland 0.57 dropped hyprlang, 2026-11-14)
local scheme = require("scheme.current")

return {
    ------------------
    ---- HYPRLAND ----
    ------------------

    -- Apps
    terminal                   = "~/.config/hypr/scripts/launch-terminal.sh",
    browser                    = "/home/rayin/.local/opt/zen-bridge/zen-rdp.sh",
    editor                     = "~/.config/hypr/scripts/agent-picker.sh",
    fileExplorer               = "dolphin",
    audioSettings              = "pavucontrol",

    -- Touchpad
    touchpadDisableTyping      = true,
    touchpadScrollFactor       = 0.3,
    gestureFingers             = 3,
    workspaceSwipeFingers      = 4,
    gestureFingersMore         = 4,

    -- Blur
    blurEnabled                = false,
    blurSpecialWs              = false,
    blurPopups                 = true,
    blurInputMethods           = true,
    blurSize                   = 6,
    blurPasses                 = 1,
    blurXray                   = false,

    -- Shadow
    shadowEnabled              = false,
    shadowRange                = 10,
    shadowRenderPower          = 3,
    shadowColour               = "rgba(" .. scheme.surface .. "d4)",

    -- Gaps
    workspaceGaps              = 20,
    windowGapsIn               = 5,
    windowGapsOut              = 10,
    singleWindowGapsOut        = 20,

    -- Window styling
    windowOpacity              = 1.0,
    windowRounding             = 15,
    windowRoundingPower        = 2,
    windowBorderSize           = 1,
    activeWindowBorderColour   = "rgba(" .. scheme.primary .. "e6)",
    inactiveWindowBorderColour = "rgba(" .. scheme.onSurfaceVariant .. "11)",

    -- Misc
    volumeStep                 = 10,
    volumeMax                  = 100,
    cursorTheme                = "sweet-cursors",
    cursorSize                 = 24,
    sleepGestureCmd            = "systemctl suspend",
    specialWsCloseAny          = false,

    ------------------
    ---- KEYBINDS ----
    ------------------
    -- Format: "MOD + MOD + key". Modifier-only entries are combined with 0-9.

    -- Workspaces
    kbMoveWinToWs              = "SUPER + ALT",
    kbMoveWinToWsGroup         = "CTRL + SUPER + ALT",
    kbGoToWs                   = "SUPER",
    kbGoToWsGroup              = "CTRL + SUPER",
    kbNextWs                   = "CTRL + SUPER + right",
    kbPrevWs                   = "CTRL + SUPER + left",
    kbToggleSpecialWs          = "SUPER + S",

    -- Window groups
    kbWindowGroupCycleNext     = "ALT + Tab",
    kbWindowGroupCyclePrev     = "SHIFT + ALT + Tab",
    kbUngroup                  = "SUPER + SHIFT + U",
    kbToggleGroup              = "SUPER + Comma",

    -- Window actions
    kbMoveWindow               = "SUPER + Z",
    kbResizeWindow             = "SUPER + X",
    kbWindowPip                = "SUPER + ALT + Backslash",
    kbPinWindow                = "SUPER + SHIFT + P",
    kbWindowFullscreen         = "SUPER + F",
    kbWindowBorderedFullscreen = "SUPER + ALT + F",
    kbToggleWindowFloating     = "SUPER + ALT + Space",
    kbCloseWindow              = "SUPER + Q",

    -- Special workspace toggles
    kbSystemMonitor            = "CTRL + SHIFT + Escape",
    kbMusic                    = "SUPER + M",
    kbWhatsapp                 = "SUPER + W",
    kbDiscord                  = "SUPER + D",

    -- Apps
    kbTerminal                 = "SUPER + T",
    kbBrowser                  = "SUPER + B",
    kbEditor                   = "SUPER + C",
    kbFileExplorer             = "SUPER + E",

    -- Misc
    kbSession                  = "CTRL + ALT + Delete",
    kbShowSidebar              = "SUPER + N",
    kbClearNotifs              = "CTRL + ALT + C",
    kbShowPanels               = "SUPER + K",
    kbLock                     = "SUPER + L",
    kbRestoreLock              = "SUPER + ALT + L",
}
