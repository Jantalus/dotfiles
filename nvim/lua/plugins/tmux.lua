return {
  {
    "christoomey/vim-tmux-navigator",
    cmd = {
      "TmuxNavigateLeft",
      "TmuxNavigateDown",
      "TmuxNavigateUp",
      "TmuxNavigateRight",
    },
    keys = {
      { "<c-h>", "<cmd>TmuxNavigateLeft<cr>",  desc = "Navigate left (nvim/tmux)" },
      { "<c-j>", "<cmd>TmuxNavigateDown<cr>",  desc = "Navigate down (nvim/tmux)" },
      { "<c-k>", "<cmd>TmuxNavigateUp<cr>",    desc = "Navigate up (nvim/tmux)" },
      { "<c-l>", "<cmd>TmuxNavigateRight<cr>", desc = "Navigate right (nvim/tmux)" },
    },
  },
}
