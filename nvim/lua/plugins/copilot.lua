return {
  {
    "github/copilot.vim",
    event = "BufReadPost",
    init = function()
      vim.g.copilot_no_tab_map = true
    end,
    config = function()
      vim.keymap.set("i", "<a-p>", 'copilot#Accept("\\<CR>")', { expr = true, replace_keycodes = false })
      vim.keymap.set("i", "<a-i>", "<Plug>(copilot-previous)")
      vim.keymap.set("i", "<a-o>", "<Plug>(copilot-next)")
    end,
  },
}
