local M = {}

function M.apply()
  local palette_path = vim.fn.expand("~/.config/theme/current/nvim.lua")
  local ok, palette = pcall(dofile, palette_path)
  if not ok then
    vim.notify("theme: failed to load " .. palette_path, vim.log.levels.WARN)
    return
  end

  vim.o.termguicolors = true
  vim.g.colors_name = "theme-current"

  local hl = vim.api.nvim_set_hl
  hl(0, "Normal", { fg = palette.foreground, bg = palette.background })
  hl(0, "Comment", { fg = palette.bright_black, italic = true })
  hl(0, "String", { fg = palette.green })
  hl(0, "Function", { fg = palette.blue })
  hl(0, "Keyword", { fg = palette.magenta })
  hl(0, "Identifier", { fg = palette.cyan })
  hl(0, "DiffAdd", { fg = palette.green })
  hl(0, "DiffDelete", { fg = palette.red })
  hl(0, "CursorLine", { bg = palette.black })
  hl(0, "Visual", { bg = palette.bright_black })
  hl(0, "LineNr", { fg = palette.bright_black })
  hl(0, "StatusLine", { fg = palette.foreground, bg = palette.bright_black })
  hl(0, "Pmenu", { fg = palette.foreground, bg = palette.bright_black })
  hl(0, "Search", { fg = palette.black, bg = palette.yellow })
end

return M
