return {
    {
        'catppuccin/nvim',
        name = "catppuccin",
        config = function()
            require('catppuccin').setup({
                flavour = "macchiato",
                transparent_background = false,
                integrations = {
                    blink_cmp = true,
                    treesitter = true,
                    noice = true,
                    notify = false,
                    mason = true,
                    telescope = {
                        enabled = true,
                    },
                    which_key = true,
                    -- Add alpha
                }
            })
        end,
    }
}
