-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

vim.keymap.del("n", "<C-Up>")
vim.keymap.del("n", "<C-Down>")
vim.keymap.del("n", "<C-Left>")
vim.keymap.del("n", "<C-Right>")

local map = LazyVim.safe_keymap_set

map("i", "jk", "<Esc>", { desc = "jk to Esc, duh" })

map("n", "<Up>", "<cmd>resize +2<cr>", { desc = "Increase Window Height" })
map("n", "<Down>", "<cmd>resize -2<cr>", { desc = "Decrease Window Height" })
map("n", "<Left>", "<cmd>vertical resize -2<cr>", { desc = "Decrease Window Width" })
map("n", "<Right>", "<cmd>vertical resize +2<cr>", { desc = "Increase Window Width" })

map("n", "<leader>yp", function()
  local path = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ":~:.")
  vim.fn.setreg("+", path)
  vim.notify("Copied: " .. path)
end, { desc = "Yank file path (relative)" })

map("n", "<leader>yP", function()
  local path = vim.fn.expand("%:p")
  vim.fn.setreg("+", path)
  vim.notify("Copied: " .. path)
end, { desc = "Yank file path (absolute)" })
