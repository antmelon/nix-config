-- NERV palette, ported verbatim from the Omarchy "evangelion" theme
-- (~/.config/omarchy/themes/evangelion/colors.toml) so nvim matches the bar,
-- terminal and Hyprland borders.
--
-- The handful of entries marked "derived" have no counterpart in colors.toml:
-- they are dark blends of the palette used for surfaces that need to sit
-- between `bg` and `lighter_background` (cursorline, diff washes, indent
-- guides). Everything else is the theme's own hex.

return {
  -- surfaces
  bg = "#0a0a0a", -- background
  bg_dark = "#070604", -- dark_background: statusline, tabline
  bg_darker = "#030302", -- darker_background
  bg_light = "#1a1206", -- lighter_background: floats, popups, folds
  cursorline = "#12100b", -- derived
  sel = "#3a2a14", -- selection
  border = "#2a1c0d", -- inactive Hyprland border, reused for splits
  gutter = "#4d443a", -- derived: line numbers
  nontext = "#332c22", -- derived: eol/indent/whitespace marks

  -- text
  fg = "#e8c88a", -- foreground
  fg_dark = "#8a7355", -- dark_foreground
  fg_light = "#f0dcae", -- light_foreground
  fg_bright = "#fff2d5", -- bright_foreground
  muted = "#585045", -- comments, disabled text

  -- accents
  accent = "#ff6b1a", -- accent / orange
  red = "#ff3b30",
  yellow = "#ffc145",
  orange = "#ff6b1a",
  green = "#3ddc84",
  cyan = "#5fd3d3",
  blue = "#4a9ebf",
  magenta = "#c77dff",
  brown = "#7a5230",

  bright_red = "#ff6659",
  bright_yellow = "#ffd873",
  bright_green = "#6be89f",
  bright_cyan = "#8bece0",
  bright_blue = "#7ec4e0",
  bright_magenta = "#dba3ff",

  -- derived washes for diffs and reference highlights
  diff_add = "#0e2015",
  diff_delete = "#2a0f0d",
  diff_change = "#141b26",
  diff_text = "#1e2c3d",
  reference = "#241a0e",
}
