return {
  "mg979/vim-visual-multi",
  init = function()
    vim.g.VM_maps = {
      ["Find Under"] = "<M-d>",
      ["Find Subword Under"] = "<M-d>",
      ["Add Cursor Down"] = "<M-Down>",
      ["Add Cursor Up"] = "<M-Up>",
      -- VM claims Shift+Left/Right by default to start multi-cursor mode,
      -- overriding the VSCode-style selection in config/keymaps.lua (and it
      -- re-applies them on every VM exit, so load order can't fix it).
      ["Select l"] = "",
      ["Select h"] = "",
    }
  end,
}
