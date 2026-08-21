local gh = function(repo) return 'https://github.com/' .. repo end

vim.pack.add({
  gh('nvim-lua/plenary.nvim'),
  gh('mikavilpas/yazi.nvim'),
})

local yazi = require('yazi')

yazi.setup({
  open_for_directories = true,
  keymaps = {
    show_help = '<f1>',
  },
})

vim.keymap.set('n', '<leader>e', function()
  yazi.yazi()
end, { desc = 'File [E]xplorer (Yazi)' })
