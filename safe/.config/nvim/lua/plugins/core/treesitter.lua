return {
  "nvim-treesitter/nvim-treesitter",
  branch = "master",
  lazy = false,
  build = ":TSUpdate",
  dependencies = {
    "nvim-treesitter/nvim-treesitter-textobjects",
  },
  config = function()
    require("nvim-treesitter.configs").setup({
      -- 1. PARSER MANAGEMENT
      -- We keep only lua/vim as requested.
      ensure_installed = { "lua", "vim", "query" }, -- Added 'query' for .scm highlighting
      -- These fields silence the [missing-fields] warning

      sync_install = false,
      auto_install = false,
      ignore_install = {},
      modules = {},

      -- 2. HIGHLIGHTING (CRITICAL)
      -- This enables the parser watcher, fixing the "Undo" bug.
      highlight = {
        enable = true,
        additional_vim_regex_highlighting = false,
      },

      -- 3. TEXTOBJECTS EXTENSION
      -- This registers the textobjects module so your custom queries work.
      textobjects = {
        select = {
          enable = true,
          lookahead = true, -- Automatically jump forward to textobj
          keymaps = {
            -- We leave this empty because you are using mini.ai for mappings.
            -- This just enables the engine to recognize the queries.
          },
        },
      },
    })
  end,
}
