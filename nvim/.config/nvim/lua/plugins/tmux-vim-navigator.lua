return {
  "christoomey/vim-tmux-navigator",
  init = function()
    vim.g.tmux_navigator_no_mappings = 1
  end,
  cmd = {
    "TmuxNavigateLeft",
    "TmuxNavigateDown",
    "TmuxNavigateUp",
    "TmuxNavigateRight",
    "TmuxNavigatePrevious",
    "TmuxNavigatorProcessList",
  },
  keys = {
    { "<c-j>", "<cmd>TmuxNavigateLeft<cr>" },
    -- { "<c-j>", "<cmd>TmuxNavigateDown<cr>" },
    -- { "<c-k>", "<cmd>TmuxNavigateUp<cr>" },
    { "<c-k>", "<cmd>TmuxNavigateRight<cr>" },
    -- { "<c-\\>", "<cmd>TmuxNavigatePrevious<cr>" },
  },
}
