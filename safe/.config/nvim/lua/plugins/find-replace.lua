return {
  'MagicDuck/grug-far.nvim',
  -- Note (lazy loading): grug-far.lua defers all it's requires so it's lazy by default
  -- additional lazy config to defer loading is not really needed...
  config = function()
    require('grug-far').setup({});

    vim.keymap.set({ 'n', 'x' }, '<leader>fr', function()
  	require('grug-far').open({ visualSelectionUsage = 'operate-within-range' })
    end, { desc = 'grug-far: Search within range' })
  end,
}
