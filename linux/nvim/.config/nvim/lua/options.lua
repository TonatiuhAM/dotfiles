-- ============================================================
-- OPTIONS
-- Corresponde a init.lua SECTION 1 (ajustes core, leaders, opciones),
-- SECTION 7 (formateo con conform.nvim) y SECTION 8 (autocompletado
-- y snippets con blink.cmp + LuaSnip).
--
-- Aquí vive toda la configuración general de Neovim que NO son
-- keymaps: opciones (`vim.o`/`vim.opt`), diagnósticos, autocomandos
-- básicos y el setup (sin atajos) de los plugins de formateo y
-- autocompletado.
--
-- Los keymaps que originalmente acompañaban a estas secciones
-- (p. ej. `<leader>f` para formatear) se movieron a keymaps.lua.
-- ============================================================

-- Enable faster startup by caching compiled Lua modules
vim.loader.enable()

-- Set <space> as the leader key
-- See `:help mapleader`
--  NOTE: Must happen before plugins are loaded (otherwise wrong leader will be used)
vim.g.mapleader = ' '
vim.g.maplocalleader = ','

-- Set to true if you have a Nerd Font installed and selected in the terminal
vim.g.have_nerd_font = true

-- [[ Setting options ]]
--  See `:help vim.o`
-- NOTE: You can change these options as you wish!
--  For more options, you can see `:help option-list`

-- Make line numbers default
vim.o.number = true
vim.o.relativenumber = true

-- Enable mouse mode, can be useful for resizing splits for example!
vim.o.mouse = 'a'

-- Don't show the mode, since it's already in the status line
vim.o.showmode = false

-- Sync clipboard between OS and Neovim.
--  Schedule the setting after `UiEnter` because it can increase startup-time.
--  Remove this option if you want your OS clipboard to remain independent.
--  See `:help 'clipboard'`
vim.schedule(function() vim.o.clipboard = 'unnamedplus' end)

-- Enable break indent
vim.o.breakindent = true

-- Enable undo/redo changes even after closing and reopening a file
vim.o.undofile = true

-- Case-insensitive searching UNLESS \C or one or more capital letters in the search term
vim.o.ignorecase = true
vim.o.smartcase = true

-- Keep signcolumn on by default
vim.o.signcolumn = 'yes'

-- Decrease update time
vim.o.updatetime = 250

-- Decrease mapped sequence wait time
vim.o.timeoutlen = 300

-- Configure how new splits should be opened
vim.o.splitright = true
vim.o.splitbelow = true

vim.g.loaded_netrw = 1
vim.g.loaded_netrwPLugin = 1

-- Sets how neovim will display certain whitespace characters in the editor.
--  See `:help 'list'`
--  and `:help 'listchars'`
--
--  Notice listchars is set using `vim.opt` instead of `vim.o`.
--  It is very similar to `vim.o` but offers an interface for conveniently interacting with tables.
--   See `:help lua-options`
--   and `:help lua-guide-options`
vim.o.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }

-- Hide the "~" markers shown on empty lines past the end of the buffer
vim.opt.fillchars:append { eob = ' ' }

-- Preview substitutions live, as you type!
vim.o.inccommand = 'split'

-- Show which line your cursor is on
vim.o.cursorline = true

-- Minimal number of screen lines to keep above and below the cursor.
vim.o.scrolloff = 10

-- if performing an operation that would fail due to unsaved changes in the buffer (like `:q`),
-- instead raise a dialog asking if you wish to save the current file(s)
-- See `:help 'confirm'`
vim.o.confirm = true

-- [[ Diagnostics ]]
--  See `:help vim.diagnostic.Opts`
vim.diagnostic.config {
  update_in_insert = false,
  severity_sort = true,
  float = { border = 'rounded', source = 'if_many' },
  underline = { severity = { min = vim.diagnostic.severity.WARN } },

  -- Can switch between these as you prefer
  virtual_text = true, -- Text shows up at the end of the line
  virtual_lines = false, -- Text shows up underneath the line, with virtual lines

  -- Auto open the float, so you can easily read the errors when jumping with `[d` and `]d`
  jump = {
    on_jump = function(_, bufnr)
      vim.diagnostic.open_float {
        bufnr = bufnr,
        scope = 'cursor',
        focus = false,
      }
    end,
  },
}

-- [[ Basic Autocommands ]]
--  See `:help lua-guide-autocommands`

-- Highlight when yanking (copying) text
--  Try it with `yap` in normal mode
--  See `:help vim.hl.on_yank()`
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function() vim.hl.on_yank() end,
})

---Helper local para construir URLs de GitHub para `vim.pack.add`.
---Se repite en cada archivo que instala plugins (mismo patrón que
---ya usan los archivos de lua/custom/plugins/*.lua).
---@param repo string
---@return string
local function gh(repo) return 'https://github.com/' .. repo end

-- ============================================================
-- init.lua SECTION 7: FORMATTING — conform.nvim
-- ============================================================
vim.pack.add { gh 'stevearc/conform.nvim' }
require('conform').setup {
  notify_on_error = false,
  format_on_save = function(bufnr)
    -- You can specify filetypes to autoformat on save here:
    local enabled_filetypes = {
      -- lua = true,
      -- python = true,
    }
    if enabled_filetypes[vim.bo[bufnr].filetype] then
      return { timeout_ms = 500 }
    else
      return nil
    end
  end,
  default_format_opts = {
    lsp_format = 'fallback', -- Use external formatters if configured below, otherwise use LSP formatting. Set to `false` to disable LSP formatting entirely.
  },
  -- You can also specify external formatters in here.
  formatters_by_ft = {
    -- rust = { 'rustfmt' },
    -- Conform can also run multiple formatters sequentially
    -- python = { "isort", "black" },
    --
    -- You can use 'stop_after_first' to run the first available formatter from the list
    -- javascript = { "prettierd", "prettier", stop_after_first = true },
  },
}
-- NOTE: El keymap `<leader>f` para formatear vive en keymaps.lua.

-- ============================================================
-- init.lua SECTION 8: AUTOCOMPLETE & SNIPPETS — blink.cmp, LuaSnip
-- ============================================================
-- [[ Snippet Engine ]]

-- NOTE: You can also specify plugin using a version range for its git tag.
--  See `:help vim.version.range()` for more info
vim.pack.add { { src = gh 'L3MON4D3/LuaSnip', version = vim.version.range '2.*' } }
require('luasnip').setup {}

-- `friendly-snippets` contains a variety of premade snippets.
--    See the README about individual language/framework/plugin snippets:
--    https://github.com/rafamadriz/friendly-snippets
--
-- vim.pack.add { gh 'rafamadriz/friendly-snippets' }
-- require('luasnip.loaders.from_vscode').lazy_load()

-- [[ Autocomplete Engine ]]
vim.pack.add { { src = gh 'saghen/blink.cmp', version = vim.version.range '1.*' } }
require('blink.cmp').setup {
  keymap = {
    -- 'default' (recommended) for mappings similar to built-in completions
    --   <c-y> to accept ([y]es) the completion.
    --    This will auto-import if your LSP supports it.
    --    This will expand snippets if the LSP sent a snippet.
    -- 'super-tab' for tab to accept
    -- 'enter' for enter to accept
    -- 'none' for no mappings
    --
    -- For an understanding of why the 'default' preset is recommended,
    -- you will need to read `:help ins-completion`
    --
    -- All presets have the following mappings:
    -- <tab>/<s-tab>: move to right/left of your snippet expansion
    -- <c-space>: Open menu or open docs if already open
    -- <c-n>/<c-p> or <up>/<down>: Select next/previous item
    -- <c-e>: Hide menu
    -- <c-k>: Toggle signature help
    --
    -- See `:help blink-cmp-config-keymap` for defining your own keymap
    preset = 'default',
  },

  appearance = {
    -- 'mono' (default) for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
    -- Adjusts spacing to ensure icons are aligned
    nerd_font_variant = 'mono',
  },

  completion = {
    -- By default, you may press `<c-space>` to show the documentation.
    -- Optionally, set `auto_show = true` to show the documentation after a delay.
    documentation = { auto_show = false, auto_show_delay_ms = 500 },
  },

  sources = {
    default = { 'lsp', 'path', 'snippets', 'buffer', 'copilot' },
    providers = {
      copilot = {
        name = 'copilot',
        module = 'blink-copilot',
        score_offset = 100, -- prioriza las sugerencias de IA en el menú
        async = true,
      },
    },
  },

  snippets = { preset = 'luasnip' },

  -- Blink.cmp includes an optional, recommended rust fuzzy matcher,
  -- which automatically downloads a prebuilt binary when enabled.
  --
  -- By default, we use the Lua implementation instead, but you may enable
  -- the rust implementation via `'prefer_rust_with_warning'`
  --
  -- See `:help blink-cmp-config-fuzzy` for more information
  fuzzy = { implementation = 'lua' },

  -- Shows a signature help window while you type arguments for a function
  signature = { enabled = true },
}

vim.api.nvim_create_autocmd("FileType", {
  pattern = "markdown",
  callback = function(args)
    vim.diagnostic.enable(false, { bufnr = args.buf })
  end,
})

local function set_markdown_bold()
  local highlight_opts = {
    fg = "#FFD700", -- Cambia por el color HEX que prefieras
    bold = true,
  }

  -- Treesitter (Neovim 0.8+)
  vim.api.nvim_set_hl(0, "@markup.strong", highlight_opts)
  vim.api.nvim_set_hl(0, "@markup.strong.markdown_inline", highlight_opts)

  -- Sintaxis clásica de Vim / Markdown integrado
  vim.api.nvim_set_hl(0, "markdownBold", highlight_opts)
  vim.api.nvim_set_hl(0, "htmlBold", highlight_opts)
end

-- Ejecutarlo al cargar la config
set_markdown_bold()

-- Asegurar que persista si cambias de tema
vim.api.nvim_create_autocmd("ColorScheme", {
  group = vim.api.nvim_create_augroup("CustomMarkdownBold", { clear = true }),
  callback = set_markdown_bold,
})
