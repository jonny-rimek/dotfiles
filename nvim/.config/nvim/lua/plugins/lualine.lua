return {
	{
		"nvim-lualine/lualine.nvim",
		opts = function(_, opts)
			opts.sections.lualine_z = {}
			opts.sections.lualine_y = {}

			-- Show full path from git root, never truncate
			-- Remove root_dir (index 1) since full path makes it redundant
			-- Replace pretty_path (index 4) with untruncated version
			table.remove(opts.sections.lualine_c, 1)
			opts.sections.lualine_c[3] = { LazyVim.lualine.pretty_path({ relative = "root", length = 0 }) }
		end,
	},
}
