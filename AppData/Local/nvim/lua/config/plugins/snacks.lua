local explorer = require("config.plugins.snacks.explorer")
local notifier = require("config.plugins.snacks.notifier")
local picker = require("config.plugins.snacks.picker")

return {
    {
        "folke/snacks.nvim",
        priority = 1000,
        lazy = false,
        opts = {
            bigfile = { enabled = false },
            dashboard = { enabled = false },
            explorer = explorer,
            indent = { enabled = false },
            input = { enabled = false },
            notifier = notifier,
            picker = picker,
            quickfile = { enabled = false },
            scope = { enabled = false },
            scroll = { enabled = false },
            statuscolumn = { enabled = false },
            words = { enabled = false },
            styles = { enabled = false },
        },
        keys = {
            -- Top Pickers & Explorer
            { "<leader><space>", function() Snacks.picker.smart() end,           desc = "Smart Find Files" },
            { "<leader>,",       function() Snacks.picker.buffers() end,         desc = "Buffers" },
            { "<leader>/",       function() Snacks.picker.grep() end,            desc = "Grep" },
            { "<leader>:",       function() Snacks.picker.command_history() end, desc = "Command History" },
            { "<leader>n",       function() Snacks.picker.notifications() end,   desc = "Notification History" },
            { "<leader>e",       function() Snacks.explorer() end,               desc = "File Explorer" },
        },
    },
}
