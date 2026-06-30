return {
  {
    "mistweaverco/kulala.nvim",
    ft = { "http", "rest" },
    keys = {
      { "<leader>R",  "",                                                         desc = "+rest",           ft = "http" },
      { "<leader>Rr", function() require("kulala").run() end,                     desc = "Run request",     ft = "http" },
      { "<leader>Ra", function() require("kulala").run_all() end,                 desc = "Run all",         ft = "http" },
      { "<leader>Rp", function() require("kulala").jump_prev() end,               desc = "Prev request",    ft = "http" },
      { "<leader>Rn", function() require("kulala").jump_next() end,               desc = "Next request",    ft = "http" },
      { "<leader>Re", function() require("kulala").set_selected_env() end,        desc = "Select env",      ft = "http" },
      { "<leader>Ri", function() require("kulala").inspect() end,                 desc = "Inspect request", ft = "http" },
      { "<leader>Rc", function() require("kulala").copy() end,                    desc = "Copy as curl",    ft = "http" },
      { "<leader>Rx", function() require("kulala").close() end,                   desc = "Close response",  ft = "http" },
    },
    opts = {
      default_env = "dev",
      debug = false,
      display_mode = "split",
      split_direction = "vertical",
      formatters = {
        json = { "jq", "." },
        xml  = { "xmllint", "--format", "-" },
        html = { "xmllint", "--format", "--html", "-" },
      },
      icons = {
        inlay = { loading = "⏳", done = "✓", error = "✗" },
      },
    },
  },

  -- treesitter parser for .http files
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      vim.list_extend(opts.ensure_installed, { "http", "graphql" })
    end,
  },
}
