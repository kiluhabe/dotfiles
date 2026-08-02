return {
  "nvim-telescope/telescope.nvim",
  branch = "0.1.x",
  dependencies = { "nvim-lua/plenary.nvim" },
  keys = {
    { "<M-p>", "<cmd>Telescope find_files<cr>", desc = "Find files" },
    { "<leader>fg", "<cmd>Telescope live_grep<cr>", desc = "Live grep" },
    { "<M-F>", "<cmd>Telescope live_grep<cr>", desc = "Live grep (project)" },
    { "<M-P>", "<cmd>Telescope commands<cr>", desc = "Command palette" },
  },
}
