return {
  "echaya/neowiki.nvim",
  opts = {
    wiki_dirs = {
      -- neowiki.nvim supports both absolute and tilde-expanded paths
      { name = "Obsidian", path = "/home/tona/Obsidian/the-vault/" },
      { name = "Inbox", path = "/home/tona/Obsidian/the-vault/10-inbox/" },
      { name = "Notas", path = "/home/tona/Obsidian/the-vault/20-notas/" },
      { name = "Cursos", path = "/home/tona/Obsidian/the-vault/30-cursos/" },
      { name = "Hoarder", path = "/home/tona/Obsidian/the-vault/40-hoarded/" },
    },
  },
  keys = {
    { "<leader>ww", "<cmd>lua require('neowiki').open_wiki()<cr>", desc = "Open Wiki" },
    { "<leader>wW", "<cmd>lua require('neowiki').open_wiki_floating()<cr>", desc = "Open Wiki in Floating Window" },
    { "<leader>wT", "<cmd>lua require('neowiki').open_wiki_new_tab()<cr>", desc = "Open Wiki in Tab" },
  },
}
