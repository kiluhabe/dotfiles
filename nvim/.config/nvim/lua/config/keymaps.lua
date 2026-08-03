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

set("n", "<M-f>", "/", { noremap = true })
set("n", "<M-n>", "<cmd>enew<cr>", opts)
set("n", "<M-w>", "<cmd>bdelete<cr>", opts)
set("n", "<M-Left>", "<cmd>bprevious<cr>", opts)
set("n", "<M-Right>", "<cmd>bnext<cr>", opts)

-- Cmd+C / Cmd+V: system clipboard copy/paste.
-- Sent from Alacritty as F13/F14 (real terminfo-defined function keys,
-- not invented codes) rather than Meta/CSI-u encoding: bare ESC+"c" can
-- decompose into a standalone <Esc> plus a pending "c" (change) operator
-- that eats the next keystroke, and ad-hoc CSI-u forms aren't reliably
-- recognized here either. F13/F14 are registered in terminfo, so nvim
-- parses them as one atomic key with no decompose/recognition risk.
set("v", "<F13>", '"+y', opts)
set("n", "<F14>", '"+p', opts)
set("v", "<F14>", '"+p', opts)
set("i", "<F14>", "<C-r>+", opts)

-- Shift+arrows: VSCode-style extend-selection
set("n", "<S-Right>", "v<Right>", opts)
set("n", "<S-Left>", "v<Left>", opts)
set("n", "<S-Down>", "v<Down>", opts)
set("n", "<S-Up>", "v<Up>", opts)
set("v", "<S-Right>", "<Right>", opts)
set("v", "<S-Left>", "<Left>", opts)
set("v", "<S-Down>", "<Down>", opts)
set("v", "<S-Up>", "<Up>", opts)
