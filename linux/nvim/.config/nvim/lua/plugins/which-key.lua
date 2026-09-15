vim.pack.add { 'https://github.com/folke/which-key.nvim' }

require('which-key').setup {
  delay = 0,
  icons = { mappings = vim.g.have_nerd_font },
  spec = {
    { '<leader>f', group = '[F]ind', mode = { 'n', 'v' } },
    { '<leader>t', group = '[T]oggle' },
    { '<leader>h', group = 'Git [H]unk', mode = { 'n', 'v' } },
    { '<leader>b', group = '[B]uffers', mode = { 'n', 'v' } },
    { 'gr', group = 'LSP Actions', mode = { 'n' } },
    { '<localleader>l', group = '[L]ist', mode = { 'n', 'v' } },
    { '<localleader>lt', group = '[T]oggle', mode = { 'n', 'v' } },
    { '<localleader>m', group = '[M]arkdown text', mode = { 'n', 'v' } },
    { '<localleader>h', group = '[H]eaders and TOC', mode = { 'n', 'v' } },
    { '<localleader>mQ', group = '[Q]uotes and callouts', mode = { 'n', 'v' } },
    { '<localleader>f', group = '[F]ootnotes', mode = { 'n', 'v' } },
    { '<localleader>t', group = '[T]ables', mode = { 'n', 'v' } },
  },
  win = {
    no_overlap = false,
    border = 'rounded',
    padding = { 1, 2 },
    col = -1,                      -- anclado al borde derecho
    row = -1,                      -- anclado abajo a la derecha
    width = { min = 1, max = 70 }, -- 25% del ancho de pantalla
    height = { min = 1, max = 55 },
  },
  layout = {
    cols = 1, -- 1 sola columna vertical
    spacing = 1,
  },
}
