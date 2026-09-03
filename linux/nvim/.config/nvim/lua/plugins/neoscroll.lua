-- Atajos en keybinds.lua.
vim.pack.add {
  'https://github.com/karb94/neoscroll.nvim',
}

require('neoscroll').setup {
  mappings = {},
  hide_cursor = false,
  stop_eof = true,
  respect_scrolloff = false,
  cursor_scrolls_alone = true,
  easing = 'quadratic',
}
