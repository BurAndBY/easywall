return {
  first_boot_complete = true,
  show_first_boot_tips = true,
  auto_open_settings_gui_on_first_boot = false,

  ui = {
    tips_duration_ms = 12000,
    tips_color = "#F2F0E9",
    tips_size = 2,
    tips_x = 48,
    tips_y = 52,
    tips_spacing = 42,
  },

  keys = {
    thin = "N",
    wide = "M",
    tall = "B",
    toggle_ninbot = "grave",
    launch_paceman = "Shift-P",
    fullscreen = "Shift-O",
    toggle_remaps = "Insert",
    open_settings = "F8",
    reload_config = "Home",
    passthrough_action_keys = true,
  },

  input = {
    layout = "mc",
    options = "caps:none",
    repeat_rate = 40,
    repeat_delay = 120,
    confine_pointer = false,
    sensitivity_normal = 3,
    sensitivity_tall = 0.5,
  },

  paths = {
    ninbot_jar = "resources/Ninjabrain-Bot-1.5.1.jar",
    paceman_jar = "resources/paceman-tracker-0.7.1.jar",
  },

  startup = {
    auto_launch_paceman = true,
  },

  mirrors = {
    entity_counter_enabled = true,
    entity_counter_colorkey = true,
    pie_chart_enabled = true,
    pie_chart_colorkey = true,
  },

  theme = {
    ninb_anchor = "topleft",
    ninb_opacity = 0.9,
    background_png = "resources/background.png",
  },
}
