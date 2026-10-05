return {
  {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    opts = {
      picker = { enabled = true },
      terminal = { enabled = true },
      notifier = { enabled = true },
      indent = { enabled = true },
      words = { enabled = true },
      dashboard = {
        enabled = true,
        preset = {
          header = [[
___  ___  ___  _____ _____ 
|  \/  | / _ \|  __ \_   _|
| .  . |/ /_\ \ |  \/ | |  
| |\/| ||  _  | | __  | |  
| |  | || | | | |_\ \_| |_ 
\_|  |_/\_| |_/\____/\___/ ]],
          keys = {
            { icon = " ", key = "f", desc = "Find File", action = function() Snacks.picker.files() end },
            { icon = " ", key = "g", desc = "Find Text", action = function() Snacks.picker.grep() end },
            { icon = " ", key = "b", desc = "Buffers", action = function() Snacks.picker.buffers() end },
            { icon = " ", key = "r", desc = "Recent Files", action = function() Snacks.picker.recent() end },
            { icon = " ", key = "n", desc = "New File", action = ":ene | startinsert" },
            {
              icon = " ",
              key = "c",
              desc = "Config",
              action = function() Snacks.picker.files({ cwd = vim.fn.stdpath("config") }) end,
            },
            { icon = "󰒲 ", key = "L", desc = "Lazy", action = ":Lazy", enabled = package.loaded.lazy ~= nil },
            { icon = " ", key = "q", desc = "Quit", action = ":qa" },
          },
        },
        sections = {
          { section = "header" },
          {
            align = "center",
            padding = 1,
            text = {
              { "MELCHIOR", hl = "SnacksDashboardSpecial" },
              { "  ·  ",    hl = "SnacksDashboardDesc" },
              { "BALTHASAR", hl = "SnacksDashboardSpecial" },
              { "  ·  ",    hl = "SnacksDashboardDesc" },
              { "CASPER",   hl = "SnacksDashboardSpecial" },
            },
          },
          { section = "keys", gap = 1, padding = 1 },
          { icon = " ", title = "Recent Files", section = "recent_files", indent = 2, padding = 1 },
          { icon = " ", title = "Projects", section = "projects", indent = 2, padding = 1 },
          { section = "startup" },
        },
      },
    },
    keys = {
      -- Picker
      { "<leader>ff", function() Snacks.picker.files() end,            desc = "Find files" },
      { "<leader>fg", function() Snacks.picker.grep() end,             desc = "Live grep" },
      { "<leader>fb", function() Snacks.picker.buffers() end,          desc = "Find buffers" },
      { "<leader>fr", function() Snacks.picker.recent() end,           desc = "Recent files" },
      { "<leader>fd", function() Snacks.picker.diagnostics() end,      desc = "Diagnostics" },
      { "<leader>ft", function() Snacks.picker.todo_comments() end,    desc = "TODOs" },
      { "<leader>fh", function() Snacks.picker.help() end,             desc = "Help" },
      { "<leader>fc", function() Snacks.picker.command_history() end,  desc = "Command history" },
      -- Terminal
      { "<leader>tt", function() Snacks.terminal.toggle() end, desc = "Toggle terminal", mode = { "n", "t" } },
      -- Notifications
      { "<leader>fn", function() Snacks.notifier.show_history() end,   desc = "Notification history" },
    },
  },
}
