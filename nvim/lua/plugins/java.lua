return {
  {
    "mfussenegger/nvim-jdtls",
    ft = "java",
    config = function()
      local jdtls = require("jdtls")
      local mason_packages = vim.fn.stdpath("data") .. "/mason/packages"

      local bundles = vim.fn.glob(
        mason_packages .. "/java-debug-adapter/extension/server/com.microsoft.java.debug.plugin-*.jar",
        false, true
      )
      vim.list_extend(bundles, vim.fn.glob(mason_packages .. "/java-test/extension/server/*.jar", false, true))

      local function setup()
        local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ":p:h:t")
        local workspace = vim.fn.stdpath("data") .. "/jdtls-workspaces/" .. project_name

        local lombok_jars = vim.fn.glob(vim.fn.expand("~/.m2") .. "/repository/org/projectlombok/lombok/*/lombok-*.jar", false, true)
        local lombok_jar = lombok_jars[#lombok_jars] or ""

        jdtls.start_or_attach({
          cmd = {
            vim.fn.stdpath("data") .. "/mason/bin/jdtls",
            "-data", workspace,
            "--jvm-arg=-javaagent:" .. lombok_jar,
          },
          root_dir = jdtls.setup.find_root({ "pom.xml", "build.gradle", ".git" }),
          init_options = { bundles = bundles },
          settings = {
            java = {
              eclipse = { downloadSources = true },
              maven = { downloadSources = true },
              implementationsCodeLens = { enabled = true },
              referencesCodeLens = { enabled = true },
            },
          },
          on_attach = function()
            jdtls.setup_dap({ hotcodereplace = "auto" })
            require("jdtls.dap").setup_dap_main_class_configs()
          end,
        })
      end

      vim.api.nvim_create_autocmd("FileType", {
        pattern = "java",
        callback = setup,
      })
      setup()
    end,
  },
  -- extend existing neotest (already provided by LazyVim) with the Java adapter
  {
    "nvim-neotest/neotest",
    dependencies = {
      { "rcasia/neotest-java", commit = "2aa2d5ff228bea6242eda27c83d431b909925690" },
    },
    opts = function(_, opts)
      opts.adapters = opts.adapters or {}
      table.insert(opts.adapters, require("neotest-java")({ ignore_wrapper = false }))
    end,
  },
  {
    "mason-org/mason.nvim",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, { "jdtls", "java-debug-adapter", "java-test" })
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      vim.list_extend(opts.ensure_installed, { "java" })
    end,
  },
}
