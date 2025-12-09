return {
    {
        "neovim/nvim-lspconfig",
        dependencies = {
            "williamboman/mason.nvim",
            "williamboman/mason-lspconfig.nvim",
            "Hoffs/omnisharp-extended-lsp.nvim",
            'saghen/blink.cmp',
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
                    "omnisharp",
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



                    -- [ C# SETUP ] --
                    ["omnisharp"] = function()
                        local lspconfig = require("lspconfig")
                        local pid = vim.fn.getpid()
                        local util = lspconfig.util

                        lspconfig.omnisharp.setup({
                            cmd = { "omnisharp", "--languageserver", "--hostPID", tostring(pid) },

                            capabilities = capabilities,

                            root_dir = function(fname)
                                return util.root_pattern("*.sln", "*.csproj", ".git")(fname)
                                    or util.path.dirname(fname)
                            end,

                            enable_editorconfig_support = true,
                            enable_ms_build_load_projects_on_demand = true,
                            enable_roslyn_analyzers = true,
                            analyze_open_documents_only = false,
                            enable_import_completion = true,
                            organize_imports_on_format = true,
                            sdk_include_prereleases = true,

                            handlers = {
                                ["textDocument/definition"]     = require("omnisharp_extended").definition_handler,
                                ["textDocument/typeDefinition"] = require("omnisharp_extended")
                                    .type_definition_handler,
                                ["textDocument/references"]     = require("omnisharp_extended").references_handler,
                                ["textDocument/implementation"] = require("omnisharp_extended")
                                    .implementation_handler,
                            },

                            on_attach = function(client, bufnr)
                                local opts = { buffer = bufnr, silent = true, noremap = true }

                                -- Para C#, usamos las funciones extendidas (mejor que las LSP normales)
                                vim.keymap.set('n', 'gd', require('omnisharp_extended').lsp_definition, opts)
                                vim.keymap.set('n', 'gr', require('omnisharp_extended').lsp_references, opts)
                                vim.keymap.set('n', 'gi', require('omnisharp_extended').lsp_implementation, opts)
                                vim.keymap.set('n', '<leader>D', require('omnisharp_extended').lsp_type_definition,
                                    opts)

                                if client.server_capabilities.documentFormattingProvider then
                                    vim.api.nvim_create_autocmd("BufWritePre", {
                                        buffer = bufnr,
                                        callback = function()
                                            vim.lsp.buf.format({ bufnr = bufnr, async = false })
                                        end,
                                    })
                                end
                            end,
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

            local lspconfig = require("lspconfig")
            local configs = require("lspconfig.configs")
            local util = require("lspconfig.util")

            -- Define el server ccls si tu versión de lspconfig no lo trae
            if not configs.ccls then
                configs.ccls = {
                    default_config = {
                        cmd = { "ccls" }, -- o ruta absoluta al binario si quieres
                        filetypes = { "c", "cpp", "objc", "objcpp", "cuda" },
                        root_dir = util.root_pattern("compile_commands.json", ".ccls", ".git"),
                        init_options = {
                            cache = {
                                directory = ".ccls-cache",
                            },
                        },
                    },
                }
            end

            local function switch_source_header(client, bufnr)
                local method_name = 'textDocument/switchSourceHeader'
                local params = vim.lsp.util.make_text_document_params(bufnr)
                client:request(method_name, params, function(err, result)
                    if err then
                        error(tostring(err))
                    end
                    if not result then
                        vim.notify('corresponding file cannot be determined')
                        return
                    end
                    vim.cmd.edit(vim.uri_to_fname(result))
                end, bufnr)
            end

            lspconfig.ccls.setup({
                capabilities = capabilities,
                on_attach = function(client, bufnr)
                    vim.api.nvim_buf_create_user_command(bufnr, "LspCclsSwitchSourceHeader", function()
                        switch_source_header(client, bufnr)
                    end, { desc = "Switch between source/header" })
                end,
            })
        end,
    }
}
