-- ============================================================
-- KEYBINDS — todos los atajos de teclado del config, en un solo
-- lugar, agrupados por plugin/acción. Excepciones (atadas al
-- callback de setup del propio plugin, no se pueden centralizar):
--   - gitsigns (hunks)   → git.lua, dentro de `on_attach`
--   - markdown-plus      → plugins/markdown-plus.lua
-- ============================================================

-- ============================
-- [[ Básicos ]]
-- ============================
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')
vim.keymap.set({ 'n', 'v' }, 'ñ', ':', { noremap = true, desc = 'Abrir línea de comandos' })
vim.keymap.set({ 'n', 'v' }, 'Ñ', ';', { noremap = true, desc = 'Abrir línea de comandos' })
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })

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

-- Conform 
vim.keymap.set({ 'n', 'v' }, '<leader>F', function() require('conform').format { async = true } end, { desc = '[F]ormat buffer' })

-- Explorador de archivos 
vim.keymap.set('n', '<leader>e', ":Oil --float<CR>", { desc = 'File [E]xplorer (Oil)' })

vim.keymap.set('n', '<C-n>', function() MiniNotify.show_history() end, { desc = '[N]otification [H]istory' })

vim.keymap.set('x', '<Tab>', '>gv', { desc = 'Indent selection right' })
vim.keymap.set('x', '<S-Tab>', '<gv', { desc = 'Indent selection left' })

vim.keymap.set('n', '<A-j>', '<cmd>m .+1<cr>==', { desc = 'Mover línea abajo' })
vim.keymap.set('n', '<A-k>', '<cmd>m .-2<cr>==', { desc = 'Mover línea arriba' })
vim.keymap.set('i', '<A-j>', '<esc><cmd>m .+1<cr>==gi', { desc = 'Mover línea abajo' })
vim.keymap.set('i', '<A-k>', '<esc><cmd>m .-2<cr>==gi', { desc = 'Mover línea arriba' })
vim.keymap.set('v', '<A-j>', ":m '>+1<CR>gv=gv", { desc = 'Mover selección abajo' })
vim.keymap.set('v', '<A-k>', ":m '<-2<CR>gv=gv", { desc = 'Mover selección arriba' })

vim.keymap.set('n', '<leader><Space>', function()
  local current_file = vim.api.nvim_buf_get_name(0)
  local dir = current_file ~= '' and vim.fn.fnamemodify(current_file, ':p:h') or vim.fn.getcwd()

  if not (vim.env.TMUX and vim.env.TMUX ~= '') then
    vim.notify('No estas dentro de una sesion tmux.', vim.log.levels.WARN)
    return
  end

  local out = vim.fn.system({ 'tmux', 'new-window', '-c', dir })
  if vim.v.shell_error ~= 0 then
    vim.notify('No pude crear la nueva window en tmux: ' .. out, vim.log.levels.ERROR)
  end
end, { silent = true, desc = 'Nueva window tmux en directorio del archivo' })

-- Buffers
vim.keymap.set("n", "<S-k>", ":bnext<CR>", { desc = "Buffer siguiente" })
vim.keymap.set("n", "<S-j>", ":bprevious<CR>", { desc = "Buffer anterior" })
vim.keymap.set("n", "<C-b>d", ":bdelete<CR>", { desc = "Delete Buffer" })
vim.keymap.set("n", "<C-b>n", ":enew<CR>", { desc = "New empty buffer" })

-- Función para limpiar los plugins no utilizados
local function pack_clean()
  local active_plugins = {}
  local unused_plugins = {}

  for _, plugin in ipairs(vim.pack.get()) do
    active_plugins[plugin.spec.name] = plugin.active
  end

  for _, plugin in ipairs(vim.pack.get()) do
    if not active_plugins[plugin.spec.name] then
      table.insert(unused_plugins, plugin.spec.name)
    end
  end

  if #unused_plugins == 0 then
    print("No unused plugins.")
    return
  end

  -- Preguntar uno por uno
  for _, name in ipairs(unused_plugins) do
    local msg = string.format("Remove unused plugin '%s'?", name)
    local choice = vim.fn.confirm(msg, "&Yes\n&No\n&Cancel", 2)

    if choice == 1 then
      vim.pack.del({ name })
      print("Removed: " .. name)
    elseif choice == 3 then
      print("Cleanup cancelled.")
      break
    end
  end
end

vim.api.nvim_create_user_command('PackClean', pack_clean, {
  desc = 'Limpiar plugins en desuso',
})

-- Smart Picker
local function smart_picker()
  local cwd = vim.fn.getcwd()
  local cwd_pattern = '^' .. vim.pesc(cwd) .. '/'
  local seen = {}
  local items = {}

  local function add_item(path)
    if not path or path == '' then return end
    -- Normalizar a ruta relativa si está dentro del cwd
    local rel = path:gsub(cwd_pattern, '')
    -- Verificar si existe el archivo (usando la ruta absoluta o relativa válida)
    local full_path = rel:sub(1, 1) == '/' and rel or (cwd .. '/' .. rel)
    if not seen[rel] and vim.fn.filereadable(full_path) == 1 then
      seen[rel] = true
      table.insert(items, rel)
    end
  end

  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(buf) and vim.bo[buf].buflisted then
      local name = vim.api.nvim_buf_get_name(buf)
      add_item(name)
    end
  end

  for _, file in ipairs(vim.v.oldfiles or {}) do
    if file:find(cwd_pattern) then
      add_item(file)
    end
  end

  local fd_cmd = { 'fd', '--type', 'f', '--hidden', '--exclude', '.git' }
  local all_files = vim.fn.systemlist(fd_cmd)
  if vim.v.shell_error == 0 then
    for _, file in ipairs(all_files) do
      add_item(file)
    end
  end

  MiniPick.start({
    source = {
      items = items,
      name = 'Smart Files',
      show = function(buf_id, items_to_show, query)
        MiniPick.default_show(buf_id, items_to_show, query, { show_icons = true })
      end,
    },
  })
end

vim.keymap.set('n', '<C-p>', smart_picker, { desc = 'Buscar archivos' })

vim.api.nvim_create_autocmd('FileType', {
  group = vim.api.nvim_create_augroup('keybinds-starter-smart-picker', { clear = true }),
  pattern = 'ministarter',
  callback = function()
    local buf = vim.api.nvim_get_current_buf()

    vim.schedule(function()
      if not vim.api.nvim_buf_is_valid(buf) then return end
      vim.keymap.set('n', '<C-p>', function()
        MiniStarter.close()
        vim.schedule(smart_picker)
      end, {
        buffer = buf,
        nowait = true,
        silent = true,
        desc = 'Starter: Buscar archivos',
      })
    end)
  end,
})


-- ============================
-- [[ Picker ]]
-- ============================
vim.keymap.set('n', '<leader>ff', function()
  MiniPick.builtin.cli({
    command = { 'fd', '--type', 'f', '--hidden', '--exclude', '.git' },
  }, {
    source = {
      name = 'Files (hidden)',
    },
  })
end, { desc = '[F]ind [F]iles' })

vim.keymap.set('n', '<leader>fg', function()
  MiniPick.builtin.grep_live()
end, { desc = '[F]ind by [G]rep' })

-- NOTE: DIAGNOSTICS
vim.keymap.set('n', '<leader>fd', function()
  MiniExtra.pickers.diagnostic({ scope = 'all' })
end, { desc = '[F]ind [D]iagnostics' })

vim.keymap.set('n', '<leader>fr', function()
  MiniExtra.pickers.oldfiles()
end, { desc = '[F]ind [R]ecent Files' })

vim.keymap.set('n', '<leader>/', function()
  MiniExtra.pickers.buf_lines({ scope = 'current' })
end, { desc = '[/] Fuzzily search in current buffer' })

vim.keymap.set('n', '<leader>f/', function()
  MiniExtra.pickers.buf_lines({ scope = 'all' })
end, { desc = '[F]ind [/] in Open Files' })

vim.keymap.set('n', '<leader>fn', function()
  local config_dir = vim.fn.stdpath('config')
  local tool = vim.fn.executable('fd') == 1 and 'fd' or 'find'
  local post = tool == 'fd' and { '--follow' } or { '-L' }

  MiniPick.builtin.files(
    { tool = tool, post = post },
    { source = { cwd = config_dir, name = 'Neovim Config' } }
  )
end, { desc = '[F]ind [N]eovim files' })

vim.keymap.set('n', '<leader>fm', function()
  MiniExtra.pickers.marks()
end, { desc = '[F]ind Marks' })

vim.keymap.set('n', '<leader>fb', function() MiniPick.builtin.files() end, { desc = '[F]ind [B]uffers' })


-- ============================
-- [[ LSP ]]
-- ============================
-- Pickers LSP: si cambias de picker plugin, aquí es donde se actualiza.
vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('telescope-lsp-attach', { clear = true }),
  callback = function(event)
    local buf = event.buf
    vim.keymap.set('n', 'grr', function() MiniExtra.pickers.lsp({ scope = 'references' }) end, { buffer = buf, desc = '[G]oto [R]eferences' })
    vim.keymap.set('n', 'gri', function() MiniExtra.pickers.lsp({ scope = 'implementation' }) end, { buffer = buf, desc = '[G]oto [I]mplementation' })
    vim.keymap.set('n', 'grd', function() MiniExtra.pickers.lsp({ scope = 'definition' }) end, { buffer = buf, desc = '[G]oto [D]efinition' })
    vim.keymap.set('n', 'gO',  function() MiniExtra.pickers.lsp({ scope = 'document_symbol' }) end, { buffer = buf, desc = 'Open Document Symbols' })
    vim.keymap.set('n', 'gW',  function() MiniExtra.pickers.lsp({ scope = 'workspace_symbol' }) end, { buffer = buf, desc = 'Open Workspace Symbols' })
    vim.keymap.set('n', 'grt', function() MiniExtra.pickers.lsp({ scope = 'type_definition' }) end, { buffer = buf, desc = '[G]oto [T]ype Definition' })  end,
})

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


-- ============================
-- [[ DAP ]]
-- ============================
vim.keymap.set('n', '<F5>', function() require('dap').continue() end, { desc = 'Debug: Start/Continue' })
vim.keymap.set('n', '<F1>', function() require('dap').step_into() end, { desc = 'Debug: Step Into' })
vim.keymap.set('n', '<F2>', function() require('dap').step_over() end, { desc = 'Debug: Step Over' })
vim.keymap.set('n', '<F3>', function() require('dap').step_out() end, { desc = 'Debug: Step Out' })
vim.keymap.set('n', '<leader>tb', function() require('dap').toggle_breakpoint() end, { desc = 'Debug: Toggle Breakpoint' })
vim.keymap.set('n', '<leader>B', function() require('dap').set_breakpoint(vim.fn.input 'Breakpoint condition: ') end, { desc = 'Debug: Set Breakpoint' })
vim.keymap.set('n', '<F7>', function() require('dapui').toggle() end, { desc = 'Debug: See last session result.' }) -- ve el output tras una excepción no manejada



-- ============================
-- [[ Neoscroll ]]
-- ============================
local neoscroll_keys = {
  ['<C-u>'] = function() require('neoscroll').ctrl_u { duration = 250, post_hook = function() vim.cmd 'normal! zz' end } end,
  ['<C-d>'] = function() require('neoscroll').ctrl_d { duration = 250, post_hook = function() vim.cmd 'normal! zz' end } end,
  ['<C-f>'] = function() require('neoscroll').ctrl_f { duration = 350, post_hook = function() vim.cmd 'normal! zz' end } end,
}
for key, func in pairs(neoscroll_keys) do
  vim.keymap.set({ 'n', 'v', 'x' }, key, func, { desc = 'Scroll suave centrado' })
end

vim.keymap.set('n', '<leader>ud', function()
  vim.diagnostic.enable(not vim.diagnostic.is_enabled())
end, { desc = 'Toggle Diagnostics' })

vim.keymap.set('n', '<leader>uc', function()
  local current = vim.wo.conceallevel
  vim.wo.conceallevel = current > 0 and 0 or 2
  vim.notify('conceallevel: ' .. vim.wo.conceallevel)
end, { desc = 'Toggle Conceallevel' })


-- ============================
-- [[ Git ]]
-- ============================
-- Los keymaps de gitsigns (hunks) viven en git.lua, dentro de `on_attach` — son
-- locales al buffer y la API del plugin los exige ahí, no se centralizan aquí.
vim.keymap.set('n', '<leader>gb', function() MiniExtra.pickers.git_branches() end, { desc = 'Git Branches' })

local function open_lazygit()
  -- Dimensiones: 90% del ancho y alto de la pantalla
  local width = math.floor(vim.o.columns * 0.9)
  local height = math.floor(vim.o.lines * 0.9)
  local row = math.floor((vim.o.lines - height) / 2)
  local col = math.floor((vim.o.columns - width) / 2)

  -- Crear buffer no listado y ventana flotante
  local buf = vim.api.nvim_create_buf(false, true)
  local win = vim.api.nvim_open_win(buf, true, {
    relative = 'editor',
    width = width,
    height = height,
    row = row,
    col = col,
    style = 'minimal',
    border = 'rounded',
  })

  -- Lanzar lazygit dentro de la terminal
  vim.fn.termopen('lazygit', {
    on_exit = function()
      if vim.api.nvim_win_is_valid(win) then
        vim.api.nvim_win_close(win, true)
      end
      if vim.api.nvim_buf_is_valid(buf) then
        vim.api.nvim_buf_delete(buf, { force = true })
      end
    end,
  })

  -- Entrar en modo inserción directamente para interactuar con lazygit
  vim.cmd('startinsert')
end

vim.keymap.set('n', '<leader>gg', open_lazygit, { desc = 'Lazygit' })


-- ============================
-- [[ Notas/Neowiki ]]
-- ============================
vim.keymap.set('n', '<leader>ww', function() require('neowiki').open_wiki() end, { desc = 'Open Wiki' })
vim.keymap.set('n', '<leader>wW', function() require('neowiki').open_wiki_floating() end, { desc = 'Open Wiki in Floating Window' })

-- Función para busqueda de tags en notas
local notes_dir = vim.fn.expand("~/documents/notas/") -- Cambia por la ruta real a tu carpeta de notas

local function pick_notes_by_tag()
  -- Usamos PCRE2 (-P):
  -- (?<=^|\s)       -> Debe tener un espacio antes o estar al inicio de línea (evita URLs)
  -- #[a-zA-Z][\w-]* -> Debe empezar con '#' seguido obligatoriamente de una letra (evita #123 o encabezados Markdown '# ')
  local cmd = {
    "rg",
    "-P",
    "--no-filename",
    "--only-matching",
    "--no-heading",
    "-e", "(?<=^|\\s)#[a-zA-Z][\\w-]*",
    notes_dir,
  }

  local output = vim.fn.systemlist(cmd)

  if vim.v.shell_error ~= 0 or #output == 0 then
    vim.notify("No se encontraron etiquetas válidas en " .. notes_dir, vim.log.levels.WARN)
    return
  end

  local seen = {}
  local tags = {}

  for _, raw_tag in ipairs(output) do
    local tag = vim.trim(raw_tag)

    local is_hex_color = tag:match("^#[0-9a-fA-F]+$") and (#tag == 4 or #tag == 7 or #tag == 9)

    if not is_hex_color and not seen[tag] then
      seen[tag] = true
      table.insert(tags, tag)
    end
  end

  table.sort(tags)

  MiniPick.start({
    source = {
      items = tags,
      name = "Etiquetas de Notas",
      choose = function(selected_tag)
        if not selected_tag then return end

        vim.schedule(function()
          MiniPick.builtin.grep({
            pattern = selected_tag,
          }, {
            source = {
              cwd = notes_dir,
              name = "Notas con: " .. selected_tag,
            },
          })
        end)
      end,
    },
  })
end

-- Keymap para invocar el selector de tags
vim.keymap.set("n", "<leader>wT", pick_notes_by_tag, { desc = "Listar y buscar por etiqueta (mini.pick)" })
