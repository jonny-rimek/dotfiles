return {
  "maxmx03/solarized.nvim",
  lazy = false,
  priority = 1000,
  ---@type solarized.config
  opts = {
    version = "autumn",
    palette = "solarized",
    styles = {
      constants = { bold = true },
    },
  },
  config = function(_, opts)
    vim.o.termguicolors = true
    vim.o.background = "dark"
    require("solarized").setup(opts)
    vim.cmd.colorscheme("solarized")
  end,
}
