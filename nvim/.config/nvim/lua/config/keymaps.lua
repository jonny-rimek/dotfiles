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

-- Map J/K for BUFFER navigation (removed K from <nop> section)
vim.keymap.set("n", "J", ":bprevious<CR>", { noremap = true, silent = true, desc = "Previous buffer" })
vim.keymap.set("n", "K", ":bnext<CR>", { noremap = true, silent = true, desc = "Next buffer" })

-- Force K to remain bnext even after LSP attaches
vim.api.nvim_create_autocmd("LspAttach", {
	callback = function(args)
		vim.schedule(function()
			-- Delete LSP's K mapping
			pcall(vim.keymap.del, "n", "K", { buffer = args.buf })
			-- Re-apply our mapping
			vim.keymap.set("n", "K", ":bnext<CR>", {
				buffer = args.buf,
				noremap = true,
				silent = true,
				desc = "Next buffer",
			})
		end)
	end,
})

-- Unbind LazyVim's default lazygit keymaps
vim.keymap.del("n", "<leader>gg")
vim.keymap.del("n", "<leader>gG")

-- Save all buffers
vim.keymap.set("n", "<leader>a", "<cmd>wa<cr>", { desc = "Save all buffers" })
