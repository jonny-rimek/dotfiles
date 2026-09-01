return {
	"folke/snacks.nvim",
	opts = {
		dashboard = {
			enabled = false,
		},
		picker = {
			sources = {
				files = {
					hidden = true, -- Show hidden files
					ignored = false, -- Show ignored files
				},
				grep = { hidden = true },
				git_files = { hidden = true },
			},
		},
		zen = {
			toggles = {
				dim = false,
				line_number = false,
				git_signs = false,
				mini_diff_signs = false,
			},
		},
	},
	keys = {
		{
			"<leader>z",
			function()
				require("snacks").zen()
			end,
			desc = "Toggle Zen Mode",
		},
		-- Smart picker with frecency
		{
			"<leader><space>",
			function()
				require("snacks").picker.grep()
			end,
			desc = "Find by Grep (Content)",
		},
		-- Project-wide search
		{
			"<leader>ff",
			function()
				require("snacks").picker.files()
			end,
			desc = "Find Files (Project Root)",
		},
	},
}
