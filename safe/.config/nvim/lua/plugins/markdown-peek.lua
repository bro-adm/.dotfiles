return {
    'toppair/peek.nvim',
    build = 'deno task --quiet build:fast', -- Required for installation
    ft = { 'markdown' },                     -- Lazy load on Markdown filetype
    
    --- Configuration table passed to require('peek').setup()
    opts = {
        auto_load = true,
        close_on_bdelete = true,
        syntax = true,
        theme = 'dark',
        update_on_change = true,
        app = 'browser',
        filetype = { 'markdown' },
        throttle_at = 200000,
        throttle_time = 'auto',
    },
    
    -- This function runs *after* the plugin is loaded (or the opts are processed).
    -- It is used here to define the global user commands that your keymaps call.
    config = function()
        local peek = require("peek")

	vim.api.nvim_create_user_command("PeekOpen", peek.open, {})
        vim.api.nvim_create_user_command("PeekClose", peek.close, {})
    end,

    keys = {
        { '<leader>mp', '<cmd>PeekOpen<cr>', desc = 'Markdown Preview' },
        { '<leader>mc', '<cmd>PeekClose<cr>', desc = 'Close Markdown Preview' },
    }
}

