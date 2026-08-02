return {
  "nvim-telescope/telescope.nvim",
  branch = "0.1.x",
  dependencies = { "nvim-lua/plenary.nvim" },
  keys = {
    { "<D-p>", "<cmd>Telescope find_files<cr>", desc = "Find files" },
    { "<leader>fg", "<cmd>Telescope live_grep<cr>", desc = "Live grep" },
    { "<D-S-f>", "<cmd>Telescope live_grep<cr>", desc = "Live grep (project)" },
    { "<D-S-p>", "<cmd>Telescope commands<cr>", desc = "Command palette" },
  },
}
