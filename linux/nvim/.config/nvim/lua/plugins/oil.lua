vim.pack.add {
  'https://github.com/stevearc/oil.nvim',
}

require('oil').setup {
  default_file_explorer = true,
  show_hidden = true,
  is_hidden_file = function(name, bufnr) return false end,
  keymaps = {
    ['H'] = { 'actions.parent', mode = 'n' }, -- "H" (SHift + H) Subir al directorio padre
    ['L'] = { 'actions.select', mode = 'n' }, -- "L" (Shift + L) Entrar al directorio
    ['q'] = { 'actions.close', mode = 'n' },
    ['<Esc>'] = { 'actions.close', mode = 'n' },
    ['.'] = 'actions.toggle_hidden',
    ['p'] = 'actions.preview',
  },
  float = {
    border = 'double',
  },
  preview_win = {
    update_on_cursor_moved = true,
    preview_method = 'fast_scratch',
    disable_preview = function(filename) return false end,
    win_options = {},
  },
}

vim.api.nvim_create_autocmd("User", {
  pattern = "OilEnter",
  callback = vim.schedule_wrap(function(args)
    local oil = require("oil")
    if vim.api.nvim_get_current_buf() == args.data.buf and oil.get_cursor_entry() then
      oil.open_preview()
    end
  end),
})
