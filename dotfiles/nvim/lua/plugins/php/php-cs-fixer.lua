return {
	"stevearc/conform.nvim",
	config = function()
		require("conform").setup({
			formatters_by_ft = {
				lua = { "stylua" },
				nix = { "alejandra" },
				json = { "prettierd" },
				css = { "prettierd" },
				javascript = { "prettierd" },
				php = { "php-cs-fixer" },
			},
			formatters = {
				["php-cs-fixer"] = {
					command = "php-cs-fixer",
					args = {
						"fix",
						"--config=" .. "/home/nazar/.php-cs-fixer.php",
						"$FILENAME",
					},
					stdin = false,
				},
			},
			format_on_save = {
				lsp_fallback = true,
				async = false,
				timeout_ms = 1000,
			},
			notify_on_error = true,
		})
	end,
}
