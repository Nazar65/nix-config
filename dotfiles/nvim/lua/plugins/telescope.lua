return {
	"nvim-telescope/telescope.nvim",
	tag = "0.1.8",
	dependencies = {
		"nvim-lua/plenary.nvim",
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
