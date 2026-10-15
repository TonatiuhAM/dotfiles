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
vim.o.winborder = "rounded"

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

local function set_markdown_styles()
  -- Negrita en markdown
  local bold_opts = { fg = '#f38ba8', bold = true }
  vim.api.nvim_set_hl(0, '@markup.strong', bold_opts)
  vim.api.nvim_set_hl(0, '@markup.strong.markdown_inline', bold_opts)
  vim.api.nvim_set_hl(0, 'markdownBold', bold_opts)
  vim.api.nvim_set_hl(0, 'htmlBold', bold_opts)

  -- Resaltado estilo marca-textos para ==subrayado== (render-markdown.nvim)
  local highlight_mark = {
    bg = '#89b4fa',
    fg = '#1e1e2e', -- Color de texto oscuro para que contraste bien con el fondo
    bold = true,
  }

  -- Sobrescribimos el grupo de render-markdown rompiendo el enlace por defecto
  vim.api.nvim_set_hl(0, 'RenderMarkdownInlineHighlight', highlight_mark)

  -- Encabezados
  for level = 1, 6 do
    local group = '@markup.heading.' .. level .. '.markdown'
    local ok, hl = pcall(vim.api.nvim_get_hl, 0, { name = group, link = false })
    if ok then
      hl.bold = true
      vim.api.nvim_set_hl(0, group, hl)
    end
  end
end

set_markdown_styles()

vim.api.nvim_create_autocmd('ColorScheme', {
  group = vim.api.nvim_create_augroup('CustomMarkdownStyles', { clear = true }),
  callback = set_markdown_styles,
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

-- Big files: desactiva features costosas por buffer.
local bigfile_group = vim.api.nvim_create_augroup('BigFileDisable', { clear = true })

vim.api.nvim_create_autocmd('BufReadPre', {
  group = bigfile_group,
  callback = function(args)
    local max_size = 1.5 * 1024 * 1024 -- 1.5 MB
    local file = args.file
    if not file or file == '' then return end

    local ok, stat = pcall(vim.uv.fs_stat, file)
    if not (ok and stat and stat.size > max_size) then return end

    vim.b[args.buf].bigfile = true

    -- Opciones locales al buffer/ventana
    vim.bo[args.buf].swapfile = false
    vim.bo[args.buf].undolevels = -1
    vim.bo[args.buf].wrap = false

    if vim.api.nvim_get_current_buf() == args.buf then
      vim.wo.foldmethod = 'manual'
      vim.cmd 'syntax off'
    else
      vim.api.nvim_create_autocmd('BufEnter', {
        group = bigfile_group,
        buffer = args.buf,
        once = true,
        callback = function()
          vim.wo.foldmethod = 'manual'
          vim.cmd 'syntax off'
        end,
      })
    end

    -- Treesitter solo en este buffer
    vim.api.nvim_create_autocmd('BufEnter', {
      group = bigfile_group,
      buffer = args.buf,
      once = true,
      callback = function()
        local ok_ts, parser = pcall(vim.treesitter.get_parser, args.buf)
        if ok_ts and parser then pcall(vim.treesitter.stop, args.buf) end
      end,
    })
  end,
})
