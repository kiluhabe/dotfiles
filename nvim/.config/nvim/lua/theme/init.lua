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
  hl(0, "Normal", { fg = palette.fg, bg = palette.bg })
  hl(0, "Comment", { fg = palette.border, italic = true })
  hl(0, "String", { fg = palette.success })
  hl(0, "Function", { fg = palette.accent2 })
  hl(0, "Keyword", { fg = palette.accent })
  hl(0, "Identifier", { fg = palette.border2 })
  hl(0, "Directory", { fg = palette.accent2 })
  hl(0, "Type", { fg = palette.warning })
  hl(0, "Constant", { fg = palette.warning })
  hl(0, "DiffAdd", { fg = palette.success })
  hl(0, "DiffDelete", { fg = palette.error })
  hl(0, "CursorLine", { bg = palette.surface })
  hl(0, "Visual", { bg = palette.border })
  hl(0, "LineNr", { fg = palette.border })
  hl(0, "StatusLine", { fg = palette.fg, bg = palette.surface })
  hl(0, "Pmenu", { fg = palette.fg, bg = palette.surface })
  hl(0, "Search", { fg = palette.bg, bg = palette.accent2 })
  hl(0, "DiagnosticError", { fg = palette.error })
  hl(0, "DiagnosticWarn", { fg = palette.warning })
  hl(0, "ErrorMsg", { fg = palette.error })
  hl(0, "WarningMsg", { fg = palette.warning })
  vim.api.nvim_exec_autocmds("ColorScheme", { pattern = "theme-current" })
end

return M
