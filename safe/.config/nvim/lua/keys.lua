-- [nfnl] fnl/keys.fnl
vim.g.mapleader = " "
vim.g.maplocalleader = ","
local map
local function _1_(mode, binding, action, description)
  return vim.keymap.set(mode, binding, action, {desc = description, silent = true, noremap = true})
end
map = _1_
vim.keymap.set("n", "<D-C-S-h>", ":leftabove vsplit<CR>", {desc = "Split Left"})
vim.keymap.set("n", "<D-C-S-l>", ":rightbelow vsplit<CR>", {desc = "Split Right"})
vim.keymap.set("n", "<D-C-S-h>", ":leftabove split<CR>", {desc = "Split Up"})
vim.keymap.set("n", "<D-C-S-h>", ":rightbelow split<CR>", {desc = "Split Down"})
map({"n", "v", "x", "o"}, "H", "^", "Jump to start of line after blank chars")
map({"n", "v", "x", "o"}, "L", "g_", "Jump to end of line excluding blank characters")
map({"n", "v", "x", "o"}, "K", "H", "Jump to top of the visible screen")
map({"n", "v", "x", "o"}, "J", "L", "Jump to the bottom of visible screen")
map({"n", "v", "x", "o"}, "<C-S-k>", "gg0", "Jump to start of File")
map({"n", "v", "x", "o"}, "<C-S-j>", "G0", "Jump to bottom of File")
map("n", "<S-CR>", "J", "reverse enter -- join lines")
map("n", "<D-C-0>", "<C-w>=", "Splits Equal Size")
map("n", "<D-C-CR>", "<C-w>_<C-w>|", "Split Zoom")
map("n", "<D-C-t>", ":tabnew<CR>", "New Tab")
map("n", "<D-C-w>", ":ScopeClose<CR>", "Close Tab")
map("n", "<D-C-]>", ":tabnext<CR>", "Next Tab")
return map("n", "<D-C-[>", ":tabprevious<CR>", "Previous Tab")
