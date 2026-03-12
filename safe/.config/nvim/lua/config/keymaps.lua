-- ~/.config/nvim/lua/config/keymaps.lua

-- 1. Standard Setup
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Helper function for keymaps
local function map(mode, lhs, rhs, desc)
  vim.keymap.set(mode, lhs, rhs, { desc = desc, silent = true, noremap = true })
end

-- 2. Split Navigation & Creation
map("n", "<D-C-S-h>", ":leftabove vsplit<CR>", "Split Left")
map("n", "<D-C-S-l>", ":rightbelow vsplit<CR>", "Split Right")
map("n", "<D-C-S-k>", ":leftabove split<CR>", "Split Up")
map("n", "<D-C-S-j>", ":rightbelow split<CR>", "Split Down")

map({'n', 'v', 'x', 'o'}, 'H', '^', "Jump to start of line after blank chars") -- different than 0
map({'n', 'v', 'x', 'o'}, 'L', 'g_', "Jump to end of line excluding blank characters") -- different than $
map({'n', 'v', 'x', 'o'}, 'K', 'H', "Jump to top of visible screen") -- replaces original H
map({'n', 'v', 'x', 'o'}, 'J', 'L', "Jump to bottom of visible screen") -- replaces original L
map({'n', 'v', 'x', 'o'}, '<C-S-k>', 'gg0', "Jump to Start of File") -- absolute top at 0
map({'n', 'v', 'x', 'o'}, '<C-S-j>', 'G0', "Jump to End of File") -- absolute bottom at 0
map('n', '<S-CR>', 'J', "erase enter via join") -- Shift+Enter to join lines (reverse enter) -- replaces original J
-- The above do not effect D, C, S commands that all provide shortcuts for combo ops with $
-- M fot middle remains unchaned

--------------------------------------------------------------------------------
-- 3. HELPER FUNCTIONS
--------------------------------------------------------------------------------

-- Helper: Count only "Real" (Non-Floating) Windows
-- This prevents notifications or tooltips from tricking the logic
local function get_real_window_count()
  local wins = vim.api.nvim_tabpage_list_wins(0)
  local count = 0
  for _, win in ipairs(wins) do
    local config = vim.api.nvim_win_get_config(win)
    if config.relative == "" then -- Empty string means a standard split window
      count = count + 1
    end
  end
  return count
end

--------------------------------------------------------------------------------
-- 4. SMART QUIT LOGIC (GLOBAL FUNCTIONS)
--------------------------------------------------------------------------------

-- LOGIC FOR :q (Close Buffer, KEEP Window)
-- "I want to stop working on this file, but keep my layout."
_G.smart_quit = function(force)
  -- A. Special Windows: Close normally
  if vim.bo.buftype ~= "" then
    if force then vim.cmd("q!") else vim.cmd("q") end
    return
  end

  -- B. Standard Files: Delete Buffer using Mini Bufremove
  -- This keeps the window open, showing the next buffer or a scratch pad.
  local bd = require("mini.bufremove").delete
  bd(0, force)
end

-- LOGIC FOR :Q (Close Buffer AND Window)
-- "I want to kill this specific viewport."
_G.smart_close_win = function(force)
  -- A. Special Windows: Close normally
  if vim.bo.buftype ~= "" then
    if force then vim.cmd("q!") else vim.cmd("q") end
    return
  end

  -- B. Get Context (Windows in this tab, Total Tabs)
  local win_count = get_real_window_count()
  local tab_count = #vim.api.nvim_list_tabpages()

  -- C. "Last Window in Tab" Case
  if win_count == 1 then
    -- If other tabs exist, close ONLY this tab
    if tab_count > 1 then
      vim.cmd("tabclose")
    else
      -- If this is the last tab, Quit the App
      if force then 
        vim.cmd("qa!") 
      else 
        vim.cmd("confirm qa") 
      end
    end
    return
  end

  -- D. Multiple Splits in Current Tab
  -- Delete the buffer using standard 'bd' (which usually kills the split too)
  local cmd = force and "bd!" or "bd"
  local ok, err = pcall(vim.cmd, cmd)

  if not ok then
    vim.notify("Error: " .. tostring(err), vim.log.levels.ERROR)
    return
  end
  
  -- E. Cleanup
  -- If 'bd' didn't close the split automatically (e.g. it switched to prev buffer),
  -- and we still have multiple windows, force close this one.
  -- We check count again to be sure we don't accidentally close the last one.
  if get_real_window_count() > 0 and get_real_window_count() == win_count then
    vim.cmd("close")
  end
end

--------------------------------------------------------------------------------
-- 5. USER COMMANDS
--------------------------------------------------------------------------------

vim.api.nvim_create_user_command("SmartQuit", function(opts)
  _G.smart_quit(opts.bang)
end, { bang = true })

vim.api.nvim_create_user_command("SmartClose", function(opts)
  _G.smart_close_win(opts.bang)
end, { bang = true })

vim.api.nvim_create_user_command("SmartWriteQuit", function(opts)
  local save_cmd = opts.bang and "write!" or "write"
  if pcall(vim.cmd, save_cmd) then _G.smart_quit(opts.bang) end
end, { bang = true })

vim.api.nvim_create_user_command("SmartWriteClose", function(opts)
  local save_cmd = opts.bang and "write!" or "write"
  if pcall(vim.cmd, save_cmd) then _G.smart_close_win(opts.bang) end
end, { bang = true })

--------------------------------------------------------------------------------
-- 6. ABBREVIATIONS
--------------------------------------------------------------------------------

vim.cmd([[
  cnoreabbrev <expr> q getcmdtype() == ":" && getcmdline() == "q" ? "SmartQuit" : "q"
  cnoreabbrev <expr> Q getcmdtype() == ":" && getcmdline() == "Q" ? "SmartClose" : "Q"
  cnoreabbrev <expr> wq getcmdtype() == ":" && getcmdline() == "wq" ? "SmartWriteQuit" : "wq"
  cnoreabbrev <expr> wQ getcmdtype() == ":" && getcmdline() == "wQ" ? "SmartWriteClose" : "wQ"
]])

-- Optional: Leader Mappings
map("n", "<leader>q", ":SmartQuit<CR>", "Close Buffer (Keep Win)")
map("n", "<leader>Q", ":SmartClose<CR>", "Close Buffer & Win")
