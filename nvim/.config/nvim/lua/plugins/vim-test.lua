return {
	"vim-test/vim-test",
	-- dependencies = {
	--   "preservim/vimux",
	-- },
	keys = {
		{ "<leader>t", "<cmd>TestNearest<CR>", desc = "Test nearest", silent = true },
		{ "<leader>T", "<cmd>TestFile<CR>", desc = "Test file", silent = true },
		{ "<leader>a", "<cmd>TestSuite<CR>", desc = "Test suite", silent = true },
		{ "<leader>l", "<cmd>TestLast<CR>", desc = "Test last", silent = true },
		-- { "<leader>g", "<cmd>TestVisit<CR>", desc = "Test visit", silent = true },
	},
	-- config = function()
	--   vim.cmd("let test#strategy = 'vimux'")
	-- end,
}
