-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

-- Belt-and-suspenders: after nvim-dap-ui loads and its config (possibly LazyVim's)
-- sets the auto-close listeners, immediately remove them.
vim.api.nvim_create_autocmd("User", {
  pattern = "LazyLoad",
  callback = function(event)
    if event.data ~= "nvim-dap-ui" then return end
    local dap = require("dap")
    dap.listeners.before.event_terminated["dapui_config"] = nil
    dap.listeners.before.event_exited["dapui_config"] = nil

    -- Show stderr/important output as notifications so it's always visible
    -- regardless of what happens to the dap-ui windows.
    dap.listeners.after.event_output["dapui_errors"] = function(_, body)
      if body.category == "stderr" or body.category == "important" then
        vim.notify(vim.trim(body.output), vim.log.levels.WARN, { title = "DAP" })
      end
    end
  end,
})
