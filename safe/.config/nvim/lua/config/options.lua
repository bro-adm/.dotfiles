-- ~/.config/nvim/lua/config/options.lua

local opt = vim.opt

-- Use the system clipboard (macOS: copy with both + and *)
opt.clipboard = { "unnamedplus", "unnamed" }

-- line numbers
opt.number = true
opt.relativenumber = false
