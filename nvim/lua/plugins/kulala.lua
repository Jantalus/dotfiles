local active_jq_filter = nil

local function apply_active_filter()
  if not active_jq_filter then return end
  local ok, db = pcall(require, "kulala.db")
  if not ok then return end
  local data = db.global_update()
  local pos = data.current_response_pos
  local response = pos and data.responses[pos]
  if not response or not response.body or response.body == "" then return end

  local result = vim.fn.system({ "jq", active_jq_filter }, response.body)
  if vim.v.shell_error ~= 0 then
    vim.notify("jq: " .. result:gsub("\n$", ""), vim.log.levels.ERROR)
    return
  end

  local ui_bufnr = vim.fn.bufnr("kulala://ui")
  if ui_bufnr == -1 then return end

  local lines = vim.split(result, "\n", { plain = true })
  if lines[#lines] == "" then table.remove(lines) end

  vim.bo[ui_bufnr].modifiable = true
  vim.api.nvim_buf_set_lines(ui_bufnr, 0, -1, false, lines)
  vim.bo[ui_bufnr].modifiable = false
end

local function set_jq_filter()
  vim.ui.input({ prompt = "jq filter (empty to clear): ", default = active_jq_filter or "." }, function(filter)
    if filter == nil then return end
    if filter == "" or filter == "." then
      active_jq_filter = nil
      vim.notify("kulala: jq filter cleared")
      local ok, ui = pcall(require, "kulala.ui")
      if ok then ui.open_default_view() end
      return
    end
    active_jq_filter = filter
    apply_active_filter()
    vim.notify("kulala: jq active — " .. filter)
  end)
end

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
      { "<leader>RI", function() require("kulala").from_curl() end,               desc = "Import from curl", ft = "http" },
      { "<CR>",       function() require("kulala").run() end,                     desc = "Run request",     ft = "http" },
      { "<leader>Rj", set_jq_filter,                                              desc = "jq filter",       ft = "http" },
    },
    init = function()
      vim.api.nvim_set_hl(0, "KulalaStatus2xx", { fg = "#1d2021", bg = "#b8bb26", bold = true })
      vim.api.nvim_set_hl(0, "KulalaStatus4xx", { fg = "#1d2021", bg = "#fabd2f", bold = true })
      vim.api.nvim_set_hl(0, "KulalaStatus5xx", { fg = "#fbf1c7", bg = "#fb4934", bold = true })

      vim.api.nvim_create_autocmd("BufWinEnter", {
        group = vim.api.nvim_create_augroup("KulalaStatusColor", { clear = true }),
        callback = function(ev)
          if not vim.api.nvim_buf_get_name(ev.buf):match("^kulala://") then return end
          vim.fn.matchadd("KulalaStatus2xx", "Status: [23]\\d\\d")
          vim.fn.matchadd("KulalaStatus4xx", "Status: 4\\d\\d")
          vim.fn.matchadd("KulalaStatus5xx", "Status: [5-9]\\d\\d")
        end,
      })

      -- Re-apply active jq filter whenever the kulala response pane is entered
      -- (covers both switching requests and fresh responses after run())
      vim.api.nvim_create_autocmd("BufEnter", {
        group = vim.api.nvim_create_augroup("KulalaJqFilter", { clear = true }),
        callback = function(ev)
          if not vim.api.nvim_buf_get_name(ev.buf):match("^kulala://") then return end
          vim.defer_fn(apply_active_filter, 0)
        end,
      })

      vim.api.nvim_create_autocmd("BufEnter", {
        group = vim.api.nvim_create_augroup("KulalaPerBuffer", { clear = true }),
        pattern = { "*.http", "*.rest" },
        callback = function(ev)
          local ok_ui, ui = pcall(require, "kulala.ui")
          local ok_db, db = pcall(require, "kulala.db")
          if not ok_ui or not ok_db then return end

          db.set_current_buffer(ev.buf)

          if vim.fn.bufwinnr("kulala://ui") == -1 then return end

          local buf_name = vim.api.nvim_buf_get_name(ev.buf)
          local responses = db.global_update().responses
          for i = #responses, 1, -1 do
            local r = responses[i]
            if r.buf == ev.buf or r.buf_name == buf_name then
              db.global_update().current_response_pos = i
              ui.open_default_view()
              return
            end
          end
        end,
      })
    end,
    opts = {
      default_env = "dev",
      debug = false,
      display_mode = "split",
      split_direction = "vertical",
      ui = {
        max_response_size = 5 * 1024 * 1024,
      },
      formatters = {
        json = { "jq", "." },
        xml  = { "xmllint", "--format", "-" },
        html = { "xmllint", "--format", "--html", "-" },
      },
      icons = {
        inlay = { loading = "⏳", done = "✓", error = "✗" },
      },
      kulala_keymaps = {
        ["Previous tab"] = { "<S-Tab>", function() require("kulala.ui").show_previous_tab() end, mode = { "n" }, prefix = false },
        ["Next tab"]     = { "<Tab>",   function() require("kulala.ui").show_next_tab() end,     mode = { "n" }, prefix = false },
        ["Show verbose"] = false,
        ["Filter with jq"] = { "f", set_jq_filter, mode = { "n" }, prefix = false },
      },
    },
  },

  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      vim.list_extend(opts.ensure_installed, { "graphql" })
    end,
  },
}
