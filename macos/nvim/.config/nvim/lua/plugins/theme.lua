-- ~/.config/nvim/lua/plugins/theme.lua
return {
  {
    "catppuccin/nvim",
    lazy = false,
    name = "catppuccin",
    priority = 1000,
    opts = {
      flavour = "mocha",
      transparent_background = true,
      no_italic = false,
      no_bold = false,
      integrations = {
        cmp = true,
        gitsigns = true,
        nvimtree = true,
        telescope = true,
      },
    },
    -- [[ AÑADIMOS ESTA FUNCIÓN DE CONFIGURACIÓN ]]
    config = function(_, opts)
      -- Primero, aplicamos la configuración normal de catppuccin
      require("catppuccin").setup(opts)
      
      -- Establecer el colorscheme
      vim.cmd.colorscheme("catppuccin")

      -- Luego, forzamos la transparencia en los grupos de resaltado más importantes
      vim.cmd.hi("Normal guibg=NONE ctermbg=NONE")
      vim.cmd.hi("NormalFloat guibg=NONE ctermbg=NONE")
      vim.cmd.hi("WinSeparator guibg=NONE ctermbg=NONE")
    end,
  },
}
