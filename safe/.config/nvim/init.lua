require("config.options")
require("config.keymaps")
require("config.lazy")

vim.opt.termguicolors = true

vim.schedule(function()
  vim.keymap.set({ "n", "v", "o" }, "?", "<Nop>", { silent = true, noremap = true, desc = "Disabled search" })
end)

vim.filetype.add({
  extension = {
    scm = function(path, bufnr)
      -- If the file is inside a "queries" directory, it's a Tree-sitter query
      if path:match("queries") then
        return "query"
      end
      return "scheme"
    end,
  },
})

local function start_lsps_stealth()
    -- 1. Check Mason for installed servers
    local status, mason_lspconfig = pcall(require, "mason-lspconfig")
    if not status then return end
    
    local installed_servers = mason_lspconfig.get_installed_servers()
    local lspconfig = require("lspconfig")
    local cwd = vim.fn.getcwd()

    -- 2. Build the Map: Filetype -> Server Name
    local ft_to_server = {}
    for _, server_name in ipairs(installed_servers) do
        local server_cfg = lspconfig[server_name]
        -- Check default config for filetypes
        if server_cfg and server_cfg.document_config then
            local default_opts = server_cfg.document_config.default_config
            local filetypes = default_opts.filetypes
            
            if filetypes then
                for _, ft in ipairs(filetypes) do
                    if not ft_to_server[ft] then
                        ft_to_server[ft] = server_name
                    end
                end
            end
        end
    end

    -- 3. Pre-fill 'started_servers' with currently active clients
    -- This prevents us from trying to start gopls if it's already running!
    local started_servers = {}
    
    -- Support for both new (0.10+) and old Neovim APIs
    local get_clients = vim.lsp.get_clients or vim.lsp.get_active_clients
    local active_clients = get_clients()

    for _, client in ipairs(active_clients) do
        started_servers[client.name] = true
        -- Optional: print("Skipping " .. client.name .. " (Already Active)") 
    end

    -- 4. Scan the Project (fd)
    local fd_output = vim.fn.system("fd -t f --max-results 50")
    if fd_output == "" then return end

    -- 5. Match Files & Launch (Only if NOT already started)
    for filename in string.gmatch(fd_output, "[^\r\n]+") do
        local ft = vim.filetype.match({ filename = filename })
        
        if ft and ft_to_server[ft] then
            local server_name = ft_to_server[ft]
            
            -- This check now handles both "we just started it" AND "it was already running"
            if not started_servers[server_name] then
                local config = lspconfig[server_name]
                
                if config.manager then
                    config.manager:add(cwd)
                    -- print("Stealth Launch: " .. server_name)
                else
                    config.setup{} 
                    if config.manager then
                        config.manager:add(cwd)
                    end
                end
                
                started_servers[server_name] = true
            end
        end
    end
end

-- 1.5s delay
-- vim.defer_fn(start_lsps_stealth, 1)
