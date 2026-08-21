-- ============================================================
-- KEYMAPS
-- Todos los atajos de teclado de init.lua viven aquí, agrupados por
-- acción/plugin:
--   - Atajos básicos (antigua SECTION 2)
--   - Atajos de Telescope, incluyendo sus pickers de LSP
--     (antigua SECTION 5)
--   - Atajos "core" de LSP: rename, code action, declaration,
--     inlay hints (extraídos del autocomando LspAttach de la
--     antigua SECTION 6 — la lógica que NO es un keymap, como los
--     autocomandos de document-highlight, se quedó en lsp.lua)
--   - Atajo de formateo de conform.nvim (antigua SECTION 7)
--
-- La instalación/`.setup()` de estos plugins vive en options.lua,
-- plugins.lua o lsp.lua según corresponda.
-- ============================================================

-- Clear highlights on search when pressing <Esc> in normal mode
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

-- Open diagnostic quickfix list (config de diagnósticos en options.lua)
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })

--  Use CTRL+<hjkl> to switch between windows
vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })

vim.keymap.set("n", "<C-S-h>", "<C-w>H", { desc = "Move window to the left" })
vim.keymap.set("n", "<C-S-l>", "<C-w>L", { desc = "Move window to the right" })
vim.keymap.set("n", "<C-S-j>", "<C-w>J", { desc = "Move window to the lower" })
vim.keymap.set("n", "<C-S-k>", "<C-w>K", { desc = "Move window to the upper" })

-- Reemplaza la selección en modo visual sin sobreescribir el registro
vim.keymap.set("x", "p", [["_dP]])

vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")

vim.keymap.set("n", "<leader>sr", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]], { desc = "[S]earch and [r]eplace"})

-- Atajo para abrir mi archivo de notas diarias
vim.keymap.set("n", "<leader>wn", function()
  vim.cmd("edit " .. vim.fn.fnameescape("/home/tona/documents/notas/bullet-journal.md"))
end, { desc = "Abrir Bullet Journal" })

-- Busqueda de archivos con Telescope usando Ctrl-p
vim.keymap.set("n", "<C-p>", ":Telescope find_files<CR>", { desc = "Buscar archivos" })

-- Solución para la indentación en modo visual con teclados no-US
vim.keymap.set("x", "<Tab>", ">gv", { desc = "Indent selection right" })
vim.keymap.set("x", "<S-Tab>", "<gv", { desc = "Indent selection left" })

-- Modo Normal: Mueve la línea actual
vim.keymap.set('n', '<A-j>', '<cmd>m .+1<cr>==', { desc = 'Mover línea abajo' })
vim.keymap.set('n', '<A-k>', '<cmd>m .-2<cr>==', { desc = 'Mover línea arriba' })

-- Modo Insert: Mueve la línea actual desde el modo de inserción
vim.keymap.set('i', '<A-j>', '<esc><cmd>m .+1<cr>==gi', { desc = 'Mover línea abajo' })
vim.keymap.set('i', '<A-k>', '<esc><cmd>m .-2<cr>==gi', { desc = 'Mover línea arriba' })

-- Modo Visual: Mueve el bloque seleccionado y mantiene la selección e indentación
vim.keymap.set('v', '<A-j>', ":m '>+1<CR>gv=gv", { desc = 'Mover selección abajo' })
vim.keymap.set('v', '<A-k>', ":m '<-2<CR>gv=gv", { desc = 'Mover selección arriba' })

-- Abrir Alacritty en el directorio del archivo actual con Leader + n + t
vim.keymap.set("n", "<leader>nt", function()
  local dir = vim.fn.expand("%:p:h")
  vim.fn.jobstart({ "setsid", "-f", "alacritty", "--working-directory", dir }, { detach = true })
end, { silent = true, desc = "Abrir Alacritty aquí" })

-- [[ Telescope keymaps ]]
local builtin = require 'telescope.builtin'
vim.keymap.set('n', '<leader>sh', builtin.help_tags, { desc = '[S]earch [H]elp' })
vim.keymap.set('n', '<leader>sk', builtin.keymaps, { desc = '[S]earch [K]eymaps' })
vim.keymap.set('n', '<leader>sf', builtin.find_files, { desc = '[S]earch [F]iles' })
vim.keymap.set('n', '<leader>ss', builtin.builtin, { desc = '[S]earch [S]elect Telescope' })
vim.keymap.set({ 'n', 'v' }, '<leader>sw', builtin.grep_string, { desc = '[S]earch current [W]ord' })
vim.keymap.set('n', '<leader>sg', builtin.live_grep, { desc = '[S]earch by [G]rep' })
vim.keymap.set('n', '<leader>sd', builtin.diagnostics, { desc = '[S]earch [D]iagnostics' })
-- vim.keymap.set('n', '<leader>sr', builtin.resume, { desc = '[S]earch [R]esume' })
vim.keymap.set('n', '<leader>s.', builtin.oldfiles, { desc = '[S]earch Recent Files ("." for repeat)' })
vim.keymap.set('n', '<leader>sc', builtin.commands, { desc = '[S]earch [C]ommands' })

vim.keymap.set("n", "<leader>sc", function()
  require("telescope.builtin").find_files({
    cwd = vim.fn.stdpath("config"),
  })
end, { desc = "[S]earch [C]onfig" })

vim.keymap.set("n", "<leader>sC", function()
  require("telescope.builtin").find_files({
    cwd = vim.fn.expand("~/.config"),
    hidden = true,
    follow = true,
  })
end, { desc = "Buscar archivos en ~/.config" })

-- Override default behavior and theme when searching
vim.keymap.set('n', '<leader>/', function()
  -- You can pass additional configuration to Telescope to change the theme, layout, etc.
  builtin.current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
    winblend = 10,
    previewer = false,
  })
end, { desc = '[/] Fuzzily search in current buffer' })

-- It's also possible to pass additional configuration options.
--  See `:help telescope.builtin.live_grep()` for information about particular keys
vim.keymap.set(
  'n',
  '<leader>s/',
  function()
    builtin.live_grep {
      grep_open_files = true,
      prompt_title = 'Live Grep in Open Files',
    }
  end,
  { desc = '[S]earch [/] in Open Files' }
)

-- Shortcut for searching your Neovim configuration files
vim.keymap.set('n', '<leader>sn', function() builtin.find_files { cwd = vim.fn.stdpath 'config', follow = true } end, { desc = '[S]earch [N]eovim files' })

-- Add Telescope-based LSP pickers when an LSP attaches to a buffer.
-- If you later switch picker plugins, this is where to update these mappings.
vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('telescope-lsp-attach', { clear = true }),
  callback = function(event)
    local buf = event.buf

    -- Find references for the word under your cursor.
    vim.keymap.set('n', 'grr', builtin.lsp_references, { buffer = buf, desc = '[G]oto [R]eferences' })

    -- Jump to the implementation of the word under your cursor.
    vim.keymap.set('n', 'gri', builtin.lsp_implementations, { buffer = buf, desc = '[G]oto [I]mplementation' })

    -- Jump to the definition of the word under your cursor.
    vim.keymap.set('n', 'grd', builtin.lsp_definitions, { buffer = buf, desc = '[G]oto [D]efinition' })

    -- Fuzzy find all the symbols in your current document.
    vim.keymap.set('n', 'gO', builtin.lsp_document_symbols, { buffer = buf, desc = 'Open Document Symbols' })

    -- Fuzzy find all the symbols in your current workspace.
    vim.keymap.set('n', 'gW', builtin.lsp_dynamic_workspace_symbols, { buffer = buf, desc = 'Open Workspace Symbols' })

    -- Jump to the type of the word under your cursor.
    vim.keymap.set('n', 'grt', builtin.lsp_type_definitions, { buffer = buf, desc = '[G]oto [T]ype Definition' })
  end,
})

-- [[ Core LSP keymaps ]]
--  Extraídos del autocomando LspAttach de la antigua SECTION 6.
--  La lógica que NO es un keymap (autocomandos de document-highlight
--  al mover el cursor) permanece en lsp.lua, en su propio autocomando
--  LspAttach independiente de este.
vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('keymaps-lsp-attach', { clear = true }),
  callback = function(event)
    -- Helper local para atajos con buffer y descripción "LSP: ..."
    local map = function(keys, func, desc, mode)
      mode = mode or 'n'
      vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
    end

    -- Rename the variable under your cursor.
    map('grn', vim.lsp.buf.rename, '[R]e[n]ame')

    -- Execute a code action, usually your cursor needs to be on top of an error
    -- or a suggestion from your LSP for this to activate.
    map('gra', vim.lsp.buf.code_action, '[G]oto Code [A]ction', { 'n', 'x' })

    -- WARN: This is not Goto Definition, this is Goto Declaration.
    map('grD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')

    -- Toggle inlay hints, solo si el servidor LSP los soporta.
    local client = vim.lsp.get_client_by_id(event.data.client_id)
    if client and client:supports_method('textDocument/inlayHint', event.buf) then
      map('<leader>th', function() vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf }) end, '[T]oggle Inlay [H]ints')
    end
  end,
})

-- [[ conform.nvim keymap ]]
--  El plugin se instala/configura en options.lua.
vim.keymap.set({ 'n', 'v' }, '<leader>f', function() require('conform').format { async = true } end, { desc = '[F]ormat buffer' })
