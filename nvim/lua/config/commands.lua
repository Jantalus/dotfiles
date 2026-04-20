vim.cmd([[:command YankFileRelativePath :let @+ = fnamemodify(expand("%"), ":~:.")]])
vim.cmd([[:command BufOnly silent! execute "%bd|e#|bd#|Neotree toggle reveal"]])
