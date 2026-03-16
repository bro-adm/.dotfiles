return {
    "mason-org/mason-lspconfig.nvim",
    lazy = false,
    opts = {
        ensure_installed = { "lua_ls", "rust_analyzer", "gopls" },
    },
    dependencies = {
        { "mason-org/mason.nvim", opts = {} },
        "neovim/nvim-lspconfig",
    },
}
