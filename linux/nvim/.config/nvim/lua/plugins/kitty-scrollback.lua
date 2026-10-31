vim.pack.add({
  {
    src = 'https://github.com/mikesmithgh/kitty-scrollback.nvim',
  },
}, {
  load = false,
})

local loaded = false
local function load_kitty_scrollback()
  if loaded then
    return
  end
  loaded = true

  vim.cmd.packadd('kitty-scrollback.nvim')

  require('kitty-scrollback').setup()
end

local group = vim.api.nvim_create_augroup('KittyScrollbackLazy', { clear = true })

vim.api.nvim_create_autocmd('User', {
  group = group,
  pattern = 'KittyScrollbackLaunch',
  once = true,
  callback = function()
    load_kitty_scrollback()
  end,
})

local commands = {
  'KittyScrollbackGenerateKittens',
  'KittyScrollbackCheckHealth',
  'KittyScrollbackGenerateCommandLineEditing',
}

for _, cmd_name in ipairs(commands) do
  vim.api.nvim_create_user_command(cmd_name, function(opts)
    for _, c in ipairs(commands) do
      pcall(vim.api.nvim_del_user_command, c)
    end

    load_kitty_scrollback()

    local cmd_str = cmd_name
    if opts.args and #opts.args > 0 then
      cmd_str = cmd_str .. ' ' .. opts.args
    end
    vim.cmd(cmd_str)
  end, {
    nargs = '*',
    bang = true,
  })
end
