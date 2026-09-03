-- ============================================================
-- LSP — fidget, Mason (instalación de servidores/tools) y
-- configuración de servidores. Atajos LSP en keybinds.lua.
-- ============================================================

vim.pack.add { 'https://github.com/j-hui/fidget.nvim' }
require('fidget').setup {}

-- Document-highlight al reposar el cursor (lo único de LspAttach que NO es keymap;
-- los keymaps de LspAttach viven en un autocomando independiente en keybinds.lua).
vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
  callback = function(event)
    local client = vim.lsp.get_client_by_id(event.data.client_id)
    if not (client and client:supports_method('textDocument/documentHighlight', event.buf)) then return end

    local highlight_augroup = vim.api.nvim_create_augroup('kickstart-lsp-highlight', { clear = false })
    vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
      buffer = event.buf,
      group = highlight_augroup,
      callback = vim.lsp.buf.document_highlight,
    })
    vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
      buffer = event.buf,
      group = highlight_augroup,
      callback = vim.lsp.buf.clear_references,
    })
    vim.api.nvim_create_autocmd('LspDetach', {
      group = vim.api.nvim_create_augroup('kickstart-lsp-detach', { clear = true }),
      callback = function(event2)
        vim.lsp.buf.clear_references()
        vim.api.nvim_clear_autocmds { group = 'kickstart-lsp-highlight', buffer = event2.buf }
      end,
    })
  end,
})

-- [[ Servidores ]] — agrega/quita según necesites, Mason los instala solo.
-- Ver `:help lsp-config`.
---@type table<string, vim.lsp.Config>
local servers = {
  clangd = {},
  -- gopls = {},
  pyright = {},
  -- rust_analyzer = {},
  ts_ls = {}, -- para TS/JS; alternativa con más features: pmizio/typescript-tools.nvim

  lua_ls = {
    on_init = function(client)
      client.server_capabilities.documentFormattingProvider = false -- lo hace stylua

      if client.workspace_folders then
        local path = client.workspace_folders[1].name
        if path ~= vim.fn.stdpath 'config' and (vim.uv.fs_stat(path .. '/.luarc.json') or vim.uv.fs_stat(path .. '/.luarc.jsonc')) then return end
      end

      local current_settings = client.config.settings --[[@as lspconfig.settings.lua_ls]]
      client.config.settings.Lua = vim.tbl_deep_extend('force', current_settings.Lua, {
        runtime = { version = 'LuaJIT', path = { 'lua/?.lua', 'lua/?/init.lua' } },
        workspace = {
          checkThirdParty = false,
          -- NOTE: más lento y causa ruido en esta misma config; ver https://github.com/neovim/nvim-lspconfig/issues/3189
          library = vim.api.nvim_get_runtime_file('', true),
        },
      })
    end,
    ---@type lspconfig.settings.lua_ls
    settings = { Lua = { format = { enable = false } } },
  },
}

vim.pack.add {
  'https://github.com/neovim/nvim-lspconfig',
  'https://github.com/mason-org/mason.nvim',
  'https://github.com/mason-org/mason-lspconfig.nvim',
  'https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim',
}

require('mason').setup {}

-- Traduce nombres de nvim-lspconfig a paquetes de mason.nvim (lua_ls <-> lua-language-server)
require('mason-lspconfig').setup {
  automatic_enable = false, -- true = habilita solo lo instalado manualmente vía :Mason
}

-- :Mason para ver/instalar tools manualmente (g? para ayuda)
local ensure_installed = vim.tbl_keys(servers or {})
vim.list_extend(ensure_installed, {
  'stylua', -- formateador de Lua usado por conform.nvim (`<leader>F`), no es un servidor LSP
})
require('mason-tool-installer').setup { ensure_installed = ensure_installed }

for name, server in pairs(servers) do
  vim.lsp.config(name, server)
  vim.lsp.enable(name)
end
