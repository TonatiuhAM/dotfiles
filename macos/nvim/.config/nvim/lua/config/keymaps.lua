-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Solución para la indentación en modo visual con teclados no-US
vim.keymap.set("x", "<Tab>", ">gv", { desc = "Indent selection right" })
vim.keymap.set("x", "<S-Tab>", "<gv", { desc = "Indent selection left" })

-- Moverse al buffer de la derecha (siguiente) con Leader + b + k
vim.keymap.set("n", "<leader>bk", "<Cmd>bnext<CR>", { desc = "Buffer siguiente (derecha)" })

-- Moverse al buffer de la izquierda (anterior) con Leader + b + j
vim.keymap.set("n", "<leader>bj", "<Cmd>bprevious<CR>", { desc = "Buffer anterior (izquierda)" })
