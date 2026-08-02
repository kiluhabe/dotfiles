return {
  "mg979/vim-visual-multi",
  init = function()
    vim.g.VM_maps = {
      ["Find Under"] = "<D-d>",
      ["Find Subword Under"] = "<D-d>",
      ["Add Cursor Down"] = "<D-M-Down>",
      ["Add Cursor Up"] = "<D-M-Up>",
    }
  end,
}
