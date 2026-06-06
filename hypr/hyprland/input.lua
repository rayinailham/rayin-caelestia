local vars = _G.vars

local function to_bool(v)
    if v == "true" or v == true then return true end
    if v == "false" or v == false then return false end
    return v
end

hl.config({
    input = {
        kb_layout = "us",
        numlock_by_default = false,
        repeat_delay = 250,
        repeat_rate = 35,
        focus_on_close = 1,
        touchpad = {
            natural_scroll = true,
            disable_while_typing = to_bool(vars.touchpadDisableTyping),
            scroll_factor = tonumber(vars.touchpadScrollFactor),
        }
    },
    binds = {
        scroll_event_delay = 0,
    },
    cursor = {
        hotspot_padding = 1,
        no_hardware_cursors = true,
    }
})
