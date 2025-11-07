return {
  {
    "neovim/nvim-lspconfig",
    opts = function()
      local keys = require("lazyvim.plugins.lsp.keymaps").get()
      -- Disable the default K keymap for hover
      keys[#keys + 1] = { "K", false }
    end,
  },
}
