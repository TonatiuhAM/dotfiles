return {
  "daedlock/matugen.nvim",
  lazy = false,
  priority = 1000,
  config = function()
    require("matugen").setup({
      colors_path = "~/.config/matugen/generated/nvim-colors.json",
    })
    vim.cmd.colorscheme("matugen")
  end,
}
