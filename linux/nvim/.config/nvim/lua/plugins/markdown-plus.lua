vim.api.nvim_create_autocmd("FileType", {
  pattern = "markdown",
  callback = function(args)
    vim.pack.add({
      "https://github.com/yousefhadder/markdown-plus.nvim",
    })

    -- 2. Configura el plugin pasándole las opciones
    require("markdown-plus").setup({
      enabled = true,
      features = {
        list_management = true,
        text_formatting = true,
        thematic_break = true,
        headers_toc = true,
        links = true,
        images = true,
        quotes = true,
        callouts = true,
        code_block = true,
        html_block_awareness = true,
        table = true,
        footnotes = true,
      },
      footnotes = {
        section_header = "Footnotes",
        confirm_delete = true,
      },
      keymaps = {
        enabled = false,
      },
      toc = {
        initial_depth = 2,
      },
      callouts = {
        default_type = "NOTE",
        custom_types = {},
      },
      table = {
        auto_format = true,
        default_alignment = "left",
        confirm_destructive = true,
        keymaps = {
          enabled = true,
          prefix = "<localleader>t",
          insert_mode_navigation = true,
        },
      },
      filetypes = { "markdown" },
    })
  end,
})
