local function toggle_forwarded()
  local line = vim.api.nvim_get_current_line()
  local new, n = line:gsub("^(%s*[-*+]%s+%[) (%])", "%1>%2", 1)
  if n == 0 then
    new, n = line:gsub("^(%s*[-*+]%s+%[)>(%])", "%1 %2", 1)
  end
  if n > 0 then
    vim.api.nvim_set_current_line(new)
  end
end

local function feed_visual_keys(keys)
  vim.schedule(function()
    local termcode = vim.api.nvim_replace_termcodes("gv" .. keys, true, false, true)
    vim.api.nvim_feedkeys(termcode, "m", false)
  end)
end

local function feed_normal_keys(keys)
  vim.schedule(function()
    local termcode = vim.api.nvim_replace_termcodes(keys, true, false, true)
    vim.api.nvim_feedkeys(termcode, "m", false)
  end)
end

local function markdown_menu()
  local mode = vim.api.nvim_get_mode().mode
  if mode:match("[vV\22]") then
    vim.cmd("normal! \27")
  end

  local actions = {
    -- Checkboxes & Listas de tareas
    { text = "󰄲 Tarea: Alternar Forwarded [>]",        run = function() vim.schedule(toggle_forwarded) end },
    { text = " Tarea: Alternar Completado [x]",       run = function() feed_visual_keys("<Plug>(MarkdownPlusTaskToggle)") end },
    { text = "󰄱 Tarea: Convertir a Checkbox (- [ ])",  run = function() feed_visual_keys("<Plug>(MarkdownPlusListTask)") end },

    -- Listas
    { text = "󰓹 Lista: Desordenada / Viñetas (-)",    run = function() feed_visual_keys("<Plug>(MarkdownPlusListUnordered)") end },
    { text = "󰑖 Lista: Numerada / Ordenada (1.)",     run = function() feed_visual_keys("<Plug>(MarkdownPlusListOrdered)") end },

    -- Citas / Blockquotes
    { text = "󰝗 Cita: Alternar Blockquote (>)",        run = function() feed_visual_keys("<Plug>(MarkdownPlusBlockquote)") end },

    -- Bloques de código
    { text = "󰅩 Código: Convertir a Code Block",         run = function() feed_visual_keys("<Plug>(MarkdownPlusCodeBlock)") end },
    { text = "󰅩 Código: Insertar Code Block",        run = function() feed_normal_keys("<Plug>(MarkdownPlusCodeBlock)") end },
    { text = " Código: Código en linea",    run = function() feed_visual_keys("<Plug>(MarkdownPlusCodeInline)") end },

    -- Tablas
    { text = " Tabla: Crear nueva tabla",             run = function() feed_normal_keys("<Plug>(MarkdownPlusTableCreate)") end },
    { text = "󰏫 Tabla: Editar texto de celda actual",  run = function() feed_normal_keys("<Plug>(MarkdownPlusTableCellEdit)") end },
    { text = " Tabla: Formatear / Alinear tabla",      run = function() feed_normal_keys("<Plug>(MarkdownPlusTableFormat)") end },
    { text = " Tabla: Insertar fila abajo",            run = function() feed_normal_keys("<Plug>(MarkdownPlusTableInsertRowBelow)") end },
    { text = " Tabla: Insertar columna derecha",       run = function() feed_normal_keys("<Plug>(MarkdownPlusTableInsertColRight)") end },

    -- Formato de texto
    { text = " Formato: Negrita (Bold)",              run = function() feed_visual_keys("<Plug>(MarkdownPlusBold)") end },
    { text = "󰞋 Formato: Cursiva (Italic)",            run = function() feed_visual_keys("<Plug>(MarkdownPlusItalic)") end },
    { text = "󰿠 Formato: Tachado (Strikethrough)",     run = function() feed_visual_keys("<Plug>(MarkdownPlusStrikethrough)") end },
    { text = " Enlace: Convertir en Link",            run = function() feed_visual_keys("<Plug>(MarkdownPlusLink)") end },
  }

  local ok, MiniPick = pcall(require, "mini.pick")
  if not ok then
    vim.notify("mini.pick no está disponible", vim.log.levels.ERROR)
    return
  end

  MiniPick.start({
    source = {
      items = actions,
      name = "Markdown Plus Actions",
      choose = function(item)
        if item and item.run then
          item.run()
        end
      end,
    },
  })
end

-- ====================================================================
-- Keymaps
-- ====================================================================

local bufnr = vim.api.nvim_get_current_buf()

-- Menú con fuzzy search
vim.keymap.set({ "n", "x" }, "<localleader>M", markdown_menu, {
  buffer = bufnr,
  silent = true,
  desc = "Markdown Actions Menu",
})

vim.keymap.set("n", "<localleader>X", "<Plug>(MarkdownPlusToggleListTask)", {
  buffer = true,
  silent = true,
  remap = true,
  desc = "Crear checkbox"
})

vim.keymap.set("n", "<localleader>x", "<Plug>(MarkdownPlusToggleCheckbox)", {
  buffer = true,
  silent = true,
  remap = true,
  desc = "Alternat checkbox"
})

vim.keymap.set("n", "<localleader>>", toggle_forwarded, {
  buffer = true,
  silent = true,
  desc = "Checkbox fordwarded [>]",
})

vim.keymap.set("n", "<localleader>-", "<Plug>(MarkdownPlusToggleListUnordered)", {
  buffer = true,
  silent = true,
  remap = true,
  desc = "Alternat checkbox"
})
