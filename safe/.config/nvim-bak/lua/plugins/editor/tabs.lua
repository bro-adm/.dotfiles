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
    
    -- 1. Create New Tab
    vim.api.nvim_set_keymap("n", "<D-C-t>", ":$tabnew<CR>", opts)

    -- 2. Smart Close Window (<D-C-w>)
    -- Logic: Split -> Tab -> Quit (Safely)
    vim.keymap.set("n", "<D-C-w>", function()
      local wins = vim.api.nvim_tabpage_list_wins(0)
      local tabs = vim.api.nvim_list_tabpages()
      
      -- If multiple splits in this tab -> Close Split
      if #wins > 1 then
        vim.cmd("close")
        
      -- If only 1 window here, but other tabs exist -> Close Tab
      elseif #tabs > 1 then
        vim.cmd("tabclose")
        
      -- If 1 window and 1 tab (Last thing open) -> Quit Neovim
      else
        vim.cmd("confirm q")
      end
    end, { desc = "Smart Close (Split/Tab/Quit)" })

    -- 3. Force Close Tab (<D-C-Shift-w>)
    -- Logic: Always kills the Tab. If it's the last tab, it kills the App.
    vim.keymap.set("n", "<D-C-S-w>", function()
      local tabs = vim.api.nvim_list_tabpages()
      
      -- If multiple tabs -> Close just this tab
      if #tabs > 1 then
        vim.cmd("tabclose")
      -- If LAST tab -> Quit ALL (Closes app even if splits exist)
      else
        vim.cmd("confirm qa") 
      end
    end, { desc = "Force Close Tab (or Quit App)" })

    -- 4. Navigation
    vim.api.nvim_set_keymap("n", "<D-C-]>", ":tabn<CR>", opts)
    vim.api.nvim_set_keymap("n", "<D-C-[>", ":tabp<CR>", opts)
  end,
}
