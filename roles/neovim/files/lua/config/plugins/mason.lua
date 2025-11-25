return {
    {
        "neovim/nvim-lspconfig",
        dependencies = {
            "williamboman/mason.nvim",
            "williamboman/mason-lspconfig.nvim",
            'saghen/blink.cmp',
            "Hoffs/omnisharp-extended-lsp.nvim",
            {
                "folke/lazydev.nvim",
                ft = "lua", -- Only load lua files
                opts = {
                    library = {
                        -- See the configuration section for more details
                        -- Load luvit types when the `vim.uv` word is found
                        { path = "${3rd}/luv/library", words = { "vim%.uv" } },
                        { path = "snacks.nvim",        words = { "Snacks" } },
                        { path = "lazy.nvim",          words = { "LazyVim" } },
                    },
                },
            },
        },

        config = function()
            local capabilities = vim.tbl_deep_extend(
                "force",
                {},
                vim.lsp.protocol.make_client_capabilities(),
                require('blink.cmp').get_lsp_capabilities())

            require("mason").setup({
                build = ":MasonUpdate",
                ui = {
                    icons = {
                        package_installed = "✓",
                        package_pending = "➜",
                        package_uninstalled = "✗"
                    }
                }
            })

            require("mason-lspconfig").setup({
                automatic_installation = true,
                ensure_installed = {
                    "bashls",
                    "jdtls",
                    "lua_ls",
                    "pyright",
                    "zls"
                },
                handlers = {
                    function(server_name)
                        require("lspconfig")[server_name].setup({
                            capabilities = capabilities
                        })
                    end,

                    -- [ BASH SETUP ] --
                    ["bashls"] = function()
                        local lspconfig = require("lspconfig")
                        lspconfig.bashls.setup({
                            capabilities = capabilities,
                            cmd = { "bash-language-server", "start" },
                            filetypes = { "bash", "sh" },
                            settings = {
                                bashIde = {
                                    globPattern = vim.env.GLOB_PATTERN or "*@(.sh|.inc|.bash|.command)",
                                },
                            },
                            single_file_support = true,
                        })
                    end,

                    -- [ JAVA SETUP ] --
                    ["jdtls"] = function()
                        -- See nvim-jdtls.lua
                    end,

                    -- [ LUA SETUP ] --
                    ["lua_ls"] = function()
                        local lspconfig = require("lspconfig")
                        lspconfig.lua_ls.setup({
                            capabilities = capabilities,
                            settings = {
                                Lua = {
                                    runtime = { version = "Lua 5.4" },
                                    diagnostics = {
                                        globals = { "bit", "vim", "it", "describe", "before_each", "after_each" },
                                    }
                                }
                            }
                        })
                    end,

                    -- [ PYTHON SETUP ] --
                    ["pyright"] = function()
                        local lspconfig = require("lspconfig")
                        lspconfig.pyright.setup({
                            capabilities = capabilities,
                            settings = {
                                python = {
                                    analysis = {
                                        autoSearchPaths = true,
                                        diagnosticMode = "openFilesOnly",
                                        useLibraryCodeForTypes = true,
                                    }
                                }
                            }
                        })

                    end,

                    -- [ ZIG SETUP ] --
                    zls = function()
                        local lspconfig = require("lspconfig")
                        lspconfig.zls.setup({
                            capabilities = capabilities,
                            root_dir = lspconfig.util.root_pattern(".git", "build.zig", "zls.json"),
                            settings = {
                                zls = {
                                    enable_inlay_hints = true,
                                    enable_snippets = true,
                                    warn_style = true,
                                },
                            },
                        })
                        vim.g.zig_fmt_parse_errors = 0
                        vim.g.zig_fmt_autosave = 0
                    end,
                }
            })
        end,
    }
}
