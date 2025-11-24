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
	},
	keys = {
		-- Smart picker with frecency
		{
			"<leader><space>",
			function()
				require("snacks").picker.recent()
			end,
			desc = "Smart Files (Frecency)",
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
