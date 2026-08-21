vim.pack.add({
  "https://github.com/echaya/neowiki.nvim",
})

-- Expandir la variable de entorno $NOTES_DIR para evitar rutas rotas
local notes_dir = vim.env.NOTES_DIR or vim.fs.normalize("~/notes")

require("neowiki").setup({
  wiki_dirs = {
    { name = "Notas", path = notes_dir .. "/" },
    { name = "Inbox", path = notes_dir .. "/10-inbox/" },
    { name = "General", path = notes_dir .. "/20-notas/" },
    { name = "Cursos", path = notes_dir .. "/30-cursos/" },
    { name = "Hoarder", path = notes_dir .. "/40-hoarded/" },
  },
})

-- Atajos de teclado (keys)
vim.keymap.set("n", "<leader>ww", function()
  require("neowiki").open_wiki()
end, { desc = "Open Wiki" })

vim.keymap.set("n", "<leader>wW", function()
  require("neowiki").open_wiki_floating()
end, { desc = "Open Wiki in Floating Window" })

vim.keymap.set("n", "<leader>wT", function()
  require("neowiki").open_wiki_new_tab()
end, { desc = "Open Wiki in Tab" })
