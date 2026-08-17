-- Al peghar en modo visual, no reemplazar el registro por defecto
vim.keymap.set("x", "<leader>p", [["_dP]])
vim.keymap.set({ "n", "v" }, "<leader>d", [["_d]])

-- Siempre mantener el cursor centrado al hacer scroll con Ctrl-d y Ctrl-u
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")

-- Atajo para abrir mi archivo de notas diarias
vim.keymap.set("n", "<leader>wn", function()
  vim.cmd("edit " .. vim.fn.fnameescape("/home/tona/documents/notas/bullet-journal.md"))
end, { desc = "Abrir Bullet Journal" })

-- Busqueda de archivos con Telescope usando Ctrl-p
vim.keymap.set("n", "<C-p>", ":Telescope find_files<CR>", { desc = "Buscar archivos" })

-- Modo Normal: <C-S-y> copia toda la línea actual al portapapeles del sistema
vim.keymap.set("n", "<C-S-y>", '"+yy', { desc = "Copiar línea al portapapeles del sistema", silent = true })

-- Modo Visual: <C-y> copia la selección actual al portapapeles del sistema
vim.keymap.set("v", "<C-y>", '"+y', { desc = "Copiar selección al portapapeles del sistema", silent = true })

-- Modo Insertar: Ctrl+v pega directamente sin salir a modo normal
vim.keymap.set("i", "<C-v>", "<C-r>+", { desc = "Pegar del portapapeles del sistema", silent = true })

-- Solución para la indentación en modo visual con teclados no-US
vim.keymap.set("x", "<Tab>", ">gv", { desc = "Indent selection right" })
vim.keymap.set("x", "<S-Tab>", "<gv", { desc = "Indent selection left" })

-- Moverse al buffer de la derecha (siguiente) con Leader + b + k
vim.keymap.set("n", "<leader>bl", "<Cmd>bnext<CR>", { desc = "Buffer siguiente (derecha)" })
-- Moverse al buffer de la izquierda (anterior) con Leader + b + j
vim.keymap.set("n", "<leader>bh", "<Cmd>bprevious<CR>", { desc = "Buffer anterior (izquierda)" })

-- ===================================
-- SUBMENU "N"
-- ===================================

-- Registrar la 'n' minúscula como grupo/submenú
local wk = require("which-key")
wk.add({
  { "<leader>n", group = "+scripts/notif" },
})

-- Abrir notificaciones de Noice con Leader + n + n
vim.keymap.set("n", "<leader>nn", "<cmd>Noice history<CR>", { desc = "Historial de Notificaciones" })

-- Abrir Alacritty en el directorio del archivo actual con Leader + n + t
vim.keymap.set("n", "<leader>nt", function()
  local dir = vim.fn.expand("%:p:h")
  vim.fn.jobstart({ "setsid", "-f", "alacritty", "--working-directory", dir }, { detach = true })
end, { silent = true, desc = "Abrir Alacritty aquí" })

-- ====================================
-- KEYMAPS DESACTIVADAS
-- ====================================

-- ELIMINARE <leader>w
vim.keymap.set("n", "<leader>-", "<C-W>s", { desc = "Split Window Below", remap = false })
vim.keymap.set("n", "<leader>|", "<C-W>v", { desc = "Split Window Right", remap = false })
vim.keymap.set("n", "<leader>wd", "<C-W>c", { desc = "Delete Window", remap = false })

vim.keymap.set("n", "<C-h>", "<C-w>h", { desc = "Go to Left Window", remap = false })
vim.keymap.set("n", "<C-j>", "<C-w>j", { desc = "Go to Lower Window", remap = false })
vim.keymap.set("n", "<C-k>", "<C-w>k", { desc = "Go to Upper Window", remap = false })
vim.keymap.set("n", "<C-l>", "<C-w>l", { desc = "Go to Right Window", remap = false })

vim.keymap.set("n", "<C-k>", "<cmd>resize +2<cr>", { desc = "Increase Window Height" })
vim.keymap.set("n", "<C-j>", "<cmd>resize -2<cr>", { desc = "Decrease Window Height" })
vim.keymap.set("n", "<C-l>", "<cmd>vertical resize -2<cr>", { desc = "Decrease Window Width" })
vim.keymap.set("n", "<C-h>", "<cmd>vertical resize +2<cr>", { desc = "Increase Window Width" })

vim.keymap.del("n", "<leader>E")
