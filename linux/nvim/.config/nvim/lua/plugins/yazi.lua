-- Atajos en keybinds.lua.
vim.pack.add {
  'https://github.com/nvim-lua/plenary.nvim',
  'https://github.com/mikavilpas/yazi.nvim',
}

require('yazi').setup {
  open_for_directories = true,
  keymaps = { show_help = '<f1>' },
}
