local on_attach = require("nvchad.configs.lspconfig").on_attach
local on_init = require("nvchad.configs.lspconfig").on_init
local capabilities = require("nvchad.configs.lspconfig").capabilities

-- load defaults i.e lua_lsp
local lspconfig = require "lspconfig"

-- EXAMPLE
lspconfig.servers = {
  "lua_ls",
  "pyright",
  "omnisharp",
  "bash-language-server",
}

local default_servers = { "clangd" }
local nvlsp = require "nvchad.configs.lspconfig"

-- lsps with default config
for _, lsp in ipairs(default_servers) do
  lspconfig[lsp].setup {
    on_attach = nvlsp.on_attach,
    on_init = nvlsp.on_init,
    capabilities = nvlsp.capabilities,
  }
end

lspconfig.lua_ls.setup {
  on_attach = on_attach,
  on_init = on_init,
  capabilities = capabilities,

  settings = {
    Lua = {
      diagnostics = {
        enable = true,
      },
      workspace = {
        library = {
          vim.fn.expand "$VIMRUNTIME/lua",
          vim.fn.expand "$VIMRUNTIME/lua/vim/lsp",
          vim.fn.stdpath "data" .. "/lazy/ui/nvchad_types",
          vim.fn.stdpath "data" .. "/lazy/lazy.nvim/lua/lazy",
          "${3rd}/love2d/library",
        },
        maxPreload = 100000,
        preloadFileSize = 100000,
      },
    },
  },
}

lspconfig.pyright.setup {
  on_attach = on_attach,
  on_init = on_init,
  capabilities = capabilities,

  settings = {
    pyright = {
      disableOrganizeImports = true,
    },
    python = {
      analysis = {
        ignore = { "*" },
      },
    },
  },
}

lspconfig.omnisharp.setup {
  on_attach = on_attach,
  on_init = on_init,
  capabilities = capabilities,

  cmd = { "omnisharp" },
  root_dir = function(fname)
    return require("lspconfig").util.find_git_ancestor(fname) or require("lspconfig").util.path.dirname(fname)
  end,

  RoslynExtensionsOptions = {
    EnableAnalyzersSupport = true,
    EnableImportCompletion = true,
    AnalyzeOpenDocumentsOnly = false,
  },
}

lspconfig.bashls.setup {
  on_attach = on_attach,
  on_init = on_init,
  capabilities = capabilities,

  cmd = { "bash-language-server", "start" },
  filetypes = { "bash", "sh", "make" },
}
