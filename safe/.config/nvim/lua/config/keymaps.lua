-- ~/.config/nvim/lua/config/keymaps.lua

-- Set leader keys
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Helper function for keymaps with description
local function map(mode, lhs, rhs, desc)
    vim.keymap.set(mode, lhs, rhs, { desc = desc, silent = true, noremap = true })
end

-- Buffer navigation
map("n", "<leader>n", ":bn<CR>", "Next buffer")
map("n", "<leader>p", ":bp<CR>", "Previous buffer")
map("n", "<leader>c", ":bd<CR>", "Close buffer")

-- Command-line abbreviations
vim.cmd([[
    cabbrev <expr> q getcmdtype() == ":" && getcmdline() == "q" ?
        \ 'execute "lua if #vim.fn.getbufinfo({buflisted=1}) > 1 then vim.cmd(\"bd\") else vim.cmd(\"qa\") end"' :
        \ 'q'
    cabbrev Q qa
]])
