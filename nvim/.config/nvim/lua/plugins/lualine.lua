return {
	{
		"nvim-lualine/lualine.nvim",
		opts = function(_, opts)
			opts.sections.lualine_z = {}
			opts.sections.lualine_y = {}
		end,
	},
}
