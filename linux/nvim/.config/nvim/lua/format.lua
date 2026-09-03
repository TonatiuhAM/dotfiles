-- ============================================================
-- FORMAT — conform.nvim. Atajo `<leader>F` en keybinds.lua.
-- ============================================================

vim.pack.add { 'https://github.com/stevearc/conform.nvim' }

require('conform').setup {
  notify_on_error = false,
  format_on_save = function(bufnr)
    local enabled_filetypes = {
      -- lua = true,
      -- python = true,
    }
    if enabled_filetypes[vim.bo[bufnr].filetype] then return { timeout_ms = 500 } end
    return nil
  end,
  default_format_opts = {
    lsp_format = 'fallback', -- usa formatters externos si están abajo; si no, LSP. `false` para desactivar LSP formatting
  },
  formatters_by_ft = {
    -- rust = { 'rustfmt' },
    -- python = { "isort", "black" }, -- corre en secuencia
    -- javascript = { "prettierd", "prettier", stop_after_first = true },
  },
}
