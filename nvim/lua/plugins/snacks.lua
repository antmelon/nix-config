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
