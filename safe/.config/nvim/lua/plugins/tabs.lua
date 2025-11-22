return {
  'nanozuki/tabby.nvim',
  event = "VeryLazy",
  config = function()
    -- Define custom theme
    local theme = {
      fill = 'TabLineFill',
      head = 'TabLine',
      current_tab = 'TabLineSel',
      tab = 'TabLine',
      win = 'TabLine',
      tail = 'TabLine',
    }

    -- Tabby setup
    require('tabby').setup({
      line = function(line)
        return {
          {
            { '  ', hl = theme.head },
            line.sep('', theme.head, theme.fill),
          },
          line.tabs().foreach(function(tab)
            local hl = tab.is_current() and theme.current_tab or theme.tab
            return {
              line.sep('', hl, theme.fill),
              tab.is_current() and '' or '󰆣',
              tab.number(),
              tab.name(),
              tab.close_btn(''),
              line.sep('', hl, theme.fill),
              hl = hl,
              margin = ' ',
            }
          end),
          line.spacer(),
          line.wins_in_tab(line.api.get_current_tab()).foreach(function(win)
            return {
              line.sep('', theme.win, theme.fill),
              win.is_current() and '' or '',
              win.buf_name(),
              line.sep('', theme.win, theme.fill),
              hl = theme.win,
              margin = ' ',
            }
          end),
          {
            line.sep('', theme.tail, theme.fill),
            { '  ', hl = theme.tail },
          },
          hl = theme.fill,
        }
      end,
    })

    -- Keybindings
    local opts = { noremap = true, silent = true }
    vim.api.nvim_set_keymap("n", "<leader>ta", ":$tabnew<CR>", opts)
    vim.api.nvim_set_keymap("n", "<leader>tc", ":tabclose<CR>", opts)
    vim.api.nvim_set_keymap("n", "<leader>to", ":tabonly<CR>", opts)
    vim.api.nvim_set_keymap("n", "<leader>tn", ":tabn<CR>", opts)
    vim.api.nvim_set_keymap("n", "<leader>tp", ":tabp<CR>", opts)
    vim.api.nvim_set_keymap("n", "<leader>tmp", ":-tabmove<CR>", opts)
    vim.api.nvim_set_keymap("n", "<leader>tmn", ":+tabmove<CR>", opts)
  end,
}
