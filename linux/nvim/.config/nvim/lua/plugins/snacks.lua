vim.pack.add {
  'https://github.com/folke/snacks.nvim',
}

require('snacks').setup {
  bigfile = { enabled = true },
  indent = { enabled = true },
  input = { enabled = false },
  quickfile = { enabled = true },
  scope = { enabled = false },
  scroll = { enabled = false },
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

-- Depuración global. Atajos (toggles, pickers) en keybinds.lua.
_G.dd = function(...) Snacks.debug.inspect(...) end
_G.bt = function() Snacks.debug.backtrace() end

if vim.fn.has 'nvim-0.11' == 1 then
  vim._print = function(_, ...) dd(...) end
else
  vim.print = _G.dd
end

-- LSP Pickers (deshabilitado, se usan los de Telescope en su lugar)
-- vim.keymap.set("n", "gd", function() Snacks.picker.lsp_definitions() end, { desc = "Goto Definition" })
-- vim.keymap.set("n", "gD", function() Snacks.picker.lsp_declarations() end, { desc = "Goto Declaration" })
-- vim.keymap.set("n", "gr", function() Snacks.picker.lsp_references() end, { nowait = true, desc = "References" })
-- vim.keymap.set("n", "gI", function() Snacks.picker.lsp_implementations() end, { desc = "Goto Implementation" })
-- vim.keymap.set("n", "gy", function() Snacks.picker.lsp_type_definitions() end, { desc = "Goto T[y]pe Definition" })
-- vim.keymap.set("n", "gai", function() Snacks.picker.lsp_incoming_calls() end, { desc = "C[a]lls Incoming" })
-- vim.keymap.set("n", "gao", function() Snacks.picker.lsp_outgoing_calls() end, { desc = "C[a]lls Outgoing" })
-- vim.keymap.set("n", "<leader>ss", function() Snacks.picker.lsp_symbols() end, { desc = "LSP Symbols" })
-- vim.keymap.set("n", "<leader>sS", function() Snacks.picker.lsp_workspace_symbols() end, { desc = "LSP Workspace Symbols" })
