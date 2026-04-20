return {
  -- Seamless navigation between nvim splits and tmux panes with C-h/j/k/l
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

  -- Telescope picker for tmux sessions
  {
    "nvim-telescope/telescope.nvim",
    keys = {
      {
        "<leader>fs",
        function()
          local pickers = require("telescope.pickers")
          local finders = require("telescope.finders")
          local conf = require("telescope.config").values
          local actions = require("telescope.actions")
          local action_state = require("telescope.actions.state")

          -- Get sessions: "name (windows) [attached]"
          local raw = vim.fn.systemlist("tmux list-sessions -F '#{session_name}\t#{session_windows}\t#{session_attached}' 2>/dev/null")
          if vim.v.shell_error ~= 0 or #raw == 0 then
            vim.notify("No tmux sessions found", vim.log.levels.WARN)
            return
          end

          local results = {}
          for _, line in ipairs(raw) do
            local name, windows, attached = line:match("^([^\t]+)\t([^\t]+)\t([^\t]+)$")
            if name then
              local label = name .. "  [" .. windows .. " win" .. (attached == "1" and ", attached" or "") .. "]"
              table.insert(results, { name = name, label = label })
            end
          end

          pickers.new({}, {
            prompt_title = "Tmux Sessions",
            finder = finders.new_table({
              results = results,
              entry_maker = function(entry)
                return {
                  value = entry.name,
                  display = entry.label,
                  ordinal = entry.name,
                }
              end,
            }),
            sorter = conf.generic_sorter({}),
            attach_mappings = function(prompt_bufnr)
              actions.select_default:replace(function()
                local selection = action_state.get_selected_entry()
                actions.close(prompt_bufnr)
                vim.fn.system("tmux switch-client -t " .. vim.fn.shellescape(selection.value))
              end)
              return true
            end,
          }):find()
        end,
        desc = "Find tmux session",
      },
    },
  },
}
