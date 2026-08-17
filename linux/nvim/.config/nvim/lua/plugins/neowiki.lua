return {
  "echaya/neowiki.nvim",
  opts = {
    wiki_dirs = {
      -- neowiki.nvim supports both absolute and tilde-expanded paths
      { name = "Notas", path = "$NOTES_DIR/" },
      { name = "Inbox", path = "$NOTES_DIR/10-inbox/" },
      { name = "General", path = "$NOTES_DIR/20-notas/" },
      { name = "Cursos", path = "$NOTES_DIR/30-cursos/" },
      { name = "Hoarder", path = "$NOTES_DIR/40-hoarded/" },
    },
  },
  keys = {
    { "<leader>ww", "<cmd>lua require('neowiki').open_wiki()<cr>", desc = "Open Wiki" },
    { "<leader>wW", "<cmd>lua require('neowiki').open_wiki_floating()<cr>", desc = "Open Wiki in Floating Window" },
    { "<leader>wT", "<cmd>lua require('neowiki').open_wiki_new_tab()<cr>", desc = "Open Wiki in Tab" },
  },
}
