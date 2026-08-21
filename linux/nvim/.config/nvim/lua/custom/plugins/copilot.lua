-- GitHub Copilot como fuente de blink.cmp (ver `sources.providers.copilot`
-- en options.lua). El panel/ghost-text propio de copilot.lua se deja
-- desactivado porque las sugerencias se muestran dentro del menú de
-- blink.cmp en vez de como overlay independiente.
vim.pack.add({
  'https://github.com/zbirenbaum/copilot.lua',
  'https://github.com/fang2hou/blink-copilot',
})

require('copilot').setup({
  suggestion = { enabled = false },
  panel = { enabled = false },
})
