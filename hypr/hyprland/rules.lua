local vars = _G.vars

-- Window rules
hl.window_rule({
    match = { fullscreen = false },
    opacity = vars.windowOpacity .. " override",
})

hl.window_rule({
    match = { class = "foot|equibop|org\\.quickshell|imv|swappy" },
    opaque = true,
})

hl.window_rule({
    match = { float = true, xwayland = false },
    center = true,
})

-- Common floating windows
hl.window_rule({
    match = { class = "guifetch|yad|zenity|wev|org\\.gnome\\.FileRoller|file-roller|blueman-manager|com\\.github\\.GradienceTeam\\.Gradience|feh|imv|system-config-printer|org\\.quickshell" },
    float = true,
})

-- Specific floating windows with size & centering
hl.window_rule({
    match = { class = "foot", title = "nmtui" },
    float = true,
    size = "60% 70%",
    center = true,
})

hl.window_rule({
    match = { class = "org\\.gnome\\.Settings" },
    float = true,
    size = "70% 80%",
    center = true,
})

hl.window_rule({
    match = { class = "org\\.pulseaudio\\.pavucontrol|yad-icon-browser" },
    float = true,
    size = "60% 70%",
    center = true,
})

hl.window_rule({
    match = { class = "nwg-look" },
    float = true,
    size = "50% 60%",
    center = true,
})

-- Special workspaces
hl.window_rule({ match = { class = "btop" }, workspace = "special:sysmon" })
hl.window_rule({ match = { class = "feishin|Spotify|Supersonic|Cider|com.github.th_ch.youtube_music|Plexamp|com-maxrave-simpmusic-MainKt" }, workspace = "special:music" })
hl.window_rule({ match = { initial_title = "Spotify( Free)?" }, workspace = "special:music" })
hl.window_rule({ match = { class = "discord|equibop|vesktop|whatsapp" }, workspace = "special:communication" })
hl.window_rule({ match = { class = "whatsdesk" }, workspace = "special:whatsapp" })
hl.window_rule({ match = { class = "teams-for-linux" }, workspace = "special:teams" })

-- Dedicated Browser Workspace
hl.window_rule({ match = { class = "^(app\\.zen_browser\\.zen)$" }, workspace = "special:browser" })

-- Transparency rules
hl.window_rule({ match = { class = "^(app\\.zen_browser\\.zen)$" }, opacity = "0.90 override" })
hl.window_rule({ match = { class = "whatsdesk|WhatsDesk|whatsapp" }, opacity = "0.90 override" })


-- Common dialogs
hl.window_rule({
    match = { title = "(Select|Open)( a)? (File|Folder)(s)?|File (Operation|Upload)( Progress)?|.* Properties|Export Image as PNG|GIMP Crash Debug|Save As|Library" },
    float = true,
})

-- Picture-in-picture
hl.window_rule({
    match = { title = "Picture(-| )in(-| )[Pp]icture" },
    move = "100%-w-2% 100%-w-3%",
    keep_aspect_ratio = true,
    float = true,
    pin = true,
})

-- Creative software
hl.window_rule({ match = { class = "krita|gimp|inkscape|darktable|resolve|kdenlive|shotcut|blender|godot" }, opaque = true })

-- Ueberzugpp
hl.window_rule({
    match = { class = "^(ueberzugpp_.*)$" },
    float = true,
    no_initial_focus = true,
})

-- Steam
hl.window_rule({ match = { class = "steam" }, rounding = 10 })
hl.window_rule({ match = { class = "steam", title = "Friends List" }, float = true })

-- Games (Steam, Lutris/Wine, Gamescope)
hl.window_rule({
    match = { class = "(steam_app_(default|[0-9]+))|gamescope" },
    opaque = true,
    immediate = true,
    idle_inhibit = "always",
})

-- Minecraft launcher consoles
hl.window_rule({ match = { class = "com-atlauncher-App", title = "ATLauncher Console" }, float = true })
hl.window_rule({ match = { class = "PandoraLauncher", title = "Minecraft Game Output" }, float = true })

-- Autodesk Fusion 360
hl.window_rule({ match = { class = "fusion360\\.exe", title = "Fusion360|(Marking Menu)" }, no_blur = true })

-- Xwayland popups
hl.window_rule({
    match = { xwayland = 1, title = "win[0-9]+" },
    no_dim = true,
    no_shadow = true,
    rounding = 10,
})

-- Workspace rules
hl.workspace_rule({ workspace = "w[tv1]", gaps_out = tonumber(vars.singleWindowGapsOut) })
hl.workspace_rule({ workspace = "f[1]", gaps_out = tonumber(vars.singleWindowGapsOut) })

-- Layer rules
hl.layer_rule({ match = { namespace = "hyprpicker|logout_dialog|selection|wayfreeze" }, animation = "fade" })

hl.layer_rule({
    match = { namespace = "launcher" },
    animation = "popin 80%",
    blur = true,
})

hl.layer_rule({ match = { namespace = "caelestia-(border-exclusion|area-picker)" }, no_anim = true })
hl.layer_rule({ match = { namespace = "caelestia-(drawers|background)" }, animation = "fade" })
