-- ============================================================
-- MODULE LOADING — el orden importa (ver cada archivo para el
-- porqué de su posición: dependencias de mini.icons, build hooks
-- de vim.pack, mason, etc).
-- ============================================================
require 'options'
require 'pack'
require 'mini'
require 'treesitter'
require 'telescope-setup' -- (no "telescope": choca con el módulo del propio plugin)
require 'completion'
require 'format'
require 'lsp'
require 'git'
require 'dap-setup' -- (no "dap": choca con el módulo del propio plugin)
require 'plugins' -- plugins sin dependencia de orden (lua/plugins/*.lua)
require 'keybinds'

-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et
