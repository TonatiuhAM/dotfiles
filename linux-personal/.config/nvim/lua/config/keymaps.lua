-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

vim.keymap.set("n", "<leader>wn", function()
  vim.cmd("edit " .. vim.fn.fnameescape("~/Obsidian/the-vault/bullet-journal.md"))
end, { desc = "Abrir Bullet Journal" })

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
vim.keymap.set("n", "<leader>nt", ":silent !setsid -f alacritty &<CR>", { silent = true, desc = "Abrir Alacritty aquí" })

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
