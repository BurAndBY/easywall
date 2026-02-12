local waywall = require("waywall")
local helpers = require("waywall.helpers")
local remaps = require("remaps")

local home = os.getenv("HOME")
local root_path = home .. "/.config/waywall/"
local settings_path = root_path .. "settings.lua"
local default_settings_path = root_path .. "generic/advanced_gui/settings.lua"
local log_path = root_path .. "advanced_gui.log"
local ninbot_launcher_path = root_path .. "scripts/ninbot_launch.sh"
local ninbot_java_log_path = root_path .. "ninjabrain.log"

local default_settings_text = [[return {
  first_boot_complete = false,
  show_first_boot_tips = true,
  auto_open_settings_gui_on_first_boot = true,

  ui = {
    tips_duration_ms = 12000,
    tips_color = "#F2F0E9",
    tips_size = 2,
    tips_x = 48,
    tips_y = 52,
    tips_spacing = 42,
  },

  keys = {
    thin = "*-N",
    wide = "*-M",
    tall = "*-B",
    toggle_ninbot = "apostrophe",
    launch_paceman = "Shift-P",
    fullscreen = "Shift-O",
    toggle_remaps = "Insert",
    open_settings = "F8",
    reload_config = "F5",
    passthrough_action_keys = false,
  },

  input = {
    layout = "us",
    options = "caps:none",
    repeat_rate = 40,
    repeat_delay = 220,
    confine_pointer = true,
    sensitivity_normal = 3.0,
    sensitivity_tall = 0.2,
  },

  paths = {
    ninbot_jar = "resources/Ninjabrain-Bot-1.5.1.jar",
    paceman_jar = "resources/paceman-tracker-0.7.1.jar",
  },

  startup = {
    auto_launch_paceman = false,
  },

  mirrors = {
    entity_counter_enabled = true,
    entity_counter_colorkey = false,
    pie_chart_enabled = true,
    pie_chart_colorkey = false,
  },

  theme = {
    ninb_anchor = "topright",
    ninb_opacity = 1.0,
    background_png = "resources/background.png",
  },
}
]]

local function file_exists(path)
    local f = io.open(path, "r")
    if f then
        f:close()
        return true
    end
    return false
end

local function log(msg)
    local line = string.format("[%s] %s\n", os.date("%Y-%m-%d %H:%M:%S"), tostring(msg))
    local f = io.open(log_path, "a")
    if f then
        f:write(line)
        f:close()
    end
    print("[waywall-advanced] " .. tostring(msg))
end

local function ensure_default_settings_file()
    local out
    if file_exists(settings_path) then
        log("settings.lua exists; using existing file")
        return
    end

    if file_exists(default_settings_path) then
        local src = io.open(default_settings_path, "r")
        if src then
            local data = src:read("*a")
            src:close()
            out = io.open(settings_path, "w")
            if out then
                out:write(data)
                out:close()
                log("settings.lua created from default_settings_path")
                return
            end
        end
    end

    out = io.open(settings_path, "w")
    if out then
        out:write(default_settings_text)
        out:close()
        log("settings.lua created from built-in defaults")
    end
end

local function load_settings()
    ensure_default_settings_file()
    local ok, data = pcall(dofile, settings_path)
    if not ok or type(data) ~= "table" then
        log("failed to load settings.lua")
        return nil
    end
    log("settings.lua loaded successfully")
    return data
end

local function ensure_settings_defaults(s)
    s.ui = s.ui or {}
    s.keys = s.keys or {}
    s.input = s.input or {}
    s.paths = s.paths or {}
    s.startup = s.startup or {}
    s.theme = s.theme or {}
    s.mirrors = s.mirrors or {}

    s.first_boot_complete = (s.first_boot_complete == true)
    if s.show_first_boot_tips == nil then s.show_first_boot_tips = true end
    if s.auto_open_settings_gui_on_first_boot == nil then s.auto_open_settings_gui_on_first_boot = true end

    if s.ui.tips_duration_ms == nil then s.ui.tips_duration_ms = 12000 end
    if s.ui.tips_color == nil then s.ui.tips_color = "#F2F0E9" end
    if s.ui.tips_size == nil then s.ui.tips_size = 2 end
    if s.ui.tips_x == nil then s.ui.tips_x = 48 end
    if s.ui.tips_y == nil then s.ui.tips_y = 52 end
    if s.ui.tips_spacing == nil then s.ui.tips_spacing = 42 end

    if s.keys.thin == nil then s.keys.thin = "*-N" end
    if s.keys.wide == nil then s.keys.wide = "*-M" end
    if s.keys.tall == nil then s.keys.tall = "*-B" end
    if s.keys.toggle_ninbot == nil then s.keys.toggle_ninbot = "apostrophe" end
    if s.keys.launch_paceman == nil then s.keys.launch_paceman = "Shift-P" end
    if s.keys.fullscreen == nil then s.keys.fullscreen = "Shift-O" end
    if s.keys.toggle_remaps == nil then s.keys.toggle_remaps = "Insert" end
    if s.keys.open_settings == nil then s.keys.open_settings = "F8" end
    if s.keys.reload_config == nil then s.keys.reload_config = "F5" end
    if s.keys.passthrough_action_keys == nil then s.keys.passthrough_action_keys = false end

    if s.input.layout == nil then s.input.layout = "us" end
    if s.input.options == nil then s.input.options = "caps:none" end
    if s.input.repeat_rate == nil then s.input.repeat_rate = 40 end
    if s.input.repeat_delay == nil then s.input.repeat_delay = 220 end
    if s.input.confine_pointer == nil then s.input.confine_pointer = true end
    if s.input.sensitivity_normal == nil then s.input.sensitivity_normal = 3.0 end
    if s.input.sensitivity_tall == nil then s.input.sensitivity_tall = 0.2 end

    if s.paths.ninbot_jar == nil then s.paths.ninbot_jar = "resources/Ninjabrain-Bot-1.5.1.jar" end
    if s.paths.paceman_jar == nil then s.paths.paceman_jar = "resources/paceman-tracker-0.7.1.jar" end

    if s.startup.auto_launch_paceman == nil then s.startup.auto_launch_paceman = false end

    if s.mirrors.entity_counter_enabled == nil then s.mirrors.entity_counter_enabled = true end
    if s.mirrors.entity_counter_colorkey == nil then s.mirrors.entity_counter_colorkey = false end
    if s.mirrors.pie_chart_enabled == nil then s.mirrors.pie_chart_enabled = true end
    if s.mirrors.pie_chart_colorkey == nil then s.mirrors.pie_chart_colorkey = false end

    if s.theme.ninb_anchor == nil then s.theme.ninb_anchor = "topright" end
    if s.theme.ninb_opacity == nil then s.theme.ninb_opacity = 1.0 end
    if s.theme.background_png == nil then s.theme.background_png = "resources/background.png" end
end

local function lua_quote(v)
    return string.format("%q", tostring(v))
end

local function write_settings(settings)
    local lines = {
        "return {",
        "  first_boot_complete = " .. tostring(settings.first_boot_complete) .. ",",
        "  show_first_boot_tips = " .. tostring(settings.show_first_boot_tips) .. ",",
        "  auto_open_settings_gui_on_first_boot = " .. tostring(settings.auto_open_settings_gui_on_first_boot) .. ",",
        "",
        "  ui = {",
        "    tips_duration_ms = " .. tonumber(settings.ui.tips_duration_ms) .. ",",
        "    tips_color = " .. lua_quote(settings.ui.tips_color) .. ",",
        "    tips_size = " .. tonumber(settings.ui.tips_size) .. ",",
        "    tips_x = " .. tonumber(settings.ui.tips_x) .. ",",
        "    tips_y = " .. tonumber(settings.ui.tips_y) .. ",",
        "    tips_spacing = " .. tonumber(settings.ui.tips_spacing) .. ",",
        "  },",
        "",
        "  keys = {",
        "    thin = " .. lua_quote(settings.keys.thin) .. ",",
        "    wide = " .. lua_quote(settings.keys.wide) .. ",",
        "    tall = " .. lua_quote(settings.keys.tall) .. ",",
        "    toggle_ninbot = " .. lua_quote(settings.keys.toggle_ninbot) .. ",",
        "    launch_paceman = " .. lua_quote(settings.keys.launch_paceman) .. ",",
        "    fullscreen = " .. lua_quote(settings.keys.fullscreen) .. ",",
        "    toggle_remaps = " .. lua_quote(settings.keys.toggle_remaps) .. ",",
        "    open_settings = " .. lua_quote(settings.keys.open_settings) .. ",",
        "    reload_config = " .. lua_quote(settings.keys.reload_config) .. ",",
        "    passthrough_action_keys = " .. tostring(settings.keys.passthrough_action_keys) .. ",",
        "  },",
        "",
        "  input = {",
        "    layout = " .. lua_quote(settings.input.layout) .. ",",
        "    options = " .. lua_quote(settings.input.options) .. ",",
        "    repeat_rate = " .. tonumber(settings.input.repeat_rate) .. ",",
        "    repeat_delay = " .. tonumber(settings.input.repeat_delay) .. ",",
        "    confine_pointer = " .. tostring(settings.input.confine_pointer) .. ",",
        "    sensitivity_normal = " .. tonumber(settings.input.sensitivity_normal) .. ",",
        "    sensitivity_tall = " .. tonumber(settings.input.sensitivity_tall) .. ",",
        "  },",
        "",
        "  paths = {",
        "    ninbot_jar = " .. lua_quote(settings.paths.ninbot_jar) .. ",",
        "    paceman_jar = " .. lua_quote(settings.paths.paceman_jar) .. ",",
        "  },",
        "",
        "  startup = {",
        "    auto_launch_paceman = " .. tostring(settings.startup.auto_launch_paceman) .. ",",
        "  },",
        "",
        "  mirrors = {",
        "    entity_counter_enabled = " .. tostring(settings.mirrors.entity_counter_enabled) .. ",",
        "    entity_counter_colorkey = " .. tostring(settings.mirrors.entity_counter_colorkey) .. ",",
        "    pie_chart_enabled = " .. tostring(settings.mirrors.pie_chart_enabled) .. ",",
        "    pie_chart_colorkey = " .. tostring(settings.mirrors.pie_chart_colorkey) .. ",",
        "  },",
        "",
        "  theme = {",
        "    ninb_anchor = " .. lua_quote(settings.theme.ninb_anchor) .. ",",
        "    ninb_opacity = " .. tonumber(settings.theme.ninb_opacity) .. ",",
        "    background_png = " .. lua_quote(settings.theme.background_png) .. ",",
        "  },",
        "}",
        "",
    }

    local out = io.open(settings_path, "w")
    if out then
        out:write(table.concat(lines, "\n"))
        out:close()
        log("settings.lua written")
        return true
    end
    log("failed to write settings.lua")
    return false
end

local settings = load_settings()
if not settings then
    error("Failed to load settings from " .. settings_path)
end
ensure_settings_defaults(settings)

local config_path = root_path
local ninbot_path = config_path .. settings.paths.ninbot_jar
local paceman_path = config_path .. settings.paths.paceman_jar
local background_path = config_path .. settings.theme.background_png
local settings_underlay_path = config_path .. "resources/settings_underlay.png"
local measuring_overlay_path = config_path .. "resources/measuring_overlay.png"

local remaps_active = true
local remaps_text = nil

local ui_open = false
local ui_objects = {}
local ui_status = ""
local ui_selected = 1
local ui_scroll = 1
local ui_visible_rows = 11
local ui_group_index = 1
local key_edit_mode = false
local key_edit_field = nil
local key_edit_value = nil
local key_capture_waiting = false
local ui_dirty = false
local mirror_objects = {}
local render_settings_ui
local hold_repeat_initial_ms = 230
local hold_repeat_step_ms = 45
local ninbot_last_toggle_ms = 0
local ninbot_toggle_cooldown_ms = 1200

local function is_running(pattern)
    local h = io.popen("pgrep -f '" .. pattern .. "'")
    if not h then
        return false
    end
    local pid = h:read("*l")
    h:close()
    return pid ~= nil
end

local function launch_paceman()
    log("launch_paceman requested")
    if not is_running("paceman..*") then
        waywall.exec("java -jar " .. paceman_path .. " --nogui")
        log("paceman started")
    else
        log("paceman already running")
    end
end

local function toggle_ninb()
    log("toggle_ninb requested")
    local now = waywall.current_time()
    if now - ninbot_last_toggle_ms < ninbot_toggle_cooldown_ms then
        log("toggle_ninb ignored (cooldown)")
        return
    end
    ninbot_last_toggle_ms = now

    if is_running("[Nn]injabrain.*jar") then
        helpers.toggle_floating()
        log("ninjabrain floating toggled")
        return
    end

    if not file_exists(ninbot_path) then
        log("ninjabrain launch failed: jar not found at " .. ninbot_path)
        return
    end

    if file_exists(ninbot_launcher_path) then
        waywall.exec("sh " .. ninbot_launcher_path .. " " .. ninbot_path .. " " .. ninbot_java_log_path)
        log("ninjabrain launcher script invoked")
    else
        waywall.exec("java -jar " .. ninbot_path)
        log("ninjabrain direct launch invoked")
    end

    waywall.sleep(300)
    if is_running("[Nn]injabrain.*jar") then
        waywall.show_floating(true)
        log("ninjabrain detected after launch; floating shown")
    else
        log("ninjabrain not detected after launch; check " .. ninbot_java_log_path)
    end
end

local function bind_to_keycode(bind)
    if not bind or bind == "" then
        return nil
    end
    local key = tostring(bind):match("([^%-]+)$") or tostring(bind)
    key = key:gsub("^%s+", ""):gsub("%s+$", "")
    if key == "" or key == "*" then
        return nil
    end
    if #key == 1 then
        key = key:upper()
    end
    return key
end

local function should_passthrough_bind(bind)
    if not settings.keys.passthrough_action_keys then
        return false
    end
    local keycode = bind_to_keycode(bind)
    if not keycode then
        return false
    end
    log("action passthrough enabled (return false): bind=" .. tostring(bind) .. " keycode=" .. tostring(keycode))
    return true
end

local function passthrough_to_minecraft(bind)
    if not settings.keys.passthrough_action_keys then
        return
    end
    local keycode = bind_to_keycode(bind)
    if not keycode then
        return
    end
    waywall.press_key(keycode)
    log("action passthrough sent to minecraft: bind=" .. tostring(bind) .. " keycode=" .. tostring(keycode))
end

local function clear_ui_objects()
    for _, obj in ipairs(ui_objects) do
        obj:close()
    end
    ui_objects = {}
end

local function clear_mirror_objects()
    for _, obj in ipairs(mirror_objects) do
        obj:close()
    end
    mirror_objects = {}
end

local function create_mirror(options)
    local obj = waywall.mirror(options)
    table.insert(mirror_objects, obj)
end

local function create_image(path, options)
    local obj = waywall.image(path, options)
    table.insert(mirror_objects, obj)
end

local function apply_mirror_settings()
    clear_mirror_objects()

    local w, h = waywall.active_res()
    local is_tall = (w == 384 and h == 16384)
    local is_thin = (w == 350 and h == 1100)
    local is_wide = (w == 2560 and h == 400)
    local is_game_res = (is_thin or is_tall or is_wide)
    local use_tall = is_tall
    local use_thin_like = (is_thin or is_wide)

    if settings.mirrors.entity_counter_enabled and is_game_res then
        local src = use_tall and { x = 45, y = 15998, w = 37, h = 9 } or { x = 13, y = 37, w = 37, h = 9 }
        create_mirror({
            src = src,
            dst = { x = 1500, y = 400, w = 37 * 5, h = 9 * 5 },
            color_key = settings.mirrors.entity_counter_colorkey and {
                input = "#dddddd",
                output = "#ec6e4e",
            } or nil,
            depth = 2,
        })
    end

    if settings.mirrors.pie_chart_enabled and is_game_res then
        local src_all
        local src_layers
        if use_tall then
            src_all = { x = 44, y = 15978, w = 340, h = 221 }
            src_layers = { x = 44, y = 15978, w = 340, h = 178 }
        elseif use_thin_like then
            src_all = { x = 10, y = 694, w = 340, h = 221 }
            src_layers = { x = 10, y = 694, w = 340, h = 178 }
        else
            src_all = { x = 0, y = 674, w = 340, h = 221 }
            src_layers = { x = 0, y = 674, w = 340, h = 178 }
        end

        if settings.mirrors.pie_chart_colorkey then
            -- Match generic behavior: layered pie mirrors with 3 separate colorkeys.
            create_mirror({
                src = src_layers,
                dst = { x = 1490, y = 645, w = 420, h = 423 },
                color_key = { input = "#E446C4", output = "#E446C4" },
                depth = 2,
            })
            create_mirror({
                src = src_layers,
                dst = { x = 1490, y = 645, w = 420, h = 423 },
                color_key = { input = "#46CE66", output = "#46CE66" },
                depth = 2,
            })
            create_mirror({
                src = src_layers,
                dst = { x = 1490, y = 645, w = 420, h = 423 },
                color_key = { input = "#ec6e4e", output = "#ec6e4e" },
                depth = 2,
            })
        else
            create_mirror({
                src = src_all,
                dst = { x = 1490, y = 645, w = 420, h = 273 },
                depth = 2,
            })
        end
    end

    -- Tall-only eye measuring overlay (mirror + optional PNG frame).
    if is_tall then
        create_mirror({
            src = { x = 177, y = 7902, w = 30, h = 580 },
            dst = { x = 94, y = 470, w = 900, h = 500 },
            depth = 2,
        })
        if file_exists(measuring_overlay_path) then
            create_image(measuring_overlay_path, {
                dst = { x = 94, y = 470, w = 900, h = 500 },
                depth = 3,
            })
        end
    end

    log(string.format(
        "mirrors applied: entity=%s entity_ck=%s pie=%s pie_ck=%s measure=%s res=%dx%d",
        tostring(settings.mirrors.entity_counter_enabled),
        tostring(settings.mirrors.entity_counter_colorkey),
        tostring(settings.mirrors.pie_chart_enabled),
        tostring(settings.mirrors.pie_chart_colorkey),
        tostring(is_tall),
        w, h
    ))
end

local function clamp(n, minv, maxv)
    if n < minv then
        return minv
    end
    if n > maxv then
        return maxv
    end
    return n
end

local function cycle_choice(options, value, dir)
    local idx = 1
    for i, option in ipairs(options) do
        if option == value then
            idx = i
            break
        end
    end
    idx = idx + dir
    if idx < 1 then
        idx = #options
    elseif idx > #options then
        idx = 1
    end
    return options[idx]
end

local key_choices = {
    "*-N", "*-M", "*-B", "apostrophe", "Shift-P", "Shift-O", "Insert", "F8", "F5", "F6", "F7",
}

local anchor_choices = {
    "topleft", "top", "topright", "left", "right", "bottomleft", "bottom", "bottomright",
}

local function get_layout_choices(current)
    local list = {}
    local seen = {}
    local function prepend_layout(name)
        if not name or name == "" then
            return
        end
        if seen[name] then
            for i, v in ipairs(list) do
                if v == name then
                    table.remove(list, i)
                    break
                end
            end
        end
        seen[name] = true
        table.insert(list, 1, name)
    end
    local function add_layout(name)
        if name and name ~= "" and not seen[name] then
            seen[name] = true
            table.insert(list, name)
        end
    end

    local h = io.popen("localectl list-x11-keymap-layouts 2>/dev/null")
    if h then
        for line in h:lines() do
            local name = line:gsub("^%s+", ""):gsub("%s+$", "")
            add_layout(name)
        end
        h:close()
    end

    if #list == 0 then
        list = { "us", "de", "fr", "ru", "mc" }
        seen = { us = true, de = true, fr = true, ru = true, mc = true }
    end

    -- Include custom symbol-file layouts not reported by localectl.
    for _, p in ipairs({
        "/usr/share/X11/xkb/symbols/mc",
        "/etc/X11/xkb/symbols/mc",
    }) do
        if file_exists(p) then
            prepend_layout("mc")
            break
        end
    end

    if current and current ~= "" then
        prepend_layout(current)
    end

    return list
end

local layout_choices = get_layout_choices(settings.input.layout)
do
    local has_mc = false
    local preview = {}
    local max_preview = math.min(#layout_choices, 8)
    for i = 1, #layout_choices do
        if layout_choices[i] == "mc" then
            has_mc = true
        end
        if i <= max_preview then
            table.insert(preview, layout_choices[i])
        end
    end
    log("layout choices loaded count=" .. tostring(#layout_choices) .. " has_mc=" .. tostring(has_mc) .. " preview=" .. table.concat(preview, ","))
end

local groups = {
    "Keys",
    "Input",
    "Mirrors",
    "Theme",
    "Startup",
}

local fields = {
    { group = "Keys", label = "Open Settings Key", kind = "choice", get = function() return settings.keys.open_settings end, set = function(v) settings.keys.open_settings = v end, choices = key_choices },
    { group = "Keys", label = "Reload Config Key", kind = "choice", get = function() return settings.keys.reload_config end, set = function(v) settings.keys.reload_config = v end, choices = key_choices },
    { group = "Keys", label = "Toggle Ninjabrain Key", kind = "choice", get = function() return settings.keys.toggle_ninbot end, set = function(v) settings.keys.toggle_ninbot = v end, choices = key_choices },
    { group = "Keys", label = "Launch Paceman Key", kind = "choice", get = function() return settings.keys.launch_paceman end, set = function(v) settings.keys.launch_paceman = v end, choices = key_choices },
    { group = "Keys", label = "Thin Resolution Key", kind = "choice", get = function() return settings.keys.thin end, set = function(v) settings.keys.thin = v end, choices = key_choices },
    { group = "Keys", label = "Wide Resolution Key", kind = "choice", get = function() return settings.keys.wide end, set = function(v) settings.keys.wide = v end, choices = key_choices },
    { group = "Keys", label = "Tall Resolution Key", kind = "choice", get = function() return settings.keys.tall end, set = function(v) settings.keys.tall = v end, choices = key_choices },
    { group = "Keys", label = "Fullscreen Key", kind = "choice", get = function() return settings.keys.fullscreen end, set = function(v) settings.keys.fullscreen = v end, choices = key_choices },
    { group = "Keys", label = "Toggle Remaps Key", kind = "choice", get = function() return settings.keys.toggle_remaps end, set = function(v) settings.keys.toggle_remaps = v end, choices = key_choices },
    { group = "Keys", label = "Action Key Passthrough", kind = "bool", get = function() return settings.keys.passthrough_action_keys end, set = function(v) settings.keys.passthrough_action_keys = v end },

    { group = "Input", label = "Keyboard Layout", kind = "choice", get = function() return settings.input.layout end, set = function(v) settings.input.layout = v end, choices = layout_choices },
    { group = "Input", label = "Repeat Rate", kind = "number", get = function() return settings.input.repeat_rate end, set = function(v) settings.input.repeat_rate = clamp(v, 10, 80) end, step = 1 },
    { group = "Input", label = "Repeat Delay", kind = "number", get = function() return settings.input.repeat_delay end, set = function(v) settings.input.repeat_delay = clamp(v, 50, 900) end, step = 10 },
    { group = "Input", label = "Sensitivity Normal", kind = "number", get = function() return settings.input.sensitivity_normal end, set = function(v) settings.input.sensitivity_normal = clamp(v, 0.1, 20.0) end, step = 0.1 },
    { group = "Input", label = "Sensitivity Tall", kind = "number", get = function() return settings.input.sensitivity_tall end, set = function(v) settings.input.sensitivity_tall = clamp(v, 0.01, 10.0) end, step = 0.05 },
    { group = "Input", label = "Confine Pointer", kind = "bool", get = function() return settings.input.confine_pointer end, set = function(v) settings.input.confine_pointer = v end },

    { group = "Mirrors", label = "Entity Counter Enabled", kind = "bool", get = function() return settings.mirrors.entity_counter_enabled end, set = function(v) settings.mirrors.entity_counter_enabled = v end },
    { group = "Mirrors", label = "Entity Counter Colorkey", kind = "bool", get = function() return settings.mirrors.entity_counter_colorkey end, set = function(v) settings.mirrors.entity_counter_colorkey = v end },
    { group = "Mirrors", label = "Pie Chart Enabled", kind = "bool", get = function() return settings.mirrors.pie_chart_enabled end, set = function(v) settings.mirrors.pie_chart_enabled = v end },
    { group = "Mirrors", label = "Pie Chart Colorkey", kind = "bool", get = function() return settings.mirrors.pie_chart_colorkey end, set = function(v) settings.mirrors.pie_chart_colorkey = v end },

    { group = "Theme", label = "Ninb Anchor", kind = "choice", get = function() return settings.theme.ninb_anchor end, set = function(v) settings.theme.ninb_anchor = v end, choices = anchor_choices },
    { group = "Theme", label = "Ninb Opacity", kind = "number", get = function() return settings.theme.ninb_opacity end, set = function(v) settings.theme.ninb_opacity = clamp(v, 0.1, 1.0) end, step = 0.05 },

    { group = "Startup", label = "Auto Launch Paceman", kind = "bool", get = function() return settings.startup.auto_launch_paceman end, set = function(v) settings.startup.auto_launch_paceman = v end },
    { group = "Startup", label = "Show First Boot Tips", kind = "bool", get = function() return settings.show_first_boot_tips end, set = function(v) settings.show_first_boot_tips = v end },
    { group = "Startup", label = "Auto Open Settings on First Boot", kind = "bool", get = function() return settings.auto_open_settings_gui_on_first_boot end, set = function(v) settings.auto_open_settings_gui_on_first_boot = v end },
}

local function fields_in_group(group_name)
    local ids = {}
    for i, field in ipairs(fields) do
        if field.group == group_name then
            table.insert(ids, i)
        end
    end
    return ids
end

local function selected_group_name()
    return groups[ui_group_index]
end

local function mark_dirty(reason)
    ui_dirty = true
    log("staged change: " .. tostring(reason))
end

local function is_key_field(field)
    return field and field.group == "Keys" and field.kind == "choice"
end

local function finish_key_edit(saved, message)
    if saved then
        mark_dirty("keybind edit")
    end
    key_edit_mode = false
    key_edit_field = nil
    key_edit_value = nil
    key_capture_waiting = false
    ui_status = message
end

local function try_capture_key(key_name)
    if not key_edit_mode or not key_capture_waiting or not key_edit_field then
        return false
    end
    if key_name == "Escape" then
        return false
    end

    local blocked = {
        Return = true,
        Up = true,
        Down = true,
        Left = true,
        Right = true,
        Tab = true,
        Shift_Tab = true,
        ["Shift-Tab"] = true,
        ISO_Left_Tab = true,
        Prior = true,
        Next = true,
        Page_Up = true,
        Page_Down = true,
    }
    if blocked[key_name] then
        ui_status = "Press the key you want to bind (Esc cancels)."
        log("capture ignored blocked key: " .. key_name)
        render_settings_ui()
        return true
    end

    local field = fields[key_edit_field]
    if not field then
        finish_key_edit(false, "Key edit canceled.")
        return true
    end
    field.set(key_name)
    log("captured key for " .. field.label .. ": " .. key_name)
    finish_key_edit(true, "Saved keybind: " .. field.label .. " -> " .. key_name)
    render_settings_ui()
    return true
end

local function fmt_field_value(field, field_id)
    if key_edit_mode and key_edit_field == field_id then
        if key_capture_waiting then
            return tostring(key_edit_value) .. " (press key...)"
        end
        return tostring(key_edit_value) .. " (pending)"
    end
    local value = field.get()
    if field.kind == "bool" then
        return value and "ON" or "OFF"
    end
    if field.kind == "number" then
        if math.abs(value - math.floor(value)) < 0.001 then
            return tostring(math.floor(value))
        end
        return string.format("%.2f", value)
    end
    return tostring(value)
end

render_settings_ui = function()
    if not ui_open then
        return
    end

    clear_ui_objects()

    local res_w, res_h = waywall.active_res()
    if res_w <= 0 or res_h <= 0 then
        res_w, res_h = 2560, 1440
    end
    local panel_w, panel_h = 1330, 700
    local panel_x = math.floor((res_w - panel_w) / 2)
    local panel_y = math.floor((res_h - panel_h) / 2)
    if panel_x < 0 then panel_x = 0 end
    if panel_y < 0 then panel_y = 0 end

    local text_x = panel_x + 20
    local title_y = panel_y + 25
    local help1_y = panel_y + 65
    local help2_y = panel_y + 95
    local group_y = panel_y + 140
    local rows_start_y = group_y + 31
    local footer_y = panel_y + panel_h - 170
    local dirty_y = panel_y + panel_h - 130
    local status_y = panel_y + panel_h - 100

    if file_exists(settings_underlay_path) then
        table.insert(ui_objects, waywall.image(settings_underlay_path, {
            dst = { x = panel_x, y = panel_y, w = panel_w, h = panel_h },
            depth = 110,
        }))
    end

    table.insert(ui_objects, waywall.text("easyWall", {
        x = text_x, y = title_y, color = "#F1F0E8", size = 3, depth = 120,
    }))
    table.insert(ui_objects, waywall.text("UP/DOWN: scroll  LEFT/RIGHT: change  TAB: next group  " .. settings.keys.open_settings .. "/ESC: close", {
        x = text_x, y = help1_y, color = "#C8C4BA", size = 2, depth = 120,
    }))
    table.insert(ui_objects, waywall.text("Changes are staged and saved when you close this menu.", {
        x = text_x, y = help2_y, color = "#A9D7B7", size = 2, depth = 120,
    }))

    local visible = fields_in_group(selected_group_name())
    local start = ui_scroll
    local stop = math.min(#visible, ui_scroll + ui_visible_rows - 1)
    local y = group_y

    table.insert(ui_objects, waywall.text("Group: " .. selected_group_name(), {
        x = text_x + 10, y = y, color = "#87D7FF", size = 2, depth = 120,
    }))
    y = rows_start_y

    for i = start, stop do
        local field_id = visible[i]
        local field = fields[field_id]
        local prefix = (field_id == ui_selected) and "> " or "  "
        if key_edit_mode and key_edit_field == field_id then
            prefix = "* "
        end
        local color = (field_id == ui_selected) and "#F7D27A" or "#D7D3C8"
        local line = string.format("%s%s: %s", prefix, field.label, fmt_field_value(field, field_id))
        table.insert(ui_objects, waywall.text(line, {
            x = text_x + 10, y = y, color = color, size = 2, depth = 120,
        }))
        y = y + 31
    end

    local scroll_text = string.format("%d-%d / %d", start, stop, #visible)
    table.insert(ui_objects, waywall.text("Scroll: " .. scroll_text, {
        x = text_x + 10, y = footer_y, color = "#B8B4AB", size = 2, depth = 120,
    }))

    if ui_dirty then
        table.insert(ui_objects, waywall.text("Pending unsaved changes", {
            x = text_x + 10, y = dirty_y, color = "#F5B56D", size = 2, depth = 120,
        }))
    end

    if ui_status ~= "" then
        table.insert(ui_objects, waywall.text(ui_status, {
            x = text_x + 10, y = status_y, color = "#96E3AF", size = 2, depth = 120,
        }))
    end
end

local function adjust_selection(dir)
    local visible = fields_in_group(selected_group_name())
    if #visible == 0 then
        return
    end

    local pos = 1
    for i, field_id in ipairs(visible) do
        if field_id == ui_selected then
            pos = i
            break
        end
    end

    pos = clamp(pos + dir, 1, #visible)
    ui_selected = visible[pos]
    if key_edit_mode and key_edit_field ~= ui_selected then
        finish_key_edit(false, "Key edit canceled.")
    end

    if pos < ui_scroll then
        ui_scroll = pos
    elseif pos > ui_scroll + ui_visible_rows - 1 then
        ui_scroll = pos - ui_visible_rows + 1
    end
end

local function modify_selected(dir)
    local field = fields[ui_selected]
    if not field then
        return
    end

    if is_key_field(field) and not key_edit_mode then
        key_edit_mode = true
        key_edit_field = ui_selected
        key_edit_value = tostring(field.get())
        key_capture_waiting = true
        ui_status = "Press the key you want to set now. Esc to cancel."
        log("ui key capture started from left/right: " .. tostring(field.label))
        return
    end

    if key_edit_mode and key_edit_field == ui_selected and is_key_field(field) then
        ui_status = "Press the key you want to bind (Esc cancels)."
        return
    end

    if field.kind == "bool" then
        field.set(not field.get())
        mark_dirty(field.label)
    elseif field.kind == "number" then
        field.set(field.get() + (field.step * dir))
        mark_dirty(field.label)
    elseif field.kind == "choice" then
        local next_value = cycle_choice(field.choices, field.get(), dir)
        field.set(next_value)
        mark_dirty(field.label .. ": " .. tostring(next_value))
        if field.label == "Keyboard Layout" then
            ui_status = "Layout saved: " .. settings.input.layout .. ". Reload with " .. settings.keys.reload_config
        end
    end

    if field.label ~= "Keyboard Layout" then
        ui_status = "Changed. Close menu to save. Reload with " .. settings.keys.reload_config .. " to apply key/input changes."
    end

    if field.group == "Mirrors" then
        apply_mirror_settings()
    end
end

local function open_settings_gui()
    local current_group = fields[ui_selected] and fields[ui_selected].group or groups[1]
    for i, name in ipairs(groups) do
        if name == current_group then
            ui_group_index = i
            break
        end
    end
    ui_scroll = 1
    ui_open = true
    ui_status = ""
    log("settings menu opened")
    render_settings_ui()
end

local function close_settings_gui()
    if ui_dirty then
        local ok = write_settings(settings)
        if ok then
            log("settings menu closed; staged changes saved")
        else
            log("settings menu closed; failed to save staged changes")
        end
    else
        log("settings menu closed; no staged changes")
    end
    ui_open = false
    ui_dirty = false
    ui_status = ""
    clear_ui_objects()
end

local function toggle_settings_gui()
    if ui_open then
        log("toggle settings menu: close")
        close_settings_gui()
    else
        log("toggle settings menu: open")
        open_settings_gui()
    end
end

local function settings_nav_up()
    if not ui_open then
        return false
    end
    adjust_selection(-1)
    log("ui nav up; selected=" .. tostring(ui_selected))
    render_settings_ui()
end

local function settings_nav_down()
    if not ui_open then
        return false
    end
    adjust_selection(1)
    log("ui nav down; selected=" .. tostring(ui_selected))
    render_settings_ui()
end

local function settings_nav_page_up()
    if not ui_open then
        return false
    end
    adjust_selection(-ui_visible_rows)
    render_settings_ui()
end

local function settings_nav_page_down()
    if not ui_open then
        return false
    end
    adjust_selection(ui_visible_rows)
    render_settings_ui()
end

local function settings_dec()
    if not ui_open then
        return false
    end
    if key_edit_mode and key_edit_field ~= ui_selected then
        return false
    end
    modify_selected(-1)
    log("ui change left on field=" .. tostring(ui_selected))
    render_settings_ui()
end

local function settings_inc()
    if not ui_open then
        return false
    end
    if key_edit_mode and key_edit_field ~= ui_selected then
        return false
    end
    modify_selected(1)
    log("ui change right on field=" .. tostring(ui_selected))
    render_settings_ui()
end

local function repeat_while_held(keycode_name, cb)
    if not ui_open then
        return
    end
    waywall.sleep(hold_repeat_initial_ms)
    while ui_open and waywall.get_key(keycode_name) do
        if key_edit_mode and key_capture_waiting then
            break
        end
        cb()
        waywall.sleep(hold_repeat_step_ms)
    end
end

local function settings_toggle()
    if not ui_open then
        return false
    end
    local field = fields[ui_selected]
    if is_key_field(field) then
        if key_edit_mode and key_edit_field == ui_selected then
            ui_status = "Press the key you want to bind (Esc cancels)."
            log("ui key field waiting for capture: " .. tostring(field.label))
        else
            key_edit_mode = true
            key_edit_field = ui_selected
            key_edit_value = tostring(field.get())
            key_capture_waiting = true
            ui_status = "Press the key you want to set now. Esc to cancel."
            log("ui key capture started: " .. tostring(field.label))
        end
    else
        modify_selected(1)
        log("ui enter/toggle on non-key field: " .. tostring(field.label))
    end
    render_settings_ui()
end

local function settings_close_key()
    if not ui_open then
        return false
    end
    if key_edit_mode then
        finish_key_edit(false, "Key edit canceled.")
        log("key edit canceled with Escape")
        render_settings_ui()
        return
    end
    close_settings_gui()
end

local function select_group(dir)
    ui_group_index = ui_group_index + dir
    if ui_group_index < 1 then
        ui_group_index = #groups
    elseif ui_group_index > #groups then
        ui_group_index = 1
    end

    local visible = fields_in_group(selected_group_name())
    if #visible > 0 then
        ui_selected = visible[1]
    end
    ui_scroll = 1
end

local function settings_next_group()
    if not ui_open then
        return false
    end
    if key_edit_mode then
        ui_status = "Finish key capture first (Esc cancels)."
        render_settings_ui()
        return false
    end
    select_group(1)
    render_settings_ui()
end

local function settings_prev_group()
    if not ui_open then
        return false
    end
    if key_edit_mode then
        ui_status = "Finish key capture first (Esc cancels)."
        render_settings_ui()
        return false
    end
    select_group(-1)
    render_settings_ui()
end

local function show_first_boot_tips()
    if settings.first_boot_complete or not settings.show_first_boot_tips then
        return
    end

    local ui = settings.ui
    local lines = {
        "Welcome to easyWall!",
        "Open Ninjabrain Bot: " .. settings.keys.toggle_ninbot,
        "Open settings panel: " .. settings.keys.open_settings,
        "Reload after changes: " .. settings.keys.reload_config,
    }

    local objects = {}
    local y = ui.tips_y
    for _, line in ipairs(lines) do
        local text = waywall.text(line, {
            x = ui.tips_x,
            y = y,
            color = ui.tips_color,
            size = ui.tips_size,
            depth = 99,
        })
        table.insert(objects, text)
        y = y + ui.tips_spacing
    end

    settings.first_boot_complete = true
    write_settings(settings)
    log("first boot tips shown; first_boot_complete set true")

    if settings.auto_open_settings_gui_on_first_boot then
        open_settings_gui()
    end

    waywall.sleep(tonumber(ui.tips_duration_ms) or 12000)
    for _, obj in ipairs(objects) do
        obj:close()
    end
end

local config = {
    input = {
        layout = settings.input.layout,
        options = settings.input.options,
        repeat_rate = settings.input.repeat_rate,
        repeat_delay = settings.input.repeat_delay,
        remaps = remaps.enabled,
        confine_pointer = settings.input.confine_pointer,
        sensitivity = settings.input.sensitivity_normal,
    },
    theme = {
        background_png = background_path,
        ninb_anchor = settings.theme.ninb_anchor,
        ninb_opacity = settings.theme.ninb_opacity,
    },
    experimental = {
        debug = false,
        jit = true,
        tearing = false,
        scene_add_text = true,
    },
}

local resolutions = {
    thin = helpers.toggle_res(350, 1100, settings.input.sensitivity_normal),
    wide = helpers.toggle_res(2560, 400, settings.input.sensitivity_normal),
    tall = helpers.toggle_res(384, 16384, settings.input.sensitivity_tall),
}

config.actions = {
    [settings.keys.thin] = function()
        if try_capture_key(settings.keys.thin) then
            return
        end
        passthrough_to_minecraft(settings.keys.thin)
        resolutions.thin()
    end,
    [settings.keys.wide] = function()
        if try_capture_key(settings.keys.wide) then
            return
        end
        passthrough_to_minecraft(settings.keys.wide)
        resolutions.wide()
    end,
    [settings.keys.tall] = function()
        if try_capture_key(settings.keys.tall) then
            return
        end
        passthrough_to_minecraft(settings.keys.tall)
        resolutions.tall()
    end,
    [settings.keys.fullscreen] = function()
        if try_capture_key(settings.keys.fullscreen) then
            return
        end
        waywall.toggle_fullscreen()
        if should_passthrough_bind(settings.keys.fullscreen) then
            return false
        end
    end,
    [settings.keys.toggle_ninbot] = function()
        if try_capture_key(settings.keys.toggle_ninbot) then
            return
        end
        toggle_ninb()
        if should_passthrough_bind(settings.keys.toggle_ninbot) then
            return false
        end
    end,
    [settings.keys.launch_paceman] = function()
        if try_capture_key(settings.keys.launch_paceman) then
            return
        end
        launch_paceman()
        if should_passthrough_bind(settings.keys.launch_paceman) then
            return false
        end
    end,
    [settings.keys.open_settings] = function()
        if try_capture_key(settings.keys.open_settings) then
            return
        end
        toggle_settings_gui()
        if should_passthrough_bind(settings.keys.open_settings) then
            return false
        end
    end,
    [settings.keys.reload_config] = function()
        if try_capture_key(settings.keys.reload_config) then
            return
        end
        waywall.reload()
        if should_passthrough_bind(settings.keys.reload_config) then
            return false
        end
    end,
    [settings.keys.toggle_remaps] = function()
        if try_capture_key(settings.keys.toggle_remaps) then
            return
        end
        if remaps_text then
            remaps_text:close()
            remaps_text = nil
        end
        if remaps_active then
            remaps_active = false
            waywall.set_remaps(remaps.disabled)
            waywall.set_keymap({ layout = "us", options = settings.input.options })
            log("chat mode enabled: remaps off, keymap forced to us")
            remaps_text = waywall.text("Chat Mode", { x = 50, y = 1300, color = "#9FA32B", size = 3, depth = 50 })
        else
            remaps_active = true
            waywall.set_remaps(remaps.enabled)
            waywall.set_keymap({ layout = settings.input.layout, options = settings.input.options })
            log("chat mode disabled: remaps on, keymap restored to " .. tostring(settings.input.layout))
        end
        if should_passthrough_bind(settings.keys.toggle_remaps) then
            return false
        end
    end,

    ["Up"] = function()
        if try_capture_key("Up") then
            return
        end
        return settings_nav_up()
    end,
    ["Down"] = function()
        if try_capture_key("Down") then
            return
        end
        return settings_nav_down()
    end,
    ["Prior"] = function()
        if try_capture_key("Prior") then
            return
        end
        return settings_nav_page_up()
    end,
    ["Next"] = function()
        if try_capture_key("Next") then
            return
        end
        return settings_nav_page_down()
    end,
    ["Page_Up"] = function()
        if try_capture_key("Page_Up") then
            return
        end
        return settings_nav_page_up()
    end,
    ["Page_Down"] = function()
        if try_capture_key("Page_Down") then
            return
        end
        return settings_nav_page_down()
    end,
    ["Left"] = function()
        if try_capture_key("Left") then
            return
        end
        local changed = settings_dec()
        if changed == false then
            return false
        end
        repeat_while_held("LEFT", settings_dec)
    end,
    ["Right"] = function()
        if try_capture_key("Right") then
            return
        end
        local changed = settings_inc()
        if changed == false then
            return false
        end
        repeat_while_held("RIGHT", settings_inc)
    end,
    ["Tab"] = function()
        if try_capture_key("Tab") then
            return
        end
        if ui_open then
            settings_next_group()
            return
        end
        waywall.press_key("TAB")
    end,
    ["Shift-Tab"] = function()
        if try_capture_key("Shift-Tab") then
            return
        end
        if ui_open then
            settings_prev_group()
            return
        end
        waywall.press_key("TAB")
    end,
    ["ISO_Left_Tab"] = function()
        if try_capture_key("ISO_Left_Tab") then
            return
        end
        if ui_open then
            settings_prev_group()
            return
        end
        waywall.press_key("TAB")
    end,
    ["Escape"] = settings_close_key,
}

local capture_tokens = {
    "space", "minus", "equal", "apostrophe", "semicolon", "comma", "period", "slash",
    "grave", "bracketleft", "bracketright", "backslash",
    "Insert", "Delete", "Home", "End",
    "Up", "Down", "Left", "Right", "Tab",
    "Prior", "Next", "Page_Up", "Page_Down",
    "Escape",
}

for n = 0, 9 do
    table.insert(capture_tokens, tostring(n))
end
for b = string.byte("A"), string.byte("Z") do
    local c = string.char(b)
    table.insert(capture_tokens, c)
    table.insert(capture_tokens, "Shift-" .. c)
end
for f = 1, 24 do
    table.insert(capture_tokens, "F" .. tostring(f))
    table.insert(capture_tokens, "Shift-F" .. tostring(f))
end

for _, token in ipairs(capture_tokens) do
    if config.actions[token] == nil then
        config.actions[token] = function()
            return try_capture_key(token)
        end
    end
end

waywall.listen("load", function()
    log("waywall load event")
    if settings.startup.auto_launch_paceman then
        launch_paceman()
    end
    apply_mirror_settings()
    show_first_boot_tips()
end)

waywall.listen("resolution", function()
    log("resolution changed; reapplying mirror settings")
    apply_mirror_settings()
end)

return config
