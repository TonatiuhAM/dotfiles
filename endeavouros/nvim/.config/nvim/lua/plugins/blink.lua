return {
  {
    "saghen/blink.cmp",
    opts = {
      keymap = {
        preset = "none", -- Sin preset por defecto
        ["<S-Tab>"] = { "select_and_accept" }, -- Shift+Tab acepta sugerencias
        ["<Tab>"] = { "snippet_forward", "fallback" }, -- Tab para snippets
        ["<CR>"] = { "fallback" }, -- Enter funciona normalmente
        ["<C-n>"] = { "select_next" }, -- Ctrl+n siguiente
        ["<C-p>"] = { "select_prev" }, -- Ctrl+p anterior
        ["<C-Space>"] = { "show" }, -- Ctrl+Space mostrar completions
        ["<C-e>"] = { "hide" }, -- Ctrl+e ocultar completions
      },
      -- Mantener las mismas fuentes pero sin copilot automático
      sources = {
        default = { "lsp", "path", "snippets", "buffer" },
      },
    },
  },
}