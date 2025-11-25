return {
    {
        'nvim-telescope/telescope.nvim',
        tag = '0.1.8',
        dependencies = {
            'nvim-lua/plenary.nvim',
            {
                'nvim-telescope/telescope-live-grep-args.nvim',
                version = "^1.0.0",
            },
        },
        config = function()
            require('telescope').setup {
                extensions = {}
            }

            require('telescope').load_extension("live_grep_args")
            require('telescope').load_extension("noice")
        end
    },

    {
        "doctorfree/cheatsheet.nvim",
        event = "VeryLazy",
        dependencies = {
            { "nvim-telescope/telescope.nvim" },
            { "nvim-lua/popup.nvim" },
            { "nvim-lua/plenary.nvim" },
        },
        config = function()
            local ctactions = require("cheatsheet.telescope.actions")
            require("cheatsheet").setup({
                bundled_cheetsheets = {
                    enabled = { "default", "lua" },
                    disabled = { "markdown", "netrw", "nerd-fonts", "regex", "unicode" },
                },
                bundled_plugin_cheatsheets = {
                    enabled = { "goto-preview", "telescope.nvim" },
                    disabled = { "auto-session", "octo.nvim", "vim-easy-align", "vim-sandwich", "gitsigns" },
                },
                include_only_installed_plugins = true,
                telescope_mappings = {
                    ["<CR>"] = ctactions.selecto_or_fill_commandline,
                    ['<A-CR>'] = ctactions.select_or_execute,
                    ['<C-Y>'] = ctactions.copy_cheat_value,
                    ['<C-E>'] = ctactions.edit_user_cheatsheet,
                },
            })
        end,
    }
}
