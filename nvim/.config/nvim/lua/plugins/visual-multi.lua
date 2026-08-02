return {
  "mg979/vim-visual-multi",
  init = function()
    vim.g.VM_maps = {
      ["Find Under"] = "<M-d>",
      ["Find Subword Under"] = "<M-d>",
      ["Add Cursor Down"] = "<M-Down>",
      ["Add Cursor Up"] = "<M-Up>",
    }
  end,
}
