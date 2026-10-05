require("config.options")

-- NERV colorscheme (local: colors/nerv.lua + lua/nerv/). Set before lazy so
-- plugins draw with the right highlights from the first frame.
vim.cmd.colorscheme("nerv")

require("config.lazy")
require("config.keymaps")
require("config.autocmds")
