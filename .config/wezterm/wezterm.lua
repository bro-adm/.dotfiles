local wezterm = require 'wezterm'
local config = {}

-- config.hide_tab_bar_if_only_one_tab = true
config.enable_tab_bar = false

config.font = wezterm.font 'JetBrains Mono'
config.color_scheme = 'Sakura (base16)'
config.window_background_gradient = {
  colors = { 'lightpink', 'white' },
  orientation = {
    Radial = {
      -- Specifies the x coordinate of the center of the circle,
      -- in the range 0.0 through 1.0.  The default is 0.5 which
      -- is centered in the X dimension.
      cx = 0.75,

      -- Specifies the y coordinate of the center of the circle,
      -- in the range 0.0 through 1.0.  The default is 0.5 which
      -- is centered in the Y dimension.
      cy = 0.75,

      -- Specifies the radius of the notional circle.
      -- The default is 0.5, which combined with the default cx
      -- and cy values places the circle in the center of the
      -- window, with the edges touching the window edges.
      -- Values larger than 1 are possible.
      radius = 1.25,
    },
  },
}

config.ssh_domains = {
  {
    name = "server01",
    remote_address = "192.168.68.118",
    username = "server",
    multiplexing = "WezTerm",
    no_agent_auth = true,  -- don’t try ssh-agent
    ssh_option = {
      pubkeyauthentication = "no",
      preferredauthentications = "password",
    },
  },
}

config.launch_menu = {
  {
    label = 'Zsh Shell',
    args = { 'zsh', '-l' },
  },
  {
    label = 'SSH to myserver',
    args = { 'ssh', 'server@server01.local' },
  },
}

local act = wezterm.action
-- config.leader = { key = 'Space', mods = 'CTRL|SHIFT' }

config.keys = {
  {
    key = "Enter",
    mods = "SUPER",
    action = wezterm.action.ShowLauncherArgs { flags = 'TABS' },
  },
  {
    key = "Enter",
    mods = "SUPER|SHIFT",
    action = wezterm.action.ShowLauncherArgs { flags = 'LAUNCH_MENU_ITEMS' },
  },
  {
    key = 'RightArrow',
    mods = 'SUPER|SHIFT',
    action = act.SplitPane {
        direction = 'Right',
	size = { Percent = 50 },
    },
  },
  {
    key = 'DownArrow',
    mods = 'SUPER|SHIFT',
    action = act.SplitPane {
        direction = 'Down',
	size = { Percent = 50 },
    },
  },
  { key = 'LeftArrow', mods = 'SUPER', action = act.ActivatePaneDirection 'Left' },
  { key = 'RightArrow', mods = 'SUPER', action = act.ActivatePaneDirection 'Right' },
  { key = 'UpArrow', mods = 'SUPER', action = act.ActivatePaneDirection 'Up' },
  { key = 'DownArrow', mods = 'SUPER', action = act.ActivatePaneDirection 'Down' },

  {
    key = 'r',
    mods = 'SUPER',
    action = act.ActivateKeyTable {
      name = 'resize_pane',
      one_shot = false,   -- stay in resize mode until Escape
    },
  },
}

config.key_tables = {
  -- Defines the keys that are active in our resize-pane mode.
  -- Since we're likely to want to make multiple adjustments,
  -- we made the activation one_shot=false. We therefore need
  -- to define a key assignment for getting out of this mode.
  -- 'resize_pane' here corresponds to the name="resize_pane" in
  -- the key assignments above.
  resize_pane = {
    { key = 'LeftArrow', action = act.AdjustPaneSize { 'Left', 1 } },
    { key = 'h', action = act.AdjustPaneSize { 'Left', 1 } },

    { key = 'RightArrow', action = act.AdjustPaneSize { 'Right', 1 } },
    { key = 'l', action = act.AdjustPaneSize { 'Right', 1 } },

    { key = 'UpArrow', action = act.AdjustPaneSize { 'Up', 1 } },
    { key = 'k', action = act.AdjustPaneSize { 'Up', 1 } },

    { key = 'DownArrow', action = act.AdjustPaneSize { 'Down', 1 } },
    { key = 'j', action = act.AdjustPaneSize { 'Down', 1 } },

    -- Cancel the mode by pressing escape
    { key = 'Escape', action = 'PopKeyTable' },
  },
}

return config
