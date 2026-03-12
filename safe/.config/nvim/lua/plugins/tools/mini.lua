return {
  "echasnovski/mini.nvim",
  version = "*", -- Use the latest stable version
  config = function()
    -- 1. Mini Pairs (Auto-close brackets/quotes)
    require("mini.pairs").setup({})

    -- 2. Mini Bracketed (Go to next/prev with [ and ])
    require("mini.bracketed").setup({})

    -- 3. Mini Surround (Add/Delete/Replace surroundings)
    require("mini.surround").setup({})

    -- 4. Mini Comment (Fast commenting)
    require("mini.comment").setup({
      mappings = {
        comment = '<C-S-/>',
        comment_line = '<C-/>',
        comment_visual = '<C-/>',
      },
    })

    -- 5. Mini AI (Better Text Objects)
    -- We removed the manual Lua injection/autocmds because nvim-treesitter 
    -- now handles the parser and queries automatically via your other config file.
    local ai = require('mini.ai')
    local spec_treesitter = ai.gen_spec.treesitter

    ai.setup({
      n_lines = 500,
      search_method = 'cover_or_next',
      custom_textobjects = {
        a = spec_treesitter { a = '@parameter.outer', i = '@parameter.inner' },
        c = spec_treesitter { a = '@class.outer', i = '@class.inner' },
        f = spec_treesitter { a = '@function.outer', i = '@function.inner' },
        F = spec_treesitter { a = '@call.outer', i = '@call.inner' },
        o = spec_treesitter {
          a = { '@block.outer', '@conditional.outer', '@loop.outer' },
          i = { '@block.inner', '@conditional.inner', '@loop.inner' },
        },
        i = spec_treesitter({ a = '@assignment.outer', i = '@assignment.inner' }),
      },
      mappings = {
        around_next = 'an',
        inside_next = 'in',
        around_last = 'al',
        inside_last = 'il',
      },
    })

    -- 6. Mini Bufremove (Safe buffer closing)
    require("mini.bufremove").setup({})

    -- Keymap for Bufremove
    vim.keymap.set("n", "<leader>bd", function()
      local bd = require("mini.bufremove").delete
      if vim.bo.modified then
        local choice = vim.fn.confirm(("Save changes to %q?"):format(vim.fn.bufname()), "&Yes\n&No\n&Cancel")
        if choice == 1 then -- Yes
          vim.cmd.write()
          bd(0)
        elseif choice == 2 then -- No
          bd(0, true)
        end
      else
        bd(0)
      end
    end, { desc = "Delete Buffer" })
  end,
}
