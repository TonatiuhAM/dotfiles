return {
  -- 1. Configuramos Oil para que cargue al inicio
  {
    "stevearc/oil.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    -- CAMBIO CLAVE: Desactivamos lazy para que capture el comando 'nvim .'
    lazy = false,
    opts = {
      default_file_explorer = false,
      delete_to_trash = true,
      skip_confirm_for_simple_edits = false,
      view_options = {
        show_hidden = true,
      },
      keymaps = {
        ["q"] = "actions.close",
      },
    },
    -- Definimos el atajo aquí mismo
    config = function(_, opts)
      require("oil").setup(opts)
      -- vim.keymap.set("n", "<leader>e", "<cmd>Oil<cr>", { desc = "Abrir Oil (File Manager)" })
    end,
  },

  -- 2. Desactivamos el explorador de Snacks
  {
    "folke/snacks.nvim",
    opts = {
      explorer = { enabled = false },
    },
    keys = {
      { "<leader>e", false },
    },
  },

  -- 3. Neo-tree desactivado
  {
    "nvim-neo-tree/neo-tree.nvim",
    enabled = false,
  },
}
