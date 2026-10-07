-- lualine theme for the NERV colorscheme.
local c = require("nerv.palette")

local function mode(accent)
  return {
    a = { fg = c.bg, bg = accent, gui = "bold" },
    b = { fg = c.fg_light, bg = c.bg_light },
    c = { fg = c.fg_dark, bg = c.bg_dark },
  }
end

local theme = {
  normal = mode(c.accent),
  insert = mode(c.green),
  visual = mode(c.magenta),
  replace = mode(c.red),
  command = mode(c.yellow),
  terminal = mode(c.cyan),
  inactive = {
    a = { fg = c.muted, bg = c.bg_dark },
    b = { fg = c.muted, bg = c.bg_dark },
    c = { fg = c.muted, bg = c.bg_dark },
  },
}

return theme
