-- ============================================================
-- OPTIONS — ajustes core de Neovim (vim.o/vim.opt, diagnostics,
-- autocomandos nativos). Nada de plugins aquí.
-- ============================================================

vim.loader.enable()

-- [[ Leaders ]]
-- NOTE: Debe ir antes que cualquier plugin/keymap.
vim.g.mapleader = ' '
vim.g.maplocalleader = ','
vim.g.have_nerd_font = true

-- [[ Opciones generales ]]
vim.o.wrap = false

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "markdown", "md" },
  callback = function()
    vim.opt_local.wrap = true
  end,
})

vim.o.number = true
vim.o.relativenumber = true
vim.o.mouse = 'a'
vim.o.showmode = false -- ya vive en la statusline

vim.schedule(function() vim.o.clipboard = 'unnamedplus' end) -- tras UiEnter: evita penalizar el startup

vim.o.breakindent = true
vim.o.undofile = true
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.signcolumn = 'yes'
vim.o.updatetime = 250
vim.o.timeoutlen = 300
vim.o.splitright = true
vim.o.splitbelow = true

vim.g.loaded_netrw = 1
vim.g.loaded_netrwPLugin = 1

vim.o.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }
vim.opt.fillchars:append { eob = ' ' } -- oculta los "~" en líneas vacías

vim.o.inccommand = 'split'
vim.o.cursorline = true
vim.o.scrolloff = 10
vim.o.confirm = true

vim.opt.path:append '**'
vim.opt.wildmenu = true

-- [[ Diagnostics ]]
vim.diagnostic.config {
  update_in_insert = false,
  severity_sort = true,
  float = { border = 'rounded', source = 'if_many' },
  underline = { severity = { min = vim.diagnostic.severity.WARN } },
  virtual_text = true,
  virtual_lines = false,
  jump = {
    on_jump = function(_, bufnr)
      vim.diagnostic.open_float { bufnr = bufnr, scope = 'cursor', focus = false }
    end,
  },
}

vim.api.nvim_create_autocmd('FileType', {
  pattern = 'markdown',
  callback = function(args) vim.diagnostic.enable(false, { bufnr = args.buf }) end,
})

-- [[ Autocomandos básicos ]]

vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function() vim.hl.on_yank() end,
})

-- Negrita en markdown: matugen no define estos grupos, así que se fijan aquí y se
-- reaplican en cada cambio de colorscheme.
local function set_markdown_bold()
  local highlight_opts = { fg = '#FFD700', bold = true }
  vim.api.nvim_set_hl(0, '@markup.strong', highlight_opts)
  vim.api.nvim_set_hl(0, '@markup.strong.markdown_inline', highlight_opts)
  vim.api.nvim_set_hl(0, 'markdownBold', highlight_opts)
  vim.api.nvim_set_hl(0, 'htmlBold', highlight_opts)
end
set_markdown_bold()
vim.api.nvim_create_autocmd('ColorScheme', {
  group = vim.api.nvim_create_augroup('CustomMarkdownBold', { clear = true }),
  callback = set_markdown_bold,
})

vim.api.nvim_create_autocmd('BufReadPost', {
  desc = 'Ir a la última posición donde se dejó el modo insert',
  group = vim.api.nvim_create_augroup('RestoreInsertPosition', { clear = true }),
  callback = function(args)
    if vim.bo[args.buf].buftype ~= '' or vim.bo[args.buf].filetype == 'gitcommit' then return end
    local mark = vim.api.nvim_buf_get_mark(args.buf, '"')
    local line_count = vim.api.nvim_buf_line_count(args.buf)
    if mark[1] > 0 and mark[1] <= line_count then pcall(vim.api.nvim_win_set_cursor, 0, mark) end
  end,
})

-- Auto-cd a la raíz del proyecto (primer marcador encontrado hacia arriba)
local root_markers = { '.here', '.root', '.git', 'Makefile', 'package.json', 'Cargo.toml', 'pyproject.toml' }
vim.api.nvim_create_autocmd('BufEnter', {
  group = vim.api.nvim_create_augroup('AutoProjectRoot', { clear = true }),
  pattern = '*',
  callback = function(ctx)
    if vim.bo[ctx.buf].buftype ~= '' or ctx.file == '' then return end
    local root = vim.fs.root(ctx.buf, root_markers)
    if root and root ~= vim.fn.getcwd() then vim.fn.chdir(root) end
  end,
})
