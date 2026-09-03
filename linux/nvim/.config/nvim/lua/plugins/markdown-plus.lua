vim.api.nvim_create_autocmd("FileType", {
  pattern = "markdown",
  callback = function(args)
    -- 1. Agrega el plugin al runtimepath en el primer archivo markdown que abras
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
        enabled = true,
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

    -- KEYMAPS — locales al buffer, atados a este callback FileType (lazy-install).
    -- No se centralizan en keybinds.lua; ver nota-puntero en la sección Markdown-plus de ese archivo.
    pcall(vim.keymap.del, "n", "]]", { buffer = args.buf })
    pcall(vim.keymap.del, "n", "[[", { buffer = args.buf })

    vim.keymap.set("n", "}}", "<Plug>(MarkdownPlusNextHeader)", {
      buffer = args.buf,
      desc = "Header siguiente (markdown-plus)",
    })
    vim.keymap.set("n", "{{", "<Plug>(MarkdownPlusPrevHeader)", {
      buffer = args.buf,
      desc = "Header anterior (markdown-plus)",
    })
  end,
})
