return {
  {
    "leoluz/nvim-dap-go",
    opts = {
      delve = {
        detached = false,
      },
    },
  },
  {
    "rcarriga/nvim-dap-ui",
    opts = {
      layouts = {
        {
          elements = {
            { id = "scopes", size = 0.25 },
            { id = "breakpoints", size = 0.25 },
            { id = "stacks", size = 0.25 },
            { id = "watches", size = 0.25 },
          },
          position = "left",
          size = 40,
        },
        {
          elements = {
            { id = "console", size = 0.6 },
            { id = "repl", size = 0.4 },
          },
          position = "bottom",
          size = 15,
        },
      },
    },
    config = function(_, opts)
      local dap = require("dap")
      local dapui = require("dapui")
      dapui.setup(opts)

      -- Open UI on session start; never auto-close on exit
      dap.listeners.after.event_initialized["dapui_config"] = function()
        dapui.open({})
      end
      dap.listeners.before.event_terminated["dapui_config"] = nil
      dap.listeners.before.event_exited["dapui_config"] = nil

      -- Surface program output as notifications
      dap.listeners.after.event_output["dapui_errors"] = function(_, body)
        local msg = vim.trim(body.output or "")
        if msg == "" then return end
        if body.category == "stderr" or body.category == "console" or body.category == "important" then
          vim.notify(msg, vim.log.levels.WARN, { title = "DAP" })
        elseif body.category == "stdout" then
          vim.notify(msg, vim.log.levels.INFO, { title = "DAP" })
        end
      end

      -- Defer provider wrap: nvim-dap's own config (which registers the vscode
      -- provider) runs after this config, so we patch it on the next tick.
      vim.defer_fn(function()
        local orig = dap.providers
          and dap.providers.configs
          and dap.providers.configs["dap.ext.vscode"]
        if not orig then return end
        dap.providers.configs["dap.ext.vscode"] = function(bufnr)
          local cfgs = orig(bufnr)
          for _, cfg in ipairs(cfgs or {}) do
            if cfg.type == "go" and not cfg.outputMode then
              cfg.outputMode = "remote"
            end
          end
          return cfgs
        end
      end, 0)
    end,
  },
}
