vim.pack.add { 'https://github.com/folke/which-key.nvim' }

require('which-key').setup {
  delay = 0,
  icons = { mappings = vim.g.have_nerd_font },
  spec = {
    { '<leader>f', group = '[F]ind', mode = { 'n', 'v' } },
    { '<leader>t', group = '[T]oggle' },
    { '<leader>h', group = 'Git [H]unk', mode = { 'n', 'v' } },
    { 'gr', group = 'LSP Actions', mode = { 'n' } },
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
