return {
  "nvim-tree/nvim-tree.lua",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  keys = {
    { "<leader>e", "<cmd>NvimTreeFindFileToggle<cr>", desc = "Toggle file tree" },
    { "<M-b>", "<cmd>NvimTreeFindFileToggle<cr>", desc = "Toggle file tree (Cmd+B)" },
  },
  opts = {
    update_focused_file = { enable = true },
  },
}
