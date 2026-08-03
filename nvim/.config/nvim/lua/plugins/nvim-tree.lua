return {
  "nvim-tree/nvim-tree.lua",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  keys = {
    { "<leader>e", "<cmd>NvimTreeToggle<cr>", desc = "Toggle file tree" },
    { "<M-b>", "<cmd>NvimTreeToggle<cr>", desc = "Toggle file tree (Cmd+B)" },
  },
  opts = {},
}
