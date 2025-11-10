-- Load relative-motions plugin for vim-like navigation
require("relative-motions"):setup({
	show_numbers = "relative", -- Show relative line numbers
	show_motion = true, -- Show motion in status bar
	only_motions = false, -- Allow delete/cut/yank commands
})
