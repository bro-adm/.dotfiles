-- ~/.config/nvim/lua/config/options.lua

local opt = vim.opt

-- Use the system clipboard (macOS: copy with both + and *)
opt.clipboard = { "unnamedplus", "unnamed" }

-- line numbers
opt.number = true
opt.relativenumber = false

opt.tabstop = 4
opt.shiftwidth = 4
opt.softtabstop = 4
opt.expandtab = true

opt.switchbuf = "usetab,useopen"
