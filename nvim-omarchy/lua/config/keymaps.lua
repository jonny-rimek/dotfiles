-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Remove LazyVim's default buffer navigation
pcall(vim.keymap.del, "n", "<S-h>")
pcall(vim.keymap.del, "n", "<S-l>")
pcall(vim.keymap.del, "n", "<S-k>")

-- Disable default behaviors
vim.keymap.set("n", "H", "<nop>", { noremap = true, silent = true })
vim.keymap.set("n", "L", "<nop>", { noremap = true, silent = true })
vim.keymap.set("n", "J", "<nop>", { noremap = true, silent = true })
vim.keymap.set("n", "K", "<nop>", { noremap = true, silent = true })

-- Map J/K for BUFFER navigation (what you actually want)
vim.keymap.set("n", "J", ":bprevious<CR>", { noremap = true, silent = true, desc = "Previous buffer" })
vim.keymap.set("n", "K", ":bnext<CR>", { noremap = true, silent = true, desc = "Next buffer" })
