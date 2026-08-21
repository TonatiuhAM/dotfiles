vim.pack.add({
  'https://github.com/daedlock/matugen.nvim',
})

-- Al ejecutarse directamente tras vim.pack.add(), garantizas
-- la prioridad alta (se aplica antes del resto de la UI)
require('matugen').setup({
  colors_path = vim.fs.normalize('~/.config/matugen/generated/nvim-colors.json'),
})

-- [[ Colores de mini.statusline (barra inferior) ]]
-- matugen.nvim no define los grupos MiniStatuslineMode* (solo tiene los de
-- Mini.files), así que mini.statusline cae a su propio valor por defecto
-- (MiniStatuslineModeNormal -> link a "Cursor"), que queda fijo y no sigue
-- el wallpaper. Con paletas claras (accent claro) el texto queda claro
-- sobre claro y se pierde, como en la captura. Aquí los re-enlazamos a la
-- paleta viva -- texto oscuro (bg) sobre el color de acento, el mismo
-- criterio que usa el helper `.lualine()` que trae el propio plugin -- y
-- los refrescamos cada vez que matugen recarga colores (cambio de
-- wallpaper, :MatugenReload, :MatugenBrightness, :MatugenContrast).
local function apply_statusline_colors()
  local palette = require('matugen').get_palette()
  if not palette then return end

  local function mode_hl(bg) return { fg = palette.bg, bg = bg, bold = true } end

  vim.api.nvim_set_hl(0, 'MiniStatuslineModeNormal', mode_hl(palette.accent))
  vim.api.nvim_set_hl(0, 'MiniStatuslineModeInsert', mode_hl(palette.green))
  vim.api.nvim_set_hl(0, 'MiniStatuslineModeVisual', mode_hl(palette.magenta))
  vim.api.nvim_set_hl(0, 'MiniStatuslineModeReplace', mode_hl(palette.red))
  vim.api.nvim_set_hl(0, 'MiniStatuslineModeCommand', mode_hl(palette.orange))
  vim.api.nvim_set_hl(0, 'MiniStatuslineModeOther', mode_hl(palette.cyan))
end

-- Registrado antes de `colorscheme` para capturar también la carga inicial
-- (matugen.load() dispara este evento "User" de forma síncrona).
vim.api.nvim_create_autocmd('User', {
  pattern = 'MatugenReloaded',
  callback = apply_statusline_colors,
})

vim.cmd.colorscheme('matugen')
