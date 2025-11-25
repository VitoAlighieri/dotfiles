return {
    {
        'akinsho/toggleterm.nvim',
        version = "*",
        config = function()
            require("toggleterm").setup({
                direction = "float",
                border = "curved",
                shell = 'pwsh',
            })
        end
    }
}
