return {
  {
    "github/copilot.vim",
    event = "BufReadPost",
    init = function()
      vim.g.copilot_no_tab_map = true
    end,
    config = function()
      vim.keymap.set("i", "π", 'copilot#Accept("\\<CR>")', { expr = true, replace_keycodes = false })
      vim.keymap.set("i", "ı", "<Plug>(copilot-previous)")
      vim.keymap.set("i", "ø", "<Plug>(copilot-next)")
    end,
  },
}
