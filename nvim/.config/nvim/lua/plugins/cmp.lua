return {
	"saghen/blink.cmp",
	opts = {
		keymap = {
			preset = "none", -- Disable all default keymaps

			-- Custom keymaps
			["<C-space>"] = { "show", "show_documentation", "hide_documentation" },
			["<C-e>"] = { "hide" },
			["<C-y>"] = { "select_and_accept" },

			-- Navigation
			["<C-p>"] = { "select_prev", "fallback" },
			["<C-n>"] = { "select_next", "fallback" },
			["<C-b>"] = { "scroll_documentation_up", "fallback" },
			["<C-f>"] = { "scroll_documentation_down", "fallback" },

			-- Tab to confirm completion
			["<Tab>"] = { "select_and_accept", "fallback" },

			-- Snippet navigation (if using snippets)
			["<S-Tab>"] = { "snippet_backward", "fallback" },
		},
	},
}
