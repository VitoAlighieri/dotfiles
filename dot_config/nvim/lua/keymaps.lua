-- [ TELESCOPE KEYMAPS ] --
local t_builtin = require('telescope.builtin')

vim.keymap.set("n", "<leader>ff", t_builtin.find_files, { desc = "Find [f]iles" })
vim.keymap.set("n", "<leader>fz", ":lua require('telescope').extensions.live_grep_args.live_grep_args()<CR>",
    { desc = "Find fu[z]zy live grep with args" })

-- [ TOGGLETERM KEYMAPS ] --
vim.keymap.set('n', '<leader>tt', ':ToggleTerm<CR>', { desc = 'Floating [t]erminal', silent = true }) -- Add T(for toggling) group to which key

-- [ CHEATSHEET KEYMAPS ] --
vim.keymap.set('n', '<leader>?', ':Cheatsheet<CR>', { desc = 'Open cheatsheet', silent = true }) -- Add cheatsheet keymaps

-- [ LSP KEYMAPS ] --
vim.api.nvim_create_autocmd('LspAttach', {
    group = vim.api.nvim_create_augroup('UserLspConfig', {}),
    callback = function(ev)
        -- Hover documentation (overrides the K command which usually tries to show man pages)
        vim.keymap.set('n', 'K', vim.lsp.buf.hover,
            { noremap = true, silent = true, buffer = ev.buf, desc = "Show hover documentation" })

        -- LSP actions
        vim.keymap.set('n', 'gD', vim.lsp.buf.declaration,
            { noremap = true, silent = true, buffer = ev.buf, desc = 'Go to [D]eclaration' })
        vim.keymap.set('n', 'gd', vim.lsp.buf.definition,
            { noremap = true, silent = true, buffer = ev.buf, desc = 'Go to [d]efinition' })
        vim.keymap.set('n', 'gi', vim.lsp.buf.implementation,
            { noremap = true, silent = true, buffer = ev.buf, desc = 'List [i]mplementations' })
        vim.keymap.set('n', 'gr', vim.lsp.buf.references,
            { noremap = true, silent = true, buffer = ev.buf, desc = 'List [r]eferences' })
        vim.keymap.set('n', 'gt', vim.lsp.buf.type_definition,
            { noremap = true, silent = true, buffer = ev.buf, desc = 'Go to [t]ype definition' })
        vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help,
            { noremap = true, silent = true, buffer = ev.buf, desc = 'Show signature help' })

        vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename,
            { desc = 'Symbol [r]eferences [r]ename', buffer = ev.buf })
        vim.keymap.set({ 'n', 'v' }, '<leader>ca', vim.lsp.buf.code_action,
            { desc = 'Select [c]ode [a]ction', buffer = ev.buf })
        vim.keymap.set('n', '<leader>kd', function()
            vim.lsp.buf.format { async = true }
        end, { desc = 'Format code', buffer = ev.buf })
    end,
})
