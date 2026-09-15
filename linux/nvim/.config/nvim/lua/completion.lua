-- ============================================================
-- COMPLETION — LuaSnip (snippets) + blink.cmp (autocompletado).
-- ============================================================

-- [[ LuaSnip ]]
vim.pack.add { { src = 'https://github.com/L3MON4D3/LuaSnip', version = vim.version.range '2.*' } }
require('luasnip').setup {}

-- friendly-snippets (deshabilitado):
-- vim.pack.add { 'https://github.com/rafamadriz/friendly-snippets' }
-- require('luasnip.loaders.from_vscode').lazy_load()

-- [[ blink.cmp ]]
vim.pack.add { { src = 'https://github.com/saghen/blink.cmp', version = vim.version.range '1.*' } }
require('blink.cmp').setup {
  keymap = { preset = 'default' }, -- ver `:help blink-cmp-config-keymap`
  appearance = { nerd_font_variant = 'mono' },
  completion = { documentation = { auto_show = false, auto_show_delay_ms = 500 } },

  sources = {
    default = { 'lsp', 'path', 'snippets', 'buffer', 'copilot' },
    providers = {
      copilot = {
        name = 'copilot',
        module = 'blink-copilot', -- plugin instalado en plugins/copilot.lua
        score_offset = 100,       -- prioriza las sugerencias de IA en el menú
        async = true,
      },
    },
  },

  snippets = { preset = 'luasnip' },
  fuzzy = { implementation = 'prefer_rust_with_warning' }, -- alternativa: 'lua'
  signature = { enabled = true },

  -- Cmdline (":") desactivado: choca con vim._core.ui2 (tiny-cmdline.lua) y se
  -- queda en "Loading...". El autocompletado del cmdline lo cubre mini.cmdline
  -- (plugins/mini-cmdline.lua), que trabaja sobre el wildmenu nativo en vez de
  -- pasar por la fuente async 'cmdline' de blink.
  cmdline = { enabled = false },
}
