return {
  "christoomey/vim-tmux-navigator",
  cmd = {
    "TmuxNavigateLeft",
    "TmuxNavigateDown",
    "TmuxNavigateUp",
    "TmuxNavigateRight",
    "TmuxNavigatePrevious",
    "TmuxNavigatorProcessList",
  },
  keys = {
    { "<C-[>", "<cmd>TmuxNavigateLeft<cr>" },
    { "<C-shift-]>", "<cmd>TmuxNavigateDown<cr>" },
    { "<C-shift-[>", "<cmd>TmuxNavigateUp<cr>" },
    { "<C-]>", "<cmd>TmuxNavigateRight<cr>" },
    { "<C-Tab>", "<cmd>TmuxNavigatePrevious<cr>" },
  },
}
