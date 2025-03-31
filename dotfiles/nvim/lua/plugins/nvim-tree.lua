return {
  "nvim-tree/nvim-tree.lua",
  version = "*",
  lazy = false,
  keys = {
     {"<c-b>", ":NvimTreeFindFileToggle<cr>", desc = "toggle nvim-tree" },
  },
  dependencies = {
    "nvim-tree/nvim-web-devicons",
  },
  config = function()
    require("nvim-tree").setup {
      sort = {
    sorter = "case_sensitive",
  },
    update_focused_file = {
                  enable = true,
                  update_root = true,

               },
  view = {
    width = 30,
  },
  renderer = {
    group_empty = true,
  },
  filters = {
    dotfiles = true,
  },
}
  end,
}
