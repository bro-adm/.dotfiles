return {
  "stevearc/oil.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  config = function()
    local oil = require("oil")

    oil.setup({
      -- Customizing the floating window appearance
      float = {
        padding = 2,
        -- FIX 1: Reduce width so there is room for the preview on the right.
        -- 0.5 means 50% of the screen width. Adjust to 0.6 or 0.7 if you prefer.
        max_width = 0,
        max_height = 0,
        border = "rounded",
        win_options = {
          winblend = 10,
        },
        -- FIX 2: Explicitly tell the floating setup to put the preview on the right
        preview_split = "right",
      },
      -- Preview window configuration
      preview = {
        border = "rounded",
      },
      view_options = {
        show_hidden = true,
      },
      -- Oil handles LSP file operations itself
      lsp_file_methods = {
        enabled = true,         -- Oil handles the LSP logic
        autosave_changes = true, -- Oil saves the files for you
      },
      keymaps = {
        -- FIX 3: Simplify the keymap. The 'float' config above now handles the direction.
        ["<C-p>"] = "actions.preview",
      },
    })

    vim.keymap.set("n", "-", oil.open_float, { desc = "Open Oil floating window" })
  end,
}
