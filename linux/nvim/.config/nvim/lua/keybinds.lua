-- ============================================================
-- KEYBINDS — todos los atajos de teclado del config, en un solo
-- lugar, agrupados por plugin/acción. Excepciones (atadas al
-- callback de setup del propio plugin, no se pueden centralizar):
--   - gitsigns (hunks)   → git.lua, dentro de `on_attach`
--   - markdown-plus      → plugins/markdown-plus.lua
-- ============================================================

-- [[ Básicos ]]
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })
vim.keymap.set({ 'n', 'v' }, 'ñ', ':', { noremap = true, desc = 'Abrir línea de comandos' })
vim.keymap.set({ 'n', 'v' }, 'Ñ', ';', { noremap = true, desc = 'Abrir línea de comandos' })

vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })

vim.keymap.set('n', '<C-S-h>', '<C-w>H', { desc = 'Move window to the left' })
vim.keymap.set('n', '<C-S-l>', '<C-w>L', { desc = 'Move window to the right' })
vim.keymap.set('n', '<C-S-j>', '<C-w>J', { desc = 'Move window to the lower' })
vim.keymap.set('n', '<C-S-k>', '<C-w>K', { desc = 'Move window to the upper' })

vim.keymap.set('x', 'p', [["_dP]]) -- pega sin sobreescribir el registro
vim.keymap.set('n', 'n', 'nzzzv')
vim.keymap.set('n', 'N', 'Nzzzv')

vim.keymap.set('n', '<leader>fR', [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]], { desc = '[F]ind and [r]eplace' })
vim.keymap.set('i', 'jk', '<Esc>', { noremap = true, silent = true })

vim.keymap.set('n', '<C-p>', ':Telescope find_files hidden=true<CR>', { desc = 'Buscar archivos' })

vim.keymap.set('x', '<Tab>', '>gv', { desc = 'Indent selection right' }) -- fix para teclados no-US
vim.keymap.set('x', '<S-Tab>', '<gv', { desc = 'Indent selection left' })

vim.keymap.set('n', '<A-j>', '<cmd>m .+1<cr>==', { desc = 'Mover línea abajo' })
vim.keymap.set('n', '<A-k>', '<cmd>m .-2<cr>==', { desc = 'Mover línea arriba' })
vim.keymap.set('i', '<A-j>', '<esc><cmd>m .+1<cr>==gi', { desc = 'Mover línea abajo' })
vim.keymap.set('i', '<A-k>', '<esc><cmd>m .-2<cr>==gi', { desc = 'Mover línea arriba' })
vim.keymap.set('v', '<A-j>', ":m '>+1<CR>gv=gv", { desc = 'Mover selección abajo' })
vim.keymap.set('v', '<A-k>', ":m '<-2<CR>gv=gv", { desc = 'Mover selección arriba' })

vim.keymap.set('n', '<leader>nt', function()
  local dir = vim.fn.expand '%:p:h'
  vim.fn.jobstart({ 'setsid', '-f', 'alacritty', '--working-directory', dir }, { detach = true })
end, { silent = true, desc = 'Abrir Alacritty aquí' })

-- [[ Telescope ]]
local builtin = require 'telescope.builtin'
vim.keymap.set('n', '<leader>fh', builtin.help_tags, { desc = '[F]ind [H]elp' })
vim.keymap.set('n', '<leader>fk', builtin.keymaps, { desc = '[F]ind [K]eymaps' })
vim.keymap.set('n', '<leader>ff', ':Telescope find_files hidden=true<CR>', { desc = '[F]ind [F]iles' })
vim.keymap.set('n', '<leader>fs', builtin.builtin, { desc = '[F]ind [S]elect Telescope' })
vim.keymap.set({ 'n', 'v' }, '<leader>fw', builtin.grep_string, { desc = '[F]ind current [W]ord' })
vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = '[F]ind by [G]rep' })
vim.keymap.set('n', '<leader>fd', builtin.diagnostics, { desc = '[F]ind [D]iagnostics' })
vim.keymap.set('n', '<leader>f.', builtin.oldfiles, { desc = '[F]ind Recent Files ("." for repeat)' })
vim.keymap.set('n', '<leader>fc', builtin.commands, { desc = '[F]ind [C]ommands' })

vim.keymap.set('n', '<leader>/', function()
  builtin.current_buffer_fuzzy_find(require('telescope.themes').get_dropdown { winblend = 10, previewer = false })
end, { desc = '[/] Fuzzily search in current buffer' })

vim.keymap.set('n', '<leader>f/', function()
  builtin.live_grep { grep_open_files = true, prompt_title = 'Live Grep in Open Files' }
end, { desc = '[F]ind [/] in Open Files' })

vim.keymap.set('n', '<leader>fn', function() builtin.find_files { cwd = vim.fn.stdpath 'config', follow = true } end, { desc = '[F]ind [N]eovim files' })

-- Pickers LSP: si cambias de picker plugin, aquí es donde se actualiza.
vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('telescope-lsp-attach', { clear = true }),
  callback = function(event)
    local buf = event.buf
    vim.keymap.set('n', 'grr', builtin.lsp_references, { buffer = buf, desc = '[G]oto [R]eferences' })
    vim.keymap.set('n', 'gri', builtin.lsp_implementations, { buffer = buf, desc = '[G]oto [I]mplementation' })
    vim.keymap.set('n', 'grd', builtin.lsp_definitions, { buffer = buf, desc = '[G]oto [D]efinition' })
    vim.keymap.set('n', 'gO', builtin.lsp_document_symbols, { buffer = buf, desc = 'Open Document Symbols' })
    vim.keymap.set('n', 'gW', builtin.lsp_dynamic_workspace_symbols, { buffer = buf, desc = 'Open Workspace Symbols' })
    vim.keymap.set('n', 'grt', builtin.lsp_type_definitions, { buffer = buf, desc = '[G]oto [T]ype Definition' })
  end,
})

-- [[ LSP ]]
vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('keymaps-lsp-attach', { clear = true }),
  callback = function(event)
    local function map(keys, func, desc, mode)
      vim.keymap.set(mode or 'n', keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
    end

    map('grn', vim.lsp.buf.rename, '[R]e[n]ame')
    map('gra', vim.lsp.buf.code_action, '[G]oto Code [A]ction', { 'n', 'x' })
    map('grD', vim.lsp.buf.declaration, '[G]oto [D]eclaration') -- WARN: Declaration, no Definition

    local client = vim.lsp.get_client_by_id(event.data.client_id)
    if client and client:supports_method('textDocument/inlayHint', event.buf) then
      map('<leader>th', function() vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf }) end, '[T]oggle Inlay [H]ints')
    end
  end,
})

-- [[ Conform ]]
vim.keymap.set({ 'n', 'v' }, '<leader>F', function() require('conform').format { async = true } end, { desc = '[F]ormat buffer' })

-- [[ Git ]]
-- Los keymaps de gitsigns (hunks) viven en git.lua, dentro de `on_attach` — son
-- locales al buffer y la API del plugin los exige ahí, no se centralizan aquí.

-- [[ DAP ]]
vim.keymap.set('n', '<F5>', function() require('dap').continue() end, { desc = 'Debug: Start/Continue' })
vim.keymap.set('n', '<F1>', function() require('dap').step_into() end, { desc = 'Debug: Step Into' })
vim.keymap.set('n', '<F2>', function() require('dap').step_over() end, { desc = 'Debug: Step Over' })
vim.keymap.set('n', '<F3>', function() require('dap').step_out() end, { desc = 'Debug: Step Out' })
vim.keymap.set('n', '<leader>b', function() require('dap').toggle_breakpoint() end, { desc = 'Debug: Toggle Breakpoint' })
vim.keymap.set('n', '<leader>B', function() require('dap').set_breakpoint(vim.fn.input 'Breakpoint condition: ') end, { desc = 'Debug: Set Breakpoint' })
vim.keymap.set('n', '<F7>', function() require('dapui').toggle() end, { desc = 'Debug: See last session result.' }) -- ve el output tras una excepción no manejada

-- [[ Explorador de archivos ]]
-- vim.keymap.set('n', '<leader>e', function() require('yazi').yazi() end, { desc = 'File [E]xplorer (Yazi)' })
vim.keymap.set('n', '<leader>e', ":Oil --float<CR>", { desc = 'File [E]xplorer (Oil)' })

-- [[ Neowiki ]]
vim.keymap.set('n', '<leader>ww', function() require('neowiki').open_wiki() end, { desc = 'Open Wiki' })
vim.keymap.set('n', '<leader>wW', function() require('neowiki').open_wiki_floating() end, { desc = 'Open Wiki in Floating Window' })
vim.keymap.set('n', '<leader>wT', function() require('neowiki').open_wiki_new_tab() end, { desc = 'Open Wiki in Tab' })

-- [[ Neoscroll ]]
local neoscroll_keys = {
  ['<C-u>'] = function() require('neoscroll').ctrl_u { duration = 250, post_hook = function() vim.cmd 'normal! zz' end } end,
  ['<C-d>'] = function() require('neoscroll').ctrl_d { duration = 250, post_hook = function() vim.cmd 'normal! zz' end } end,
  ['<C-b>'] = function() require('neoscroll').ctrl_b { duration = 350, post_hook = function() vim.cmd 'normal! zz' end } end,
  ['<C-f>'] = function() require('neoscroll').ctrl_f { duration = 350, post_hook = function() vim.cmd 'normal! zz' end } end,
}
for key, func in pairs(neoscroll_keys) do
  vim.keymap.set({ 'n', 'v', 'x' }, key, func, { desc = 'Scroll suave centrado' })
end

-- [[ Snacks ]]
Snacks.toggle.diagnostics():map '<leader>ud'
Snacks.toggle.option('conceallevel', { off = 0, on = vim.o.conceallevel > 0 and vim.o.conceallevel or 2 }):map '<leader>uc'
Snacks.toggle.indent():map '<leader>ug'
vim.keymap.set('n', '<leader>nn', function() Snacks.picker.notifications() end, { desc = 'Notification History' })

-- Find
vim.keymap.set('n', '<leader>fb', function() Snacks.picker.buffers() end, { desc = '[F]ind [B]uffers' })
vim.keymap.set('n', '<leader>fr', function() Snacks.picker.recent() end, { desc = '[F]ind [R]ecents' })

-- Git
vim.keymap.set('n', '<leader>gb', function() Snacks.picker.git_branches() end, { desc = 'Git Branches' })
vim.keymap.set('n', '<leader>gl', function() Snacks.picker.git_log() end, { desc = 'Git Log' })
vim.keymap.set('n', '<leader>gL', function() Snacks.picker.git_log_line() end, { desc = 'Git Log Line' })
vim.keymap.set('n', '<leader>gs', function() Snacks.picker.git_status() end, { desc = 'Git Status' })
vim.keymap.set('n', '<leader>gS', function() Snacks.picker.git_stash() end, { desc = 'Git Stash' })
vim.keymap.set('n', '<leader>gd', function() Snacks.picker.git_diff() end, { desc = 'Git Diff (Hunks)' })
vim.keymap.set('n', '<leader>gf', function() Snacks.picker.git_log_file() end, { desc = 'Git Log File' })
vim.keymap.set('n', '<leader>gg', function() Snacks.lazygit() end, { desc = 'Lazygit' })

-- [[ Markdown-plus ]]
-- Sus keymaps son locales al buffer y viven en plugins/markdown-plus.lua,
-- dentro del callback FileType que hace el lazy-install del plugin.

-- [[ Notas / misceláneo ]]
vim.keymap.set(
  'n',
  '<leader>wn',
  function() vim.cmd('edit ' .. vim.fn.fnameescape '/home/tona/documents/notas/bullet-journal.md') end,
  { desc = 'Abrir Bullet Journal' }
)

-- [[ Comandos ]]
vim.api.nvim_create_user_command('LastEdit', function()
  local mark = vim.api.nvim_buf_get_mark(0, '.')
  local line_count = vim.api.nvim_buf_line_count(0)
  if mark[1] > 0 and mark[1] <= line_count then
    vim.api.nvim_win_set_cursor(0, mark)
  else
    vim.notify('No hay cambios registrados en este buffer.', vim.log.levels.WARN)
  end
end, { desc = 'Saltar al último cambio realizado en el archivo' })
