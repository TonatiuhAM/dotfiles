-- ============================================================
-- MODULE LOADING
--
-- Esta configuración está modularizada en lua/*.lua. El orden de
-- carga importa:
--   1. options  - vim.g.mapleader/maplocalleader y opciones generales
--                 DEBEN cargarse antes que cualquier plugin o keymap.
--   2. plugins  - instala y configura los plugins (incluye Telescope,
--                 cuyo módulo usan los keymaps del paso 3).
--   3. keymaps  - todos los atajos de teclado del config, agrupados
--                 por acción/plugin.
--   4. lsp      - servidores LSP, Mason y Treesitter.
--
-- Ver cada archivo para el detalle de a qué SECTION del init.lua
-- original de kickstart.nvim corresponde cada bloque.
-- ============================================================
require 'options'
require 'plugins'
require 'keymaps'
require 'lsp'

-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et
