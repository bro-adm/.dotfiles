require("config.options")
require("config.keymaps")
require("config.lazy")

vim.opt.termguicolors = true

vim.schedule(function()
  vim.keymap.set({ "n", "v", "o" }, "?", "<Nop>", { silent = true, noremap = true, desc = "Disabled search" })
end)
