-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Solución para la indentación en modo visual con teclados no-US
vim.keymap.set("x", "<Tab>", ">gv", { desc = "Indent selection right" })
vim.keymap.set("x", "<S-Tab>", "<gv", { desc = "Indent selection left" })

-- Moverse al buffer de la derecha (siguiente) con Leader + b + k
vim.keymap.set("n", "<leader>bl", "<Cmd>bnext<CR>", { desc = "Buffer siguiente (derecha)" })

-- Moverse al buffer de la izquierda (anterior) con Leader + b + j
vim.keymap.set("n", "<leader>bh", "<Cmd>bprevious<CR>", { desc = "Buffer anterior (izquierda)" })

-- 1. Registrar la 'n' minúscula como grupo/submenú
local wk = require("which-key")
wk.add({
  { "<leader>n", group = "+scripts/notif" },
})

-- 2. El "Doble Tap" para las notificaciones
vim.keymap.set("n", "<leader>nn", "<cmd>Noice history<CR>", { desc = "Historial de Notificaciones" })

-- 3. Tu comando original de Kitty adaptado al submenú
vim.keymap.set("n", "<leader>nt", ":!kitty --detach<CR>", { silent = true, desc = "Abrir Kitty aquí" })
