require("config.lazy")
vim.api.nvim_create_autocmd("BufWritePre", {
	pattern = "*",
	callback = function(args)
		require("conform").format({ bufnr = args.buf })
	end,
})
vim.o.guifont = "Hack Nerd Font Mono:h12"
vim.cmd([[colorscheme tokyonight]])
