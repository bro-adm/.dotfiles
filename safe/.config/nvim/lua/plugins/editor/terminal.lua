return {
  'akinsho/toggleterm.nvim',
  version = "*",
  config = function()
    require("toggleterm").setup({
      -- Set direction to float to satisfy the "floating window only" requirement
      direction = 'float',
      open_mapping = [[<C-CR>]], -- Standard mapping
      insert_mappings = true, 
      terminal_mappings = true,
      start_in_insert = true,
      float_opts = {
        border = 'curved',
        winblend = 3,
      },
    })

    -- Explicit mappings to ensure Kitty/C-CR behaves across all modes
    local opts = { noremap = true, silent = true }
    -- Normal mode
    vim.keymap.set('n', '<C-CR>', '<Cmd>ToggleTerm<CR>', opts)
    -- Insert mode
    vim.keymap.set('i', '<C-CR>', '<Esc><Cmd>ToggleTerm<CR>', opts)
    -- Terminal mode (to close it while inside)
    vim.keymap.set('t', '<C-CR>', [[<C-\><C-n><Cmd>ToggleTerm<CR>]], opts)
  end
}
