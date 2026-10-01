-- ============================================================
-- MINI.NVIM — icons, textobjects, surround, statusline.
-- ============================================================

vim.pack.add { 'https://github.com/nvim-mini/mini.nvim' }

-- [[ mini.icons ]]
-- Debe cargar antes que Telescope: mockea nvim-web-devicons para
-- plugins que aún dependen de esa API.
if vim.g.have_nerd_font then
  require('mini.icons').setup()
  MiniIcons.mock_nvim_web_devicons()
end

-- [[ mini.ai ]] — Better Around/Inside textobjects
-- va)  [V]isually select [A]round [)]paren · yiiq [Y]ank [I]nside [I]+1 [Q]uote · ci' [C]hange [I]nside [']quote
require('mini.ai').setup {
  mappings = { around_next = 'aa', inside_next = 'ii' }, -- evita choque con incremental-selection nativo
  n_lines = 500,
}

-- [[ mini.surround ]] — saiw) [S]urround [A]dd [I]nner [W]ord · sd' [S]urround [D]elete · sr)' [S]urround [R]eplace
require('mini.surround').setup()

-- [[ mini.statusline ]]
local statusline = require 'mini.statusline'
statusline.setup { use_icons = vim.g.have_nerd_font }
---@diagnostic disable-next-line: duplicate-set-field
statusline.section_location = function() return '%2l:%-2v' end

-- [[ mini.cmdline]]
require('mini.cmdline').setup()

-- [[ mini.tabline]]
require('mini.tabline').setup()

require('mini.extra').setup()
require('mini.git').setup()
require('mini.notify').setup()

require('mini.pick').setup({
  source = {
    show = function(buf_id, items_to_show, query)
      MiniPick.default_show(buf_id, items_to_show, query, { show_icons = true })
    end,
  },
})

-- [[ mini.starter ]]
local starter = require 'mini.starter'

local starter_header = [[
    ██╗████████╗ ██████╗ ███╗   ██╗ █████╗
   ██╔╝╚══██╔══╝██╔═══██╗████╗  ██║██╔══██╗
  ██╔╝    ██║   ██║   ██║██╔██╗ ██║███████║
 ██╔╝     ██║   ██║   ██║██║╚██╗██║██╔══██║
██╔╝      ██║   ╚██████╔╝██║ ╚████║██║  ██║
╚═╝       ╚═╝    ╚═════╝ ╚═╝  ╚═══╝╚═╝  ╚═╝
]]

local function project_root(path)
  local root = vim.fs.root(path, { '.git' })
  if root then return root end
  return vim.fs.dirname(path)
end

local function project_section(max_items)
  return function()
    local items = {}
    local seen = {}

    local function add_project(root)
      if not root or seen[root] then return end
      seen[root] = true
      local project_name = vim.fn.fnamemodify(root, ':t')
      local project_path = vim.fn.fnamemodify(root, ':~')
      table.insert(items, {
        name = string.format('%s (%s)', project_name, project_path),
        section = 'Projects',
        action = function()
          MiniPick.builtin.files({}, {
            source = {
              cwd = root,
              name = 'Project Files',
            },
          })
        end,
      })
    end

    for _, path in ipairs(vim.v.oldfiles or {}) do
      path = vim.fs.normalize(path)
      if path ~= '' and vim.fn.filereadable(path) == 1 then
        add_project(project_root(path))
        if #items >= max_items then break end
      end
    end

    if #items == 0 then
      add_project(project_root(vim.fn.getcwd()))
      add_project(vim.fn.stdpath 'config')
    end

    return items
  end
end

starter.setup {
  header = starter_header,
  items = {
    starter.sections.recent_files(5, false, true),
    project_section(5),
  },
  footer = '',
  content_hooks = {
    starter.gen_hook.adding_bullet(),
    starter.gen_hook.aligning('center', 'center'),
  },
}

local function starter_smart_picker()
  local cwd = vim.fn.getcwd()
  local cwd_pattern = '^' .. vim.pesc(cwd) .. '/'
  local seen = {}
  local items = {}

  local function add_item(path)
    if not path or path == '' then return end
    local rel = path:gsub(cwd_pattern, '')
    if not seen[rel] and vim.fn.filereadable(path) == 1 then
      seen[rel] = true
      table.insert(items, rel)
    end
  end

  for _, oldfile in ipairs(vim.v.oldfiles or {}) do
    if oldfile:find(cwd_pattern) then add_item(oldfile) end
  end

  local fd_cmd = { 'fd', '--type', 'f', '--hidden', '--exclude', '.git' }
  local all_files = vim.fn.systemlist(fd_cmd)
  if vim.v.shell_error == 0 then
    for _, file in ipairs(all_files) do
      add_item(file)
    end
  end

  MiniPick.start {
    source = {
      items = items,
      name = 'Smart Files',
      show = function(buf_id, items_to_show, query)
        MiniPick.default_show(buf_id, items_to_show, query, { show_icons = true })
      end,
    },
  }
end

-- Remaps solo para la pantalla de inicio de mini.starter.
-- Se hace en `User MiniStarterOpened` para que sobreescriba los mapas
-- internos que mini.starter aplica al abrir su buffer.
vim.api.nvim_create_autocmd('User', {
  group = vim.api.nvim_create_augroup('mini-starter-keymaps', { clear = true }),
  pattern = 'MiniStarterOpened',
  callback = function()
    local buf = vim.api.nvim_get_current_buf()
    if vim.bo[buf].filetype ~= 'ministarter' then return end

    vim.keymap.set('n', '<C-p>', function()
      MiniStarter.close()
      vim.schedule(starter_smart_picker)
    end, {
      buffer = buf,
      nowait = true,
      silent = true,
      desc = 'Starter: Smart search',
    })
    vim.keymap.set('n', '<C-S-n>', function() MiniStarter.update_current_item 'prev' end, {
      buffer = buf,
      nowait = true,
      silent = true,
      desc = 'Starter: Previous item',
    })
  end,
})
