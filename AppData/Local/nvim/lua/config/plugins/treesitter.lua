return {
    {
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate",
        config = function()
            require 'nvim-treesitter.configs'.setup {
                ensure_installed = { "bash", "c", "c_sharp", "lua", "query", "markdown", "markdown_inline", "regex", "vim", "vimdoc" },
                sync_install = false,
                auto_install = false,
                ignore_install = {},
                modules = {},
                highlight = {
                    enable = true,
                    disable = function(_, bufnr)
                        -- Normaliza bufnr: puede venir como number, o como tabla de varias formas
                        if type(bufnr) ~= "number" then
                            if type(bufnr) == "table" then
                                bufnr = bufnr.buf or bufnr.bufnr or bufnr[1]
                            end
                            if type(bufnr) ~= "number" then
                                bufnr = vim.api.nvim_get_current_buf()
                            end
                        end

                        -- Evita buffers especiales (help, prompt, nofile, etc.)
                        if vim.bo[bufnr].buftype ~= "" then
                            return true
                        end

                        local name = vim.api.nvim_buf_get_name(bufnr)
                        if name == "" then
                            return false
                        end

                        local max_filesize = 200 * 1024 -- 200KB
                        local uv = vim.uv or vim.loop
                        local ok, stats = pcall(uv.fs_stat, name)
                        return ok and stats and stats.size > max_filesize
                    end,
                    additional_vim_regex_highlighting = false,
                },
            }
        end,
    },
}
