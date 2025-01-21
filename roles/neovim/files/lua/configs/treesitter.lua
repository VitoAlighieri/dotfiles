local options = {
  ensure_installed = {
    "bash",
    "c",
    "c_sharp",
    "java",
    "lua",
    "luadoc",
    "php",
    "printf",
    "python",
    "vim",
    "vimdoc",
    "yaml",
  },

  highlight = {
    enable = true,
    use_languagetree = true,
  },

  indent = { enable = true },
}

require("nvim-treesitter.configs").setup(options)
