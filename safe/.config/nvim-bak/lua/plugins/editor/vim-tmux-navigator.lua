return {
  "christoomey/vim-tmux-navigator",
  init = function()
    vim.g.tmux_navigator_no_mappings = 1  -- Disable default <C-hjkl> mappings
  end,
  cmd = {
    "TmuxNavigateLeft",
    "TmuxNavigateDown",
    "TmuxNavigateUp",
    "TmuxNavigateRight",
    "TmuxNavigatePrevious",
    "TmuxNavigatorProcessList",
  },
  keys = {
    { "<D-C-h>", "<cmd>TmuxNavigateLeft<cr>" },
    { "<D-C-j>", "<cmd>TmuxNavigateDown<cr>" },
    { "<D-C-k>", "<cmd>TmuxNavigateUp<cr>" },
    { "<D-C-l>", "<cmd>TmuxNavigateRight<cr>" },
    -- { "<D-C-Tab>", "<cmd>TmuxNavigatePrevious<cr>" },
  },
}
