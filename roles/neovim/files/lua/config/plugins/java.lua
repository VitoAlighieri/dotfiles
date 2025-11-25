   return {
       {
           "mfussenegger/nvim-jdtls",
           dependencies = { "neovim/nvim-lspconfig" },
           ft = { "java" },
           config = function()
               local jdtls_ok, jdtls = pcall(require, "jdtls")
               if not jdtls_ok then
                   return
               end

               -- Find root directory of the project
               local root_markers = { ".git", "mvnw", "gradlew", "pom.xml", "build.gradle" }
               local root_dir = require("jdtls.setup").find_root(root_markers)
               if root_dir == "" then
                   root_dir = vim.fn.getcwd()
               end

               -- Set data directory
               local data_dir = vim.fn.stdpath("data") .. "/jdtls-workspace/"
               local project_name = vim.fn.fnamemodify(root_dir, ":p:h:t")
               local workspace_dir = data_dir .. project_name

               -- Get the mason install path
               local install_path = require("mason-registry").get_package("jdtls"):get_install_path()

               -- Find the jdtls launcher
               local launcher = vim.fn.glob(install_path .. "/plugins/org.eclipse.equinox.launcher_*.jar")

               -- Find config directory
               local config_dir
               if vim.fn.has("win32") == 1 then
                   config_dir = install_path .. "/config_win"
               elseif vim.fn.has("mac") == 1 then
                   config_dir = install_path .. "/config_mac"
               else
                   config_dir = install_path .. "/config_linux"
               end

               -- Get lombok jar if it exists
               local lombok_jar = install_path .. "/lombok.jar"
               local lombok_path = ""
               if vim.fn.filereadable(lombok_jar) == 1 then
                   lombok_path = "-javaagent:" .. lombok_jar
               end

               -- Setup capabilities
               local capabilities = vim.tbl_deep_extend(
                   "force",
                   {},
                   vim.lsp.protocol.make_client_capabilities(),
                   require('blink.cmp').get_lsp_capabilities()
               )

               -- Setup configuration
               local config = {
                   cmd = {
                       "java",
                       "-Declipse.application=org.eclipse.jdt.ls.core.id1",
                       "-Dosgi.bundles.defaultStartLevel=4",
                       "-Declipse.product=org.eclipse.jdt.ls.core.product",
                       "-Dlog.protocol=true",
                       "-Dlog.level=ALL",
                       lombok_path,
                       "-Xms1g",
                       "--add-modules=ALL-SYSTEM",
                       "--add-opens", "java.base/java.util=ALL-UNNAMED",
                       "--add-opens", "java.base/java.lang=ALL-UNNAMED",
                       "-jar", launcher,
                       "-configuration", config_dir,
                       "-data", workspace_dir,
                   },
                   root_dir = root_dir,
                   capabilities = capabilities,
                   settings = {
                       java = {
                           configuration = {
                               updateBuildConfiguration = "automatic",
                           },
                           maven = {
                               downloadSources = true,
                           },
                           implementationsCodeLens = {
                               enabled = true,
                           },
                           referencesCodeLens = {
                               enabled = true,
                           },
                           inlayHints = {
                               parameterNames = {
                                   enabled = "all",
                               },
                           },
                           format = {
                               enabled = true,
                           },
                           signatureHelp = { enabled = true },
                           completion = {
                               favoriteStaticMembers = {
                                   "org.hamcrest.MatcherAssert.assertThat",
                                   "org.hamcrest.Matchers.*",
                                   "org.junit.Assert.*",
                                   "org.junit.Assume.*",
                                   "org.junit.jupiter.api.Assertions.*",
                                   "org.junit.jupiter.api.Assumptions.*",
                                   "org.junit.jupiter.api.DynamicContainer.*",
                                   "org.junit.jupiter.api.DynamicTest.*",
                                   "java.util.Objects.requireNonNull",
                                   "java.util.Objects.requireNonNullElse",
                               },
                               importOrder = {
                                   "java",
                                   "javax",
                                   "com",
                                   "org",
                               },
                           },
                           sources = {
                               organizeImports = {
                                   starThreshold = 9999,
                                   staticStarThreshold = 9999,
                               },
                           },
                           codeGeneration = {
                               toString = {
                                   template = "${object.className}{${member.name()}=${member.value}, ${otherMembers}}",
                               },
                               hashCodeEquals = {
                                   useJava7Objects = true,
                               },
                               useBlocks = true,
                           },
                       },
                   },
                   flags = {
                       allow_incremental_sync = true,
                   },
                   init_options = {
                       bundles = {},
                   },
               }

               -- Set up extra commands for Java files
               local function attach_jdtls()
                   jdtls.start_or_attach(config)

                   -- Set keymaps after the LSP is attached
                   local bufnr = vim.api.nvim_get_current_buf()
                   local opts = { noremap = true, silent = true, buffer = bufnr }

                   -- Add custom keymaps here
                   vim.keymap.set("n", "<leader>jo", jdtls.organize_imports, opts)
                   vim.keymap.set("n", "<leader>jc", jdtls.compile, opts)
                   vim.keymap.set("n", "<leader>jt", function() jdtls.test_class() end, opts)
                   vim.keymap.set("n", "<leader>jn", function() jdtls.test_nearest_method() end, opts)
               end

               -- Attach the LSP when Java files are opened
               vim.api.nvim_create_autocmd("FileType", {
                   pattern = { "java" },
                   callback = attach_jdtls,
               })

               -- If you're already in a Java file, attach immediately
               if vim.bo.filetype == "java" then
                   attach_jdtls()
               end
           end,
       },
       -- Add debugging capability (optional but recommended)
       --{
       --    "mfussenegger/nvim-dap",
       --    optional = true,
       --    dependencies = {
       --       {
       --            "rcarriga/nvim-dap-ui",
       --            config = function()
       --                require("dapui").setup()
       --            end,
       --        },
       --    },
       --},
   }
