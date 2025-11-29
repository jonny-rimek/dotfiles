return {
  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      -- Ensure servers table exists
      opts.servers = opts.servers or {}

      -- Override ruby_lsp completely
      opts.servers.ruby_lsp = {
        mason = false,  -- Don't let Mason interfere
        init_options = {
          formatter = "none",
          enabledFeatures = {
            inlayHint = false,
          },
        },
      }

      -- Disable inlay hints globally
      opts.inlay_hints = {
        enabled = false,
      }

      -- Setup hook to disable diagnostics virtual text
      opts.diagnostics = {
        virtual_text = false,  -- This kills those inline error messages
        signs = true,          -- Keep gutter icons
        underline = true,      -- Keep underlines
        update_in_insert = false,
      }

      return opts
    end,
  },
}
