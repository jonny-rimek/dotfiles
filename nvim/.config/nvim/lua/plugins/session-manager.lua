return {
	"Shatur/neovim-session-manager",
	dependencies = { "nvim-lua/plenary.nvim" },
	config = function()
		require("session_manager").setup({
			autoload_mode = require("session_manager.config").AutoloadMode.CurrentDir,
		})
		local function close_zen()
			local snacks = package.loaded.snacks
			local win = snacks and snacks.zen.win
			if not win then
				return
			end
			if win:valid() then
				win:close()
			elseif win.augroup then
				pcall(vim.api.nvim_del_augroup_by_id, win.augroup)
				snacks.zen.win = nil
			end
		end
		vim.api.nvim_create_autocmd("User", {
			pattern = { "SessionLoadPre", "LazyReload" },
			callback = close_zen,
		})
	end,
}