-- ============================================================
-- MINI.NVIM — icons, textobjects, surround, statusline.
-- ============================================================

vim.pack.add { 'https://github.com/nvim-mini/mini.nvim' }

-- [[ mini.icons ]]
-- Debe cargar antes que Telescope: mockea nvim-web-devicons para
-- plugins que aún dependen de esa API.
if vim.g.have_nerd_font then
  require('mini.icons').setup()
  MiniIcons.mock_nvim_web_devicons()
end

-- [[ mini.ai ]] — Better Around/Inside textobjects
-- va)  [V]isually select [A]round [)]paren · yiiq [Y]ank [I]nside [I]+1 [Q]uote · ci' [C]hange [I]nside [']quote
require('mini.ai').setup {
  mappings = { around_next = 'aa', inside_next = 'ii' }, -- evita choque con incremental-selection nativo
  n_lines = 500,
}

-- [[ mini.surround ]] — saiw) [S]urround [A]dd [I]nner [W]ord · sd' [S]urround [D]elete · sr)' [S]urround [R]eplace
require('mini.surround').setup()

-- [[ mini.statusline ]]
local statusline = require 'mini.statusline'
statusline.setup { use_icons = vim.g.have_nerd_font }
---@diagnostic disable-next-line: duplicate-set-field
statusline.section_location = function() return '%2l:%-2v' end
