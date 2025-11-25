return {
    {
        "folke/which-key.nvim",
        event = "VeryLazy",
        opts = {},
        config = function()
            require("which-key").add({
                { "<leader>f", group = "Find" },
                { "<leader>t", group = "Toggle" },
            })
        end,
    },
}
