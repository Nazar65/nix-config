return {
	"romgrk/barbar.nvim",
	dependencies = {
		"lewis6991/gitsigns.nvim", -- OPTIONAL: for git status
		"nvim-tree/nvim-web-devicons", -- OPTIONAL: for file icons
	},
	init = function()
		vim.g.barbar_auto_setup = false
	end,
	opts = {
		-- lazy.nvim will automatically call setup for you. put your options here, anything missing will use the default:
		animation = true,
		-- insert_at_start = true,
	},
	keys = {
		{ "<A-,>", ":BufferPrevious<cr>", desc = "previous buffer" },
		{ "<A-.>", ":BufferNext<cr>", desc = "next buffer" },
		{ "<A-1>", ":BufferGoto 1<cr>", desc = "1 buffer" },
		{ "<A-2>", ":BufferGoto 2<cr>", desc = "2 buffer" },
		{ "<A-3>", ":BufferGoto 3<cr>", desc = "3 buffer" },
		{ "<A-4>", ":BufferGoto 4<cr>", desc = "4 buffer" },
		{ "<A-5>", ":BufferGoto 5<cr>", desc = "5 buffer" },
		{ "<A-6>", ":BufferGoto 6<cr>", desc = "6 buffer" },
		{ "<A-7>", ":BufferGoto 7<cr>", desc = "7 buffer" },
		{ "<A-8>", ":BufferGoto 8<cr>", desc = "8 buffer" },
		{ "<A-9>", ":BufferGoto 9<cr>", desc = "9 buffer" },
		{ "<A-m>", ":BufferMovePrevious<cr>", desc = "Move bnuffer previous" },
		{ "<A-c>", ":BufferClose<cr>", desc = "close bnuffer" },
		{ "<A-/>", ":BufferMoveNext<cr>", desc = "Move bnuffer next" },
	},
}
