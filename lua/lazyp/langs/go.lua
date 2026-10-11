---@type LazySpec
return {
	-- Neovim plugin for Go
	"ray-x/go.nvim",
	ft = { "go", 'gomod' },
	cmd = { "GoInstallBinaries", "GoUpdateBinaries", "GoInstallBinary" }, -- usable outside go buffers
	-- lsp_inlay_hints: go.nvim would turn inlay hints on for every buffer; toggle with <leader>tth
	config = function() require("go").setup({ lsp_inlay_hints = { enable = false } }) end,
	build = ':lua require("go.install").update_all_sync()', -- if you need to install/update all binaries
	dependencies = {
		'ray-x/guihua.lua',
		'neovim/nvim-lspconfig',
		'nvim-treesitter/nvim-treesitter',

		'mfussenegger/nvim-dap',
		'rcarriga/nvim-dap-ui',
		'theHamsta/nvim-dap-virtual-text',

	},
}
