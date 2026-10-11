-- One- and two-character queries match nearly every line of a large repo,
-- and telescope ingests every match in Lua, so hold off on grepping until
-- the query can actually narrow things down.
local LIVE_GREP_MIN_CHARS = 3

local function live_grep()
  require("telescope.builtin").live_grep({
    on_input_filter_cb = function(prompt)
      if #prompt < LIVE_GREP_MIN_CHARS then
        return { prompt = "" }
      end
    end,
  })
end

return {
  "nvim-telescope/telescope.nvim",
  branch = "0.1.x",
  dependencies = { "nvim-lua/plenary.nvim" },
  opts = {
    defaults = {
      vimgrep_arguments = {
        "rg",
        "--color=never",
        "--no-heading",
        "--with-filename",
        "--line-number",
        "--column",
        "--smart-case",
        -- Lockfiles, minified bundles and source maps have lines hundreds of
        -- KB long; passing them through whole freezes the picker.
        "--max-columns=200",
        "--max-columns-preview",
      },
    },
  },
  keys = {
    {
      "<M-p>",
      function()
        require("telescope.builtin").find_files({
          hidden = true,
          file_ignore_patterns = { "%.git/", "node_modules/" },
        })
      end,
      desc = "Find files",
    },
    { "<leader>fg", live_grep, desc = "Live grep" },
    { "<M-F>", live_grep, desc = "Live grep (project)" },
    { "<M-P>", "<cmd>Telescope commands<cr>", desc = "Command palette" },
  },
}
