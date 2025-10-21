-- ~/.config/nvim/lua/config/lazy.lua

-- Ensure lazy.nvim is installed
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "--branch=stable",
    lazyrepo,
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Initialize Lazy.nvim with LazyVim plugin
require("lazy").setup({
  spec = {
    { import = "plugins" }, -- your custom plugins
  },
  defaults = {
    lazy = false,
    version = "*",
  },
  ui = {
    border = "rounded",  -- rounded borders for floating windows
  },
  performance = {
    rtp = {
      -- disables some default runtime plugins for better startup speed
      disabled_plugins = {
        "gzip",
        "matchit",
        "matchparen",
        "netrwPlugin",
        "tarPlugin",
        "tohtml",
        "tutor",
        "zipPlugin",
      },
    },
  },
})
