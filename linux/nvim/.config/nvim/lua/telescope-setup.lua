-- ============================================================
-- TELESCOPE — fuzzy finder. Atajos en keybinds.lua.
-- ============================================================

---@type (string|vim.pack.Spec)[]
local telescope_plugins = {
  'https://github.com/nvim-lua/plenary.nvim',
  'https://github.com/nvim-telescope/telescope.nvim',
  'https://github.com/nvim-telescope/telescope-ui-select.nvim',
}
if vim.fn.executable 'make' == 1 then table.insert(telescope_plugins, 'https://github.com/nvim-telescope/telescope-fzf-native.nvim') end
vim.pack.add(telescope_plugins)

require('telescope').setup {
  defaults = {
    vimgrep_arguments = {
      'rg',
      '--color=never',
      '--no-heading',
      '--with-filename',
      '--line-number',
      '--column',
      '--smart-case',
      '--hidden',          -- incluye archivos/carpetas ocultas
      '--glob=!**/.git/*', -- ignora la base de datos interna de .git
    },
  },
  extensions = {
    ['ui-select'] = require('telescope.themes').get_dropdown(),
  },
}

pcall(require('telescope').load_extension, 'fzf')
pcall(require('telescope').load_extension, 'ui-select')
