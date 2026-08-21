vim.pack.add {
  'https://github.com/folke/snacks.nvim',
}

require('snacks').setup {
  bigfile = { enabled = true },
  indent = { enabled = true },
  input = { enabled = false },
  quickfile = { enabled = true },
  scope = { enabled = false },
  scroll = { enabled = true },
  statuscolumn = { enabled = false },
  words = { enabled = false },

  notifier = {
    enabled = true,
    timeout = 3000,
  },

  -- Dashboard personalizado sin dependencia de lazy.stats
  dashboard = {
    enabled = true,
    -- Definimos explícitamente las secciones a renderizar
    sections = {
      { section = 'header' },
      { section = 'keys', gap = 1, padding = 1 },
      { section = 'recent_files', icon = ' ', title = 'Recent Files', indent = 2, padding = 1 },
      { section = 'projects', icon = ' ', title = 'Projects', indent = 2, padding = 1 },
      -- En lugar de { section = "startup" }, usamos un texto estático o lo omitimos:
      {
        align = 'center',
        padding = 1,
        text = {
          { 'Neovim listo', hl = 'Comment' },
        },
      },
    },
    preset = {
      header = [[
    ██╗████████╗ ██████╗ ███╗   ██╗ █████╗ 
   ██╔╝╚══██╔══╝██╔═══██╗████╗  ██║██╔══██╗
  ██╔╝    ██║   ██║   ██║██╔██╗ ██║███████║
 ██╔╝     ██║   ██║   ██║██║╚██╗██║██╔══██║
██╔╝      ██║   ╚██████╔╝██║ ╚████║██║  ██║
╚═╝       ╚═╝    ╚═════╝ ╚═╝  ╚═══╝╚═╝  ╚═╝
]],
      keys = {
        { icon = ' ', key = 'f', desc = 'Find File', action = ":lua Snacks.dashboard.pick('files')" },
        { icon = ' ', key = 'n', desc = 'New File', action = ':ene | startinsert' },
        { icon = ' ', key = 'g', desc = 'Find Text', action = ":lua Snacks.dashboard.pick('live_grep')" },
        { icon = ' ', key = 'r', desc = 'Recent Files', action = ":lua Snacks.dashboard.pick('oldfiles')" },
        { icon = ' ', key = 'c', desc = 'Config', action = ":lua Snacks.dashboard.pick('files', {cwd = vim.fn.stdpath('config')})" },
        { icon = ' ', key = 's', desc = 'Restore Session', section = 'session' },
        { icon = ' ', key = 'q', desc = 'Quit', action = ':qa' },
      },
    },
  },

  -- Configuración de Pickers
  picker = {
    enabled = true,
    sources = {
      explorer = { enabled = false },
    },
  },

  -- Módulos deshabilitados
  explorer = {
    enabled = false,
    replace_netrw = false,
  },
  gh = { enabled = false },
  gitbrowse = { enabled = false },
  terminal = { enabled = false },
  zen = { enabled = false },
}

-- 2. Depuración global
_G.dd = function(...) Snacks.debug.inspect(...) end
_G.bt = function() Snacks.debug.backtrace() end

if vim.fn.has 'nvim-0.11' == 1 then
  vim._print = function(_, ...) dd(...) end
else
  vim.print = _G.dd
end

Snacks.toggle.diagnostics():map '<leader>ud'
Snacks.toggle.option('conceallevel', { off = 0, on = vim.o.conceallevel > 0 and vim.o.conceallevel or 2 }):map '<leader>uc'
Snacks.toggle.indent():map '<leader>ug'
vim.keymap.set('n', '<leader>nn', function() Snacks.picker.notifications() end, { desc = 'Notification History' })

-- Find
vim.keymap.set('n', '<leader>sb', function() Snacks.picker.buffers() end, { desc = '[S]earch [B]uffers' })
-- vim.keymap.set("n", "<leader>ff", function() Snacks.picker.files() end, { desc = "Find Files" })
-- vim.keymap.set("n", "<leader>fg", function() Snacks.picker.git_files() end, { desc = "Find Git Files" })
-- vim.keymap.set("n", "<leader>fp", function() Snacks.picker.projects() end, { desc = "Projects" })
-- vim.keymap.set("n", "<leader>fr", function() Snacks.picker.recent() end, { desc = "Recent" })

-- Git
vim.keymap.set('n', '<leader>gb', function() Snacks.picker.git_branches() end, { desc = 'Git Branches' })
vim.keymap.set('n', '<leader>gl', function() Snacks.picker.git_log() end, { desc = 'Git Log' })
vim.keymap.set('n', '<leader>gL', function() Snacks.picker.git_log_line() end, { desc = 'Git Log Line' })
vim.keymap.set('n', '<leader>gs', function() Snacks.picker.git_status() end, { desc = 'Git Status' })
vim.keymap.set('n', '<leader>gS', function() Snacks.picker.git_stash() end, { desc = 'Git Stash' })
vim.keymap.set('n', '<leader>gd', function() Snacks.picker.git_diff() end, { desc = 'Git Diff (Hunks)' })
vim.keymap.set('n', '<leader>gf', function() Snacks.picker.git_log_file() end, { desc = 'Git Log File' })
vim.keymap.set('n', '<leader>gg', function() Snacks.lazygit() end, { desc = 'Lazygit' })

-- LSP Pickers
-- vim.keymap.set("n", "gd", function() Snacks.picker.lsp_definitions() end, { desc = "Goto Definition" })
-- vim.keymap.set("n", "gD", function() Snacks.picker.lsp_declarations() end, { desc = "Goto Declaration" })
-- vim.keymap.set("n", "gr", function() Snacks.picker.lsp_references() end, { nowait = true, desc = "References" })
-- vim.keymap.set("n", "gI", function() Snacks.picker.lsp_implementations() end, { desc = "Goto Implementation" })
-- vim.keymap.set("n", "gy", function() Snacks.picker.lsp_type_definitions() end, { desc = "Goto T[y]pe Definition" })
-- vim.keymap.set("n", "gai", function() Snacks.picker.lsp_incoming_calls() end, { desc = "C[a]lls Incoming" })
-- vim.keymap.set("n", "gao", function() Snacks.picker.lsp_outgoing_calls() end, { desc = "C[a]lls Outgoing" })
-- vim.keymap.set("n", "<leader>ss", function() Snacks.picker.lsp_symbols() end, { desc = "LSP Symbols" })
-- vim.keymap.set("n", "<leader>sS", function() Snacks.picker.lsp_workspace_symbols() end, { desc = "LSP Workspace Symbols" })
