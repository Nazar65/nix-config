return {
  "neovim/nvim-lspconfig",

  dependencies = {
    "williamboman/mason.nvim"
  },

  config = function()
    local lspconfig = require("lspconfig")
    local mason = require("mason")

    mason.setup()

     lspconfig.intelephense.setup({
          root_dir = lspconfig.util.root_pattern(".git"),
     });

  end,
}
