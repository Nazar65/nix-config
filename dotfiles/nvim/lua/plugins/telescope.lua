return {
	"nvim-telescope/telescope.nvim",
	tag = "0.1.8",
	dependencies = {
		"nvim-lua/plenary.nvim",
	},
	keys = {

		{ "<C-s>b", "<cmd>Telescope buffers<cr>", desc = "Search in buffers" },
		{ "<C-s>d", "<cmd>Telescope find_files<cr>", desc = "Search files" },
		{ "<C-s>f", "<cmd>Telescope live_grep<cr>", desc = "Search in files" },
	},
	config = function()
		local telescope = require("telescope")

		telescope.setup({
			file_ignore_patterns = {
				"node_modules/.*",
				".git/.*",
				"var/.*",
				"public/.*",
				"packages/.*",
				"*.log",
				"pub/.*",
				"lib/.*",
				"setup/.*",
				"dev/.*",
				"bin/.*",
				"generated/.*",
			},
		})
	end,
}
