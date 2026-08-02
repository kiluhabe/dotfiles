local opts = { noremap = true, silent = true }
local set = vim.keymap.set

set("i", "<C-a>", "<Home>", opts)
set("i", "<C-e>", "<End>", opts)
set("i", "<C-f>", "<Right>", opts)
set("i", "<C-b>", "<Left>", opts)
set("i", "<C-n>", "<Down>", opts)
set("i", "<C-p>", "<Up>", opts)
set("i", "<C-d>", "<Delete>", opts)
set("i", "<C-k>", "<C-o>D", opts)
set("i", "<C-y>", '<C-r>"', opts)

set("n", "<C-f>", "l", opts)
set("n", "<C-b>", "h", opts)
set("n", "<C-n>", "j", opts)
set("n", "<C-p>", "k", opts)
set("n", "<C-a>", "0", opts)
set("n", "<C-e>", "$", opts)
set("n", "<C-k>", "D", opts)
set("n", "<C-d>", "x", opts)
set("n", "<C-y>", "p", opts)

set("n", "<D-f>", "/", { noremap = true })
set("n", "<D-n>", "<cmd>enew<cr>", opts)
set("n", "<D-w>", "<cmd>bdelete<cr>", opts)
set("n", "<D-Left>", "<cmd>bprevious<cr>", opts)
set("n", "<D-Right>", "<cmd>bnext<cr>", opts)
