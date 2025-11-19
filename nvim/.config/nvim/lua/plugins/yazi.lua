return {
	"mikavilpas/yazi.nvim",
	event = "VeryLazy",
	keys = {
		{
			"<leader>e",
			"<cmd>Yazi<cr>",
			desc = "Open yazi at the current file",
		},
		{
			"<leader>E",
			"<cmd>Yazi cwd<cr>",
			desc = "Open yazi in nvim's working directory",
		},
	},
	opts = {
		open_for_directories = true,
		keymaps = {
			show_help = "?",
		},
		floating_window_scaling_factor = 1.0, -- 100% size
		yazi_floating_window_border = "none", -- Remove borders
	},
}
