vim.pack.add({
  'https://github.com/catppuccin/nvim',
})

require('catppuccin').setup({
  flavour = 'macchiato',
})

-- No se activa aquí: lo decide `current_theme.lua` (ver init.lua).
