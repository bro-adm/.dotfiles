return {
  "folke/flash.nvim",
  event = "VeryLazy",
  ---@type flash.config
  opts = {
    -- this is the critical part for / search integration
    modes = {
      search = {
        enabled = true, -- shows labels automatically when you use / or ?
      },
      char = {
          enabled = true,
          jump_labels = true,
      }
    },
    -- optional: you can customize how the labels look here
    label = {
      uppercase = false,
      rainbow = { enabled = false },
    },
  },
  keys = {
    -- 1. standard "jump" (like goland's search everywhere but for the screen)
    -- { "s", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "flash jump" },

    --
    { "S", mode = { "n", "o", "v", "x" }, function() require("flash").treesitter() end, desc = "flash treesitter" },
    -- becuase of taking known S - then use its base command cc for original S

    -- 3. remote actions (delete/yank/change a distant word without moving) - normal mode is being enabled via the non custom config
    { "/", mode = { 'o', 'v', 'x' }, function() require("flash").remote() end, desc = "flash jump on operations" },

    -- 4. treesitter search - The visual modes kind of are uselss with this - use / instead for custom jump or s for treesitter based one 
    { "?", mode = { "n", "o" }, function() require("flash").treesitter_search() end, desc = "search + flash treesitter -- remote flash treesitter" },

    -- 5. toggle flash inside a search (ctrl+s while typing /)
    { "<c-f>", mode = { "c" }, function() require("flash").toggle() end, desc = "toggle flash search" },
  },
}
