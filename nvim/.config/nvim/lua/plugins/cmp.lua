return {
  -- Kill snippet plugins at the plugin level
  { "rafamadriz/friendly-snippets", enabled = false },
  { "garymjr/nvim-snippets", enabled = false },
  { "L3MON4D3/LuaSnip", enabled = false },

  {
    "saghen/blink.cmp",
    opts = function(_, opts)
      -- Only LSP source
      opts.sources = opts.sources or {}
      opts.sources.default = { "lsp" }

      -- Disable snippet provider
      opts.sources.providers = opts.sources.providers or {}
      opts.sources.providers.snippets = {
        name = "snippets",
        enabled = false,
      }

      -- Disable other unwanted providers
      opts.sources.providers.path = {
        name = "path",
        enabled = false,
      }
      opts.sources.providers.buffer = {
        name = "buffer",
        enabled = false,
      }

      -- DISABLE AUTO-POPUP - only show on manual trigger
      opts.completion = opts.completion or {}
      opts.completion.menu = opts.completion.menu or {}
      opts.completion.menu.auto_show = false

      -- DISABLE GHOST TEXT / INLINE COMPLETION
      opts.completion.ghost_text = {
        enabled = false
      }

      -- Custom keymaps
      opts.keymap = {
        preset = "none",

        -- Manual completion trigger
        ["<C-space>"] = { "show", "show_documentation", "hide_documentation" },
        ["<C-e>"] = { "hide" },

        -- Accept completion
        ["<C-y>"] = { "select_and_accept" },
        ["<Tab>"] = { "select_and_accept", "fallback" },

        -- Navigation
        ["<C-p>"] = { "select_prev", "fallback" },
        ["<C-n>"] = { "select_next", "fallback" },

        -- Scroll documentation
        ["<C-b>"] = { "scroll_documentation_up", "fallback" },
        ["<C-f>"] = { "scroll_documentation_down", "fallback" },
      }

      -- Nuclear filter: block keywords, text, and snippets
      local original_transform = opts.sources.transform_items
      opts.sources.transform_items = function(ctx, items)
        if original_transform then
          items = original_transform(ctx, items)
        end

        local CompletionItemKind = require('blink.cmp.types').CompletionItemKind

        return vim.tbl_filter(function(item)
          if not item.kind then return false end

          -- Block these explicitly
          if item.kind == CompletionItemKind.Keyword then return false end
          if item.kind == CompletionItemKind.Text then return false end
          if item.kind == CompletionItemKind.Snippet then return false end

          -- Allow everything else from LSP
          return true
        end, items)
      end

      return opts
    end,
  },
}
