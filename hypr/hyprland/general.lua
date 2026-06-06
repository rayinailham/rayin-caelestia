local vars = _G.vars

hl.config({
    general = {
        layout = "dwindle",
        allow_tearing = false,
        gaps_workspaces = tonumber(vars.workspaceGaps),
        gaps_in = tonumber(vars.windowGapsIn),
        gaps_out = tonumber(vars.windowGapsOut),
        border_size = tonumber(vars.windowBorderSize),
        col = {
            active_border = vars.activeWindowBorderColour,
            inactive_border = vars.inactiveWindowBorderColour,
        }
    },
    dwindle = {
        preserve_split = true,
        smart_split = false,
        smart_resizing = true,
    }
})
