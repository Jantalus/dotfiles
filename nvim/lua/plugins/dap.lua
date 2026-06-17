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

      -- Open UI on session start and whenever execution stops (breakpoint, step, exception)
      dap.listeners.after.event_initialized["dapui_config"] = function()
        dapui.open({})
      end
      dap.listeners.after.event_stopped["dapui_config"] = function()
        dapui.open({})
        vim.fn.jobstart({ "osascript", "-e", 'tell application "Ghostty" to activate' })
      end
      dap.listeners.before.event_terminated["dapui_config"] = nil
      dap.listeners.before.event_exited["dapui_config"] = nil

      -- Inject outputMode="remote" into Go configs from launch.json so that
      -- program stdout/stderr comes through DAP OutputEvents to the console panel.
      -- The key is "dap.launch.json" (not "dap.ext.vscode" which no longer exists).
      local orig = dap.providers.configs["dap.launch.json"]
      if orig then
        dap.providers.configs["dap.launch.json"] = function()
          local cfgs = orig()
          for _, cfg in ipairs(cfgs or {}) do
            if cfg.type == "go" and not cfg.outputMode then
              cfg.outputMode = "remote"
            end
          end
          return cfgs
        end
      end
    end,
  },
}
