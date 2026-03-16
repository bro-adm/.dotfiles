-- [nfnl] fnl/init.fnl
vim.notify("Fennel config has loaded successfully!", vim.log.levels.INFO)
require("editor")
require("tools")
return require("keys")
