-- ============================================================
-- DAP — depurador (nvim-dap + dap-ui + mason-nvim-dap). Enfocado
-- en Go via delve; extiende `ensure_installed` para otros langs.
-- Atajos en keybinds.lua.
-- ============================================================

vim.pack.add {
  'https://github.com/mfussenegger/nvim-dap',
  'https://github.com/rcarriga/nvim-dap-ui',
  'https://github.com/nvim-neotest/nvim-nio',
  'https://github.com/jay-babu/mason-nvim-dap.nvim',
  'https://github.com/leoluz/nvim-dap-go',
}

local dap = require 'dap'
local dapui = require 'dapui'

require('mason-nvim-dap').setup {
  automatic_installation = true, -- intenta configurar los debuggers instalados
  handlers = {},
  ensure_installed = { 'delve' },
}

---@diagnostic disable-next-line: missing-fields
dapui.setup {
  icons = { expanded = '▾', collapsed = '▸', current_frame = '*' },
  ---@diagnostic disable-next-line: missing-fields
  controls = {
    icons = {
      pause = '⏸',
      play = '▶',
      step_into = '⏎',
      step_over = '⏭',
      step_out = '⏮',
      step_back = 'b',
      run_last = '▶▶',
      terminate = '⏹',
      disconnect = '⏏',
    },
  },
}

dap.listeners.after.event_initialized['dapui_config'] = dapui.open
dap.listeners.before.event_terminated['dapui_config'] = dapui.close
dap.listeners.before.event_exited['dapui_config'] = dapui.close

require('dap-go').setup {
  delve = {
    -- En Windows delve debe correr attached o crashea.
    detached = vim.fn.has 'win32' == 0,
  },
}
