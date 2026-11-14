-- Ported 1:1 from rules.conf (Hyprland 0.57 dropped hyprlang, 2026-11-14)
local vars = require("variables")

local function rule(match, props)
    props.match = match
    hl.window_rule(props)
end

local float_sized = function(match, w, h)
    rule(match, { float = true, size = "(monitor_w*" .. w .. ") (monitor_h*" .. h .. ")", center = true })
end

----------------------
---- Window rules ----
----------------------

rule({ fullscreen = false }, { opacity = vars.windowOpacity .. " override" })
rule({ class = "foot|equibop|org\\.quickshell|imv|swappy" }, { opaque = true }) -- Native transparency or want opaque
rule({ float = true, xwayland = false }, { center = true })                    -- Center floating (not xwayland popups)

-- Float
for _, class in ipairs({
    "guifetch", "yad", "zenity", "wev", "org\\.gnome\\.FileRoller", "file-roller", "blueman-manager",
    "com\\.github\\.GradienceTeam\\.Gradience", "feh", "imv", "system-config-printer", "org\\.quickshell",
}) do
    rule({ class = class }, { float = true })
end
rule({ class = "agent-picker" }, { float = true, center = true })

-- Float, resize and center
float_sized({ class = "foot", title = "nmtui" }, 0.6, 0.7)
float_sized({ class = "org\\.gnome\\.Settings" }, 0.7, 0.8)
float_sized({ class = "org\\.pulseaudio\\.pavucontrol|yad-icon-browser" }, 0.6, 0.7)
float_sized({ class = "nwg-look" }, 0.5, 0.6)

-- Special workspaces
rule({ class = "btop" }, { workspace = "special:sysmon" })
rule({ class = "feishin|Spotify|Supersonic|Cider|com.github.th_ch.youtube_music|Plexamp|com-maxrave-simpmusic-MainKt" },
    { workspace = "special:music" })
rule({ initial_title = "Spotify( Free)?" }, { workspace = "special:music" }) -- Spotify wayland has no class
rule({ class = "discord|equibop|vesktop|serein|cz\\.viceverse\\.serein|whatsapp" }, { workspace = "special:communication" })
rule({ class = "whatsdesk" }, { workspace = "special:whatsapp" })

-- Transparency rules
rule({ class = "^(app\\.zen_browser\\.zen)$" }, { opacity = "1.00 override" })
rule({ class = "whatsdesk|WhatsDesk|whatsapp" }, { opacity = "1.00 override" })
rule({ class = "cz\\.viceverse\\.serein" }, { opacity = "0.95 0.95 override" })

-- Dialogs
for _, title in ipairs({
    "(Select|Open)( a)? (File|Folder)(s)?", "File (Operation|Upload)( Progress)?", ".* Properties",
    "Export Image as PNG", "GIMP Crash Debug", "Save As", "Library",
}) do
    rule({ title = title }, { float = true })
end

-- Picture in picture (resize and move done via `caelestia resizer`)
rule({ title = "Picture(-| )in(-| )[Pp]icture" }, {
    move              = "(monitor_w*0.98-window_w) (monitor_h*0.97-window_h)", -- Initial move so it doesn't shoot across
    keep_aspect_ratio = true,
    float             = true,
    pin               = true,
})

-- Creative software
rule({ class = "krita|gimp|inkscape|darktable|resolve|kdenlive|shotcut|blender|godot" }, { opaque = true })

-- Ueberzugpp
rule({ class = "^(ueberzugpp_.*)$" }, { float = true, no_initial_focus = true })

-- Steam
rule({ class = "steam" }, { rounding = 10 })
rule({ class = "steam", title = "Friends List" }, { float = true })

-- Games (Steam, Lutris/Wine, Gamescope)
rule({ class = "(steam_app_(default|[0-9]+))|gamescope" }, { opaque = true, immediate = true, idle_inhibit = "always" })

-- Minecraft launcher consoles
rule({ class = "com-atlauncher-App", title = "ATLauncher Console" }, { float = true })
rule({ class = "PandoraLauncher", title = "Minecraft Game Output" }, { float = true })

-- Autodesk Fusion 360
rule({ class = "fusion360\\.exe", title = "Fusion360|(Marking Menu)" }, { no_blur = true })

-- Ugh xwayland popups
rule({ xwayland = true, title = "win[0-9]+" }, { no_dim = true, no_shadow = true, rounding = 10 })

-------------------------
---- Workspace rules ----
-------------------------

hl.workspace_rule({ workspace = "w[tv1]s[false]", gaps_out = vars.singleWindowGapsOut })
hl.workspace_rule({ workspace = "f[1]s[false]", gaps_out = vars.singleWindowGapsOut })

---------------------
---- Layer rules ----
---------------------

hl.layer_rule({ match = { namespace = "hyprpicker" }, animation = "fade" })    -- Colour picker out animation
hl.layer_rule({ match = { namespace = "logout_dialog" }, animation = "fade" }) -- wlogout
hl.layer_rule({ match = { namespace = "selection" }, animation = "fade" })     -- slurp
hl.layer_rule({ match = { namespace = "wayfreeze" }, animation = "fade" })
hl.layer_rule({ match = { namespace = "launcher" }, animation = "popin 80%", blur = true }) -- Fuzzel

-- Shell
hl.layer_rule({ match = { namespace = "caelestia-(border-exclusion|area-picker)" }, no_anim = true })
hl.layer_rule({ match = { namespace = "caelestia-(drawers|background)" }, animation = "fade" })
