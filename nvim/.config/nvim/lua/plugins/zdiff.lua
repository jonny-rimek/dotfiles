return {
	{
		"martindur/zdiff.nvim",
		cmd = "Zdiff",
		keys = {
			{ "<leader>gz", "<cmd>Zdiff<cr>", desc = "Zdiff (uncommitted)" },
			{ "<leader>gZ", "<cmd>Zdiff main<cr>", desc = "Zdiff (vs main)" },
		},
		opts = {
			default_expanded = true,
		},
	},
}
