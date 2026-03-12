return {
  "ghillb/cybu.nvim",
  branch = "main",
  dependencies = {
    "nvim-tree/nvim-web-devicons",
    "nvim-lua/plenary.nvim",
  },
  -- Lazy loads the plugin when you press these keys
  keys = {
    -- 1. Cycling Buffers (K and J)
    { "<C-k>", "<Plug>(CybuPrev)", desc = "Cybu Prev" },
    { "<C-j>", "<Plug>(CybuNext)", desc = "Cybu Next" },

    -- 2. Last Used Buffers (Control + Tab)
    -- Note: <c-tab> does NOT conflict with <c-i>, so this is safe.
    { "<c-s-tab>", "<plug>(CybuLastusedPrev)", mode = { "n", "v" }, desc = "Cybu Last Used Prev" },
    { "<c-tab>", "<plug>(CybuLastusedNext)", mode = { "n", "v" }, desc = "Cybu Last Used Next" },
    
    -- OPTIONAL: If you switch to plain <tab>, uncomment these:
    -- { "<s-tab>", "<plug>(CybuLastusedPrev)", mode = { "n", "v" } },
    -- { "<tab>", "<plug>(CybuLastusedNext)", mode = { "n", "v" } },
  },
  
  -- The 'init' function runs BEFORE the plugin loads.
  -- This is the correct place to apply the <C-i> fix if you ever use plain <Tab>.
  init = function()
    -- Only strictly needed if you map <Tab>, but harmless to add now for safety.
    vim.keymap.set("n", "<C-i>", "<C-i>")
  end,

  config = function()
    local cybu = require("cybu")
    cybu.setup()
  end,
}
