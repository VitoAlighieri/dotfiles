return {
    {
        "WhoIsSethDaniel/mason-tool-installer.nvim",
        dependencies = { "williamboman/mason.nvim" },
        cmd = { "MasonToolsInstall", "MasonToolsUpdate" },
        config = function()
            require("mason-tool-installer").setup({
                ensure_installed = {
                },
                auto_update = false,
                run_on_start = true,
                start_delay = 3000,
            })
        end,
    },
}
