return {
    {
        'saghen/blink.cmp',
        dependencies = 'rafamadriz/friendly-snippets',
        version = '*',

        ---@module 'blink.cmp'
        ---@type blink.cmp.Config
        opts = {
            -- 'default' for mappings similar to built-in completion
            -- The default keymap makes ctrl + n (next) and ctrl + p (previous) for navigation
            -- and ctrl + y for accept auto-completion
            keymap = { preset = 'default' },

            completion = {
                trigger = {
                    show_on_keyword = true,
                    show_on_trigger_character = true,
                },
                documentation = {
                    auto_show = true,
                    auto_show_delay_ms = 500,
                },
                menu = {
                    draw = {
                        columns = {
                            { "label",     "label_description", gap = 1 },
                            { "kind_icon", "kind",              gap = 1 },
                        },
                        treesitter = { "lsp" },
                    },
                },
            },

            appearance = {
                use_nvim_cmp_as_default = true,
                nerd_font_variant = 'mono',
            },

            signature = { enabled = true }
        },
    }
}
