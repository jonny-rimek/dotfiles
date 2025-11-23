return {
	"vim-test/vim-test",
	-- dependencies = {
	--   "preservim/vimux",
	-- },
	keys = {
		-- { "<leader>tt", "<cmd>TestNearest<CR>", desc = "Test nearest", silent = true },
		{ "<leader>tt", "<cmd>TestFile<CR>", desc = "Test file", silent = true },
		{ "<leader>ta", "<cmd>TestSuite<CR>", desc = "Test suite", silent = true },
		{ "<leader>tl", "<cmd>TestLast<CR>", desc = "Test last", silent = true },
		{ "<leader>tg", "<cmd>TestVisit<CR>", desc = "Test visit", silent = true },
	},
	config = function()
		-- vim.cmd("let test#strategy = 'vimux'")
		vim.g["test#ruby#rspec#options"] = "--format documentation"
	end,
}
