local function open_markdown_link()
  local line = vim.fn.getline(".")
  local col = vim.fn.col(".")

  for text, label in line:gmatch("%[([^%]]-)%]%[([^%]]-)%]") do
    local pattern = "%[" .. vim.pesc(text) .. "%]%[" .. vim.pesc(label) .. "%]"
    local s, e = line:find(pattern)
    if s and col >= s and col <= e then
      local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
      local target_label = (label ~= "" and label or text)
      for _, l in ipairs(lines) do
        local def_label, url = l:match("^%[([^%]]-)%]:%s*(%S+)")
        if def_label and def_label:lower() == target_label:lower() then
          vim.ui.open(url)
          return
        end
      end
      vim.notify("No se encontró la referencia [" .. target_label .. "]", vim.log.levels.WARN)
      return
    end
  end

  for url in line:gmatch("%[[^%]]-%]%((%S-)%)") do
    local s, e = line:find(vim.pesc("(" .. url .. ")"))
    if s and col >= s and col <= e then
      vim.ui.open(url)
      return
    end
  end

  local url = line:match("(https?://[%S]+)")
  if url then
    vim.ui.open(url)
  else
    vim.notify("No hay link bajo el cursor", vim.log.levels.INFO)
  end
end

vim.keymap.set("n", "gx", open_markdown_link, { buffer = true, desc = "Abrir link (soporta reference-style)" })
