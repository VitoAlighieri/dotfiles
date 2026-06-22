return {
    {
        "mfussenegger/nvim-lint",
        event = { "BufReadPre", "BufNewFile" },
        config = function()
            local lint = require("lint")

            lint.linters_by_ft = {
                lua = { "luacheck" },
            }

            local augroup = vim.api.nvim_create_augroup("Linting", { clear = true })

            vim.api.nvim_create_autocmd({ "BufWritePost", "BufEnter", "InsertLeave" }, {
                group = augroup,
                callback = function()
                    local bt = vim.bo.buftype
                    if bt ~= "" then return end
                    lint.try_lint()
                end,
            })

            vim.api.nvim_create_user_command("Lint", function()
                lint.try_lint()
            end, {})
        end,
    },
}
