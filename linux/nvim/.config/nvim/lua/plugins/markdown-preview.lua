vim.api.nvim_create_autocmd("FileType", {
  pattern = "markdown",
  callback = function()
    -- 1. Añade el plugin al runtimepath al abrir un buffer markdown
    vim.pack.add({
      "https://github.com/iamcco/markdown-preview.nvim",
    })
  end,
})
