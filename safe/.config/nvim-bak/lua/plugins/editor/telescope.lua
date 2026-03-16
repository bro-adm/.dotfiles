return {
  "nvim-telescope/telescope.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    { 
      "tiagovla/scope.nvim", 
      config = true 
    },
  },
  config = function()
    local telescope = require("telescope")
    local actions = require("telescope.actions")
    local action_state = require("telescope.actions.state")

    -- 1. Load Scope Extension
    telescope.load_extension("scope")

    -- 2. Helper: Teleport to existing tab if file is open
    local function jump_to_tab_or_open(prompt_bufnr)
      local selection = action_state.get_selected_entry()
      actions.close(prompt_bufnr)
      if not selection then return end

      local target_buf = selection.bufnr or vim.fn.bufnr(selection.path or selection.filename)

      if target_buf and target_buf ~= -1 then
        for _, tab in ipairs(vim.api.nvim_list_tabpages()) do
          for _, win in ipairs(vim.api.nvim_tabpage_list_wins(tab)) do
            if vim.api.nvim_win_get_buf(win) == target_buf then
              vim.api.nvim_set_current_tabpage(tab)
              vim.api.nvim_set_current_win(win)
              return
            end
          end
        end
      end
      
      local path = selection.path or selection.filename
      if path then
        vim.cmd("edit " .. vim.fn.fnameescape(path))
      end
    end

    -- 3. Helper: Smart Move (Fixes the Tab Deletion Bug)
    local function move_buf_to_tab(tab_num)
      local buf_to_move = vim.api.nvim_get_current_buf()
      
      -- A. Execute the scope move
      -- This updates the internal "lists" of which buffer belongs where
      vim.cmd("ScopeMoveBuf " .. tab_num)

      -- B. Clean up SOURCE Tab (Current)
      -- If we are still looking at the buffer we just moved, switch away.
      if vim.api.nvim_get_current_buf() == buf_to_move then
        pcall(vim.cmd, "bnext")
        -- If bnext didn't change anything (only 1 buf was here), open scratch
        if vim.api.nvim_get_current_buf() == buf_to_move then
          vim.cmd("enew")
        end
      end

      -- C. Clean up TARGET Tab
      -- 1. Find the handle for the target tab
      local target_tab_handle = nil
      for _, tab in ipairs(vim.api.nvim_list_tabpages()) do
        if vim.api.nvim_tabpage_get_number(tab) == tab_num then
          target_tab_handle = tab
          break
        end
      end

      -- 2. If target tab exists, look for empty [No Name] windows
      if target_tab_handle then
        for _, win in ipairs(vim.api.nvim_tabpage_list_wins(target_tab_handle)) do
          local win_buf = vim.api.nvim_win_get_buf(win)
          local name = vim.api.nvim_buf_get_name(win_buf)
          
          -- Check if it's an empty [No Name] buffer
          if name == "" and vim.api.nvim_buf_line_count(win_buf) == 1 then
            local lines = vim.api.nvim_buf_get_lines(win_buf, 0, 1, false)
            if lines[1] == "" then
              
              -- CRITICAL FIX: 
              -- First, force the window to display the buffer we just moved.
              vim.api.nvim_win_set_buf(win, buf_to_move)
              
              -- Now that the window is safe (holding a real file), 
              -- we can delete the empty placeholder buffer.
              pcall(vim.api.nvim_buf_delete, win_buf, { force = true })
            end
          end
        end
      end
    end

    -- 4. Setup Telescope
    telescope.setup({
      defaults = {
        prompt_prefix = "🔍 ",
        selection_caret = " ",
        path_display = { "truncate" },
        mappings = {
          i = {
            ["<C-j>"] = actions.move_selection_next,
            ["<C-k>"] = actions.move_selection_previous,
          },
        },
      },
      pickers = {
        find_files = {
          theme = "dropdown",
          hidden = false,
          mappings = { i = { ["<CR>"] = jump_to_tab_or_open } },
        },
        buffers = {
          theme = "dropdown",
          mappings = { i = { ["<CR>"] = jump_to_tab_or_open } },
        },
      },
    })

    -- 5. Keymaps
    local map = vim.keymap.set

    -- Standard Telescope
    map("n", "<leader>ff", "<cmd>Telescope find_files<CR>", { desc = "Find Files" })
    map("n", "<leader>fg", "<cmd>Telescope live_grep<CR>", { desc = "Live Grep" })
    map("n", "<leader>fc", "<cmd>Telescope commands<CR>", { desc = "Commands" })
    map("n", "<leader>fh", "<cmd>Telescope help_tags<CR>", { desc = "Help Tags" })

    -- TAB-SCOPED Buffers
    map("n", "<leader>fb", "<cmd>Telescope buffers<CR>", { desc = "Buffers (Tab-Scoped)" })

    -- GLOBAL Buffers
    map("n", "<leader>fB", function()
      telescope.extensions.scope.buffers({
        theme = "dropdown",
        attach_mappings = function(_, map_inner)
          map_inner("i", "<CR>", jump_to_tab_or_open)
          map_inner("n", "<CR>", jump_to_tab_or_open)
          return true
        end
      })
    end, { desc = "Buffers (Global Teleport)" })

    -- Scope Move Keys (Using the fixed move helper)
    map("n", "<D-C-S-1>", function() move_buf_to_tab(1) end, { desc = "Move Buf to Tab 1" })
    map("n", "<D-C-S-2>", function() move_buf_to_tab(2) end, { desc = "Move Buf to Tab 2" })
    map("n", "<D-C-S-3>", function() move_buf_to_tab(3) end, { desc = "Move Buf to Tab 3" })
    map("n", "<D-C-S-4>", function() move_buf_to_tab(4) end, { desc = "Move Buf to Tab 4" })
    map("n", "<D-C-S-5>", function() move_buf_to_tab(5) end, { desc = "Move Buf to Tab 5" })
    map("n", "<D-C-S-6>", function() move_buf_to_tab(6) end, { desc = "Move Buf to Tab 6" })
    map("n", "<D-C-S-7>", function() move_buf_to_tab(7) end, { desc = "Move Buf to Tab 7" })
    map("n", "<D-C-S-8>", function() move_buf_to_tab(8) end, { desc = "Move Buf to Tab 8" })
    map("n", "<D-C-S-9>", function() move_buf_to_tab(9) end, { desc = "Move Buf to Tab 9" })
  end,
}
