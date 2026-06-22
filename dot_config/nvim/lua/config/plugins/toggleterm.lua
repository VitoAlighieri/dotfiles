return {
    {
        'akinsho/toggleterm.nvim',
        version = "*",
        config = function()
            -- En Windows usamos pwsh; en el resto, la shell por defecto del sistema.
            local shell = vim.fn.has("win32") == 1 and "pwsh" or vim.o.shell
            require("toggleterm").setup({
                direction = "float",
                border = "curved",
                shell = shell,
            })
        end
    }
}
