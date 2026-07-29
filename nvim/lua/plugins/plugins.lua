-- since this is just an example spec, don't actually load anything here and return an empty spec
-- stylua: ignore
-- if true then return {} end

-- every spec file under the "plugins" directory will be loaded automatically by lazy.nvim
--
-- In your plugin files, you can:
-- * add extra plugins
-- * disable/enabled LazyVim plugins
-- * override the configuration of LazyVim plugins
return {
  { "ellisonleao/gruvbox.nvim" },

  {
    "catppuccin/nvim",
    name = "catppuccin",
    lazy = false,
    priority = 1000,
    opts = { flavour = "latte" },
    config = function(_, opts)
      require("catppuccin").setup(opts)
      -- watch the tmux theme state file and switch colorscheme live
      local state_file = vim.fn.expand("~/.local/state/ghostty-theme")
      local watcher = vim.uv.new_fs_event()
      if watcher then
        watcher:start(state_file, {}, vim.schedule_wrap(function()
          local f = io.open(state_file, "r")
          local state = f and f:read("*l") or "dark"
          if f then f:close() end
          vim.cmd("colorscheme " .. (state == "light" and "catppuccin-latte" or "gruvbox"))
        end))
      end
    end,
  },

  -- pick startup colorscheme from the same state file prefix-t writes
  {
    "LazyVim/LazyVim",
    opts = function(_, opts)
      local f = io.open(vim.fn.expand("~/.local/state/ghostty-theme"), "r")
      local state = f and f:read("*l") or "dark"
      if f then f:close() end
      opts.colorscheme = state == "light" and "catppuccin-latte" or "gruvbox"
      return opts
    end,
  },

  -- change trouble config
  {
    "folke/trouble.nvim",
    -- opts will be merged with the parent spec
    opts = { use_diagnostic_signs = true },
  },

  -- disable trouble
  { "folke/trouble.nvim", enabled = false },

  {
    "theprimeagen/harpoon",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      require("harpoon").setup()

      local mark = require("harpoon.mark")
      local ui = require("harpoon.ui")
      local map = vim.keymap.set

      require("which-key").add({ { "<leader>h", group = "harpoon", icon = "󰀱" } })

      map("n", "<leader>ha", mark.add_file, { desc = "Harpoon add file" })
      map("n", "<leader>hh", ui.toggle_quick_menu, { desc = "Harpoon menu" })

      for i = 1, 9 do
        map("n", "<leader>" .. i, function() ui.nav_file(i) end, { desc = "Harpoon file " .. i })
      end
    end,
  },

  -- override nvim-cmp and add cmp-emoji
  -- {
  --   "hrsh7th/nvim-cmp",
  --   dependencies = { "hrsh7th/cmp-emoji" },
  --   ---@param opts cmp.ConfigSchema
  --   opts = function(_, opts)
  --     table.insert(opts.sources, { name = "emoji" })
  --   end,
  -- },

-- add pyright to lspconfig
  {
    "neovim/nvim-lspconfig",
    ---@class PluginLspOpts
    opts = {
      ---@type lspconfig.options
      servers = {
        -- pyright will be automatically installed with mason and loaded with lspconfig
        pyright = {},
        gopls = {},
        sqls = {
          settings = {
            sqls = {
              connections = {
                { driver = "bigquery", dataSourceName = "meli-bi-data" },
              },
            },
          },
        },
      },
    },
  },


  -- add more treesitter parsers
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = {
        "go",
        "bash",
        "html",
        "javascript",
        "json",
        "lua",
        "markdown",
        "markdown_inline",
        "python",
        "query",
        "regex",
        "tsx",
        "typescript",
        "vim",
        "yaml",
      },
    },
  },

  -- since `vim.tbl_deep_extend`, can only merge tables and not lists, the code above
  -- would overwrite `ensure_installed` with the new value.
  -- If you'd rather extend the default config, use the code below instead:
  -- {
  --   "nvim-treesitter/nvim-treesitter",
  --   opts = function(_, opts)
  --     -- add tsx and treesitter
  --     vim.list_extend(opts.ensure_installed, {
  --       "tsx",
  --       "typescript",
  --     })
  --   end,
  -- },

  -- the opts function can also be used to change the default opts:
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    opts = function(_, opts)
      table.insert(opts.sections.lualine_x, {
        function()
          return "🇦🇷🤙"
        end,
      })
    end,
  },

  -- or you can return new options to override all the defaults
  -- {
  --   "nvim-lualine/lualine.nvim",
  --   event = "VeryLazy",
  --   opts = function()
  --     return {
  --       --[[add your custom lualine config here]]
  --     }
  --   end,
  -- },

  {
    "szw/vim-maximizer",
    keys = {
      { "<C-w>m", "<cmd>MaximizerToggle<cr>", desc = "Maximize window" },
    },
  },

  {
    "mason-org/mason.nvim",
    opts = {
      ensure_installed = {
        "stylua",
        "shellcheck",
        "shfmt",
        "flake8",
        "sqls",
      },
    },
  },
}
