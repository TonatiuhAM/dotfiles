vim.api.nvim_create_autocmd("BufReadPre", {
  once = true,
  callback = function()
    vim.pack.add({
      "https://github.com/catgoose/nvim-colorizer.lua",
    })

    require("colorizer").setup({
      filetypes = {
        "*",            -- Activar en todos los tipos de archivo
        "!markdown",    -- Excluir explícitamente buffers markdown
      },
      user_default_options = {
        names = false,  -- Evita colorear nombres comunes de colores (opcional pero recomendado)
      },
    })
  end,
})
