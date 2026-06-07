hl.config({
    debug = {
        disable_logs = false
    }
})

local home = os.getenv("HOME")
local hypr_dir = home .. "/.config/hypr"
local c_conf_dir = home .. "/.config/caelestia"

-- 1. Helper function to load variables from old conf files
local function load_vars(filepath)
    local vars = {}
    filepath = filepath:gsub("^~", home)
    local file = io.open(filepath, "r")
    if not file then return vars end
    for line in file:lines() do
        -- Trim comments and whitespace
        local clean_line = line:gsub("#.*", ""):gsub("^%s+", ""):gsub("%s+$", "")
        if clean_line ~= "" then
            -- Match $var = value
            local var, val = clean_line:match("^%$([%w_]+)%s*=%s*(.+)$")
            if var and val then
                -- Strip trailing comments if any
                val = val:gsub("%s*#.*", ""):gsub("^%s+", ""):gsub("%s+$", "")
                -- Strip quotes if present
                val = val:gsub("^['\"]", ""):gsub("['\"]$", "")
                vars[var] = val
            end
        end
    end
    file:close()
    return vars
end

-- 2. Helper function to resolve variable references (e.g. $var1 inside $var2)
local function resolve_vars(vars)
    local var_names = {}
    for k in pairs(vars) do
        table.insert(var_names, k)
    end
    table.sort(var_names, function(a, b) return #a > #b end)
    
    local function replace_var(raw_ref)
        local var_name = raw_ref:sub(2) -- strip $
        if vars[var_name] then
            return vars[var_name]
        end
        for _, name in ipairs(var_names) do
            if var_name:sub(1, #name) == name then
                local suffix = var_name:sub(#name + 1)
                local val = vars[name]
                if val ~= nil then
                    return tostring(val) .. suffix
                end
            end
        end
        return raw_ref
    end
    
    for k, v in pairs(vars) do
        if type(v) == "string" then
            local changed
            repeat
                local next_v = v:gsub("%$[%w_]+", replace_var)
                changed = (next_v ~= v)
                v = next_v
            until not changed
            vars[k] = v
        end
    end
    return vars
end

-- 3. Run startup/copy commands (equivalent to exec in main config)
os.execute("cp -L --no-preserve=mode --update=none " .. hypr_dir .. "/scheme/default.conf " .. hypr_dir .. "/scheme/current.conf")
os.execute(hypr_dir .. "/scripts/configs.fish " .. c_conf_dir)

-- 4. Load all configurations and variables
local vars = {}
local function merge_vars(new_vars)
    for k, v in pairs(new_vars) do
        vars[k] = v
    end
end

merge_vars(load_vars(hypr_dir .. "/scheme/current.conf"))
merge_vars(load_vars(hypr_dir .. "/variables.conf"))
merge_vars(load_vars(c_conf_dir .. "/hypr-vars.conf"))

resolve_vars(vars)

-- Create a metatable so that suffix concatenation like vars.primaryd4 is resolved dynamically
local var_names = {}
for k in pairs(vars) do
    table.insert(var_names, k)
end
table.sort(var_names, function(a, b) return #a > #b end)

setmetatable(vars, {
    __index = function(t, key)
        for _, name in ipairs(var_names) do
            if key:sub(1, #name) == name then
                local suffix = key:sub(#name + 1)
                local val = t[name]
                if val ~= nil then
                    return tostring(val) .. suffix
                end
            end
        end
        return nil
    end
})

_G.vars = vars

-- 5. Default monitor configuration
hl.monitor({
    output = "",
    mode = "preferred",
    position = "auto",
    scale = "1"
})

-- 6. Load Lua sub-modules
require("hyprland/env")
require("hyprland/general")
require("hyprland/input")
require("hyprland/misc")
require("hyprland/animations")
require("hyprland/decoration")
require("hyprland/group")
require("hyprland/execs")
require("hyprland/rules")
require("hyprland/gestures")
require("hyprland/scrolling")
require("hyprland/keybinds")

-- 7. Helper function to make bindings cleaner and fix lowercase/comma issues
local function clean_key_combo(keys_str)
    if not keys_str then return "" end
    -- Replace commas with plus
    keys_str = keys_str:gsub(",", " + ")
    
    -- Preserve keysyms containing mod names from being capitalized
    keys_str = keys_str:gsub("[Ss][Uu][Pp][Ee][Rr]_[Ll]", "__SUPER_L__")
    keys_str = keys_str:gsub("[Ss][Uu][Pp][Ee][Rr]_[Rr]", "__SUPER_R__")
    keys_str = keys_str:gsub("[Cc][Tt][Rr][Ll]_[Ll]", "__CTRL_L__")
    keys_str = keys_str:gsub("[Cc][Tt][Rr][Ll]_[Rr]", "__CTRL_R__")
    keys_str = keys_str:gsub("[Aa][Ll][Tt]_[Ll]", "__ALT_L__")
    keys_str = keys_str:gsub("[Aa][Ll][Tt]_[Rr]", "__ALT_R__")
    keys_str = keys_str:gsub("[Ss][Hh][Ii][Ff][Tt]_[Ll]", "__SHIFT_L__")
    keys_str = keys_str:gsub("[Ss][Hh][Ii][Ff][Tt]_[Rr]", "__SHIFT_R__")

    -- Normalize modifiers to uppercase
    keys_str = keys_str:gsub("ctrl", "CTRL"):gsub("Ctrl", "CTRL")
                       :gsub("alt", "ALT"):gsub("Alt", "ALT")
                       :gsub("super", "SUPER"):gsub("Super", "SUPER")
                       :gsub("shift", "SHIFT"):gsub("Shift", "SHIFT")
                       
    -- Restore preserved keysyms with correct case
    keys_str = keys_str:gsub("__SUPER_L__", "Super_L")
    keys_str = keys_str:gsub("__SUPER_R__", "Super_R")
    keys_str = keys_str:gsub("__CTRL_L__", "Control_L")
    keys_str = keys_str:gsub("__CTRL_R__", "Control_R")
    keys_str = keys_str:gsub("__ALT_L__", "Alt_L")
    keys_str = keys_str:gsub("__ALT_R__", "Alt_R")
    keys_str = keys_str:gsub("__SHIFT_L__", "Shift_L")
    keys_str = keys_str:gsub("__SHIFT_R__", "Shift_R")

    -- Normalize spacing around plusses
    keys_str = keys_str:gsub("%s*%+%s*", " + ")
    -- Clean up multiple spaces
    keys_str = keys_str:gsub("%s+", " ")
    keys_str = keys_str:gsub("^%s+", ""):gsub("%s+$", "")
    return keys_str
end
_G.clean_key_combo = clean_key_combo

-- 8. Helper function to parse legacy user configuration dynamically
local function parse_legacy_conf(filepath, vars)
    filepath = filepath:gsub("^~", home)
    local file = io.open(filepath, "r")
    if not file then return end
    
    local function replace_vars(str)
        return str:gsub("%$[%w_]+", function(raw_ref)
            local var_name = raw_ref:sub(2)
            if vars[var_name] then
                return vars[var_name]
            end
            for _, name in ipairs(var_names) do
                if var_name:sub(1, #name) == name then
                    local suffix = var_name:sub(#name + 1)
                    local val = vars[name]
                    if val ~= nil then
                        return tostring(val) .. suffix
                    end
                end
            end
            return raw_ref
        end)
    end
    
    for line in file:lines() do
        local clean_line = line:gsub("^%s+", ""):gsub("%s+$", "")
        if clean_line ~= "" and not clean_line:match("^#") then
            clean_line = replace_vars(clean_line)
            
            local rule_type, rule_val = clean_line:match("^([%w_]+)%s*=%s*(.+)$")
            if rule_type == "windowrule" then
                local prop, match_str = rule_val:match("^([^,]+),%s*match:(.+)$")
                if prop and match_str then
                    local match_type, match_pattern = match_str:match("^([%w_]+)%s+(.+)$")
                    if match_type and match_pattern then
                        local rule_table = { match = {} }
                        rule_table.match[match_type] = match_pattern
                        
                        local prop_name, prop_val = prop:match("^([%w_]+)%s*(.*)$")
                        if prop_name then
                            prop_val = prop_val:gsub("^%s+", ""):gsub("%s+$", "")
                            if prop_val == "" or prop_val == "1" or prop_val == "true" then
                                rule_table[prop_name] = true
                            elseif prop_val == "0" or prop_val == "false" then
                                rule_table[prop_name] = false
                            elseif prop_val:match("^%d+$") then
                                rule_table[prop_name] = tonumber(prop_val)
                            elseif prop_val:match("^%d+%s+%d+$") then
                                local w, h = prop_val:match("^(%d+)%s+(%d+)$")
                                rule_table[prop_name] = { tonumber(w), tonumber(h) }
                            else
                                rule_table[prop_name] = prop_val
                            end
                            hl.window_rule(rule_table)
                        end
                    end
                end
            elseif rule_type == "bind" or rule_type == "bindi" or rule_type == "binde" or rule_type == "bindl" or rule_type == "bindr" or rule_type == "bindm" then
                local parts = {}
                for part in rule_val:gmatch("[^,]+") do
                    table.insert(parts, (part:gsub("^%s+", ""):gsub("%s+$", "")))
                end
                if #parts >= 3 then
                    local mods = parts[1]
                    local key = parts[2]
                    local dispatcher = parts[3]
                    local args = {}
                    for i = 4, #parts do
                        table.insert(args, parts[i])
                    end
                    local arg_str = table.concat(args, ", ")
                    
                    local keys_str = mods ~= "" and (mods .. " + " .. key) or key
                    
                    local flags = {}
                    if rule_type == "bindi" then flags.ignore_mods = true end
                    if rule_type == "binde" then flags.repeating = true end
                    if rule_type == "bindl" then flags.locked = true end
                    if rule_type == "bindr" then flags.release = true end
                    if rule_type == "bindm" then flags.mouse = true end
                    
                    local dsp_fn
                    if dispatcher == "exec" or dispatcher == "exec-once" then
                        dsp_fn = hl.dsp.exec_cmd(arg_str)
                    else
                        dsp_fn = hl.dsp.exec_cmd("hyprctl dispatch " .. dispatcher .. " " .. arg_str)
                    end
                    hl.bind(clean_key_combo(keys_str), dsp_fn, flags)
                end
            end
        end
    end
    file:close()
end

-- 8. Dynamically parse legacy user configurations to support caelestia theme/user additions
hl.define_submap("global", function()
    parse_legacy_conf(c_conf_dir .. "/hypr-user.conf", vars)
end)
