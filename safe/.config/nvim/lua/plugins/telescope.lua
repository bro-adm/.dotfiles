-- ~/.config/nvim/lua/plugins/telescope.lua

return {
  "nvim-telescope/telescope.nvim",
  dependencies = { "nvim-lua/plenary.nvim" },
  config = function()
    local telescope = require("telescope")
    local actions = require("telescope.actions")

    telescope.setup({
      defaults = {
        prompt_prefix = "🔍 ",
        selection_caret = " ",
        path_display = { "truncate" },
        mappings = {
          i = {
            ["<C-n>"] = actions.cycle_history_next,
            ["<C-p>"] = actions.cycle_history_prev,
            ["<C-j>"] = actions.move_selection_next,
            ["<C-k>"] = actions.move_selection_previous,
            ["<C-c>"] = actions.close,
          },
          n = {
            ["q"] = actions.close,
          },
        },
      },
      pickers = {
        find_files = {
          theme = "dropdown",
          hidden = true, -- show hidden files
        },
        buffers = {
          theme = "dropdown",
          previewer = false,
        },
      },
      extensions = {
        -- example: live_grep_args or fzf native can go here
      },
    })

    -- Optional keymaps for convenience
    local map = vim.keymap.set
    map("n", "<leader>ff", "<cmd>Telescope find_files<CR>", { desc = "Find files" })
    map("n", "<leader>fg", "<cmd>Telescope live_grep<CR>", { desc = "Live grep" })
    map("n", "<leader>fb", "<cmd>Telescope buffers<CR>", { desc = "Buffers" })
    map("n", "<leader>fh", "<cmd>Telescope help_tags<CR>", { desc = "Help tags" })
    map("n", "<leader>fc", "<cmd>Telescope commands<CR>", { desc = "Commands" })
  end,
}
