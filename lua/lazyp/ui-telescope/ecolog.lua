return {
	-- todo: test me 2026
	"ph1losof/ecolog2.nvim",

	ft = { "dotenv", "sh", "bash", "zsh" },
	pattern = { "*.env", ".env", ".env.*", "*.env.*" },

	cmd = {
		"EcologPeek",
		"EcologSelect",
		"EcologGoto",
		"EcologGotoVar",
		"EcologRefresh",
		"EcologTelescope",
	},

	keys = {
		{ "<leader>gE",  "<cmd>EcologGoto<cr>",      desc = "Env: go to env file",   noremap = true, silent = true },
		{ "<leader>gEp", "<cmd>EcologPeek<cr>",      desc = "Env: peek variable",    noremap = true, silent = true },
		{ "<leader>gEs", "<cmd>EcologSelect<cr>",    desc = "Env: select env file",  noremap = true, silent = true },
		{ "<leader>gEv", "<cmd>EcologTelescope<cr>", desc = "Env: browse variables", noremap = true, silent = true },
	},

	dependencies = {
		"nvim-telescope/telescope.nvim", -- optional
	},

	---@type table
	opts = {},
}
