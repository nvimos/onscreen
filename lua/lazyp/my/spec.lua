-- https://github.com/LunarVim/Neovim-from-scratch/blob/master/lua/user/plugins.lua

-- pcall(require, 'genja.plugins-dashboard')
-- pcall(require, 'genja.plugins-lsp')
return {

	{ 'mbbill/undotree' }, -- revert to previous versions of edits
	{ 'rafcamlet/nvim-luapad', lazy = true, cmd = 'Luapad' }, -- evaluate lua in realtime
	{ 'tpope/vim-fugitive', lazy = true, cmd = 'Git' }, -- git ui
	{ 'equalsraf/neovim-gui-shim', enabled = false }, -- neovim-qt fancy context mouse menu popup

	{
		'eandrju/cellular-automaton.nvim',
		cmd = 'CellularAutomaton',
		lazy = false,
		keys = {
			{ '<leader>fml-', '<cmd>CellularAutomaton make_it_rain<cr>', { noremap = true, silent = true, desc = "fml-1"  }},
			{ '<leader>fml=', '<cmd>CellularAutomaton scramble<cr>',  { noremap = true, silent = true, desc = "fml-2"  }}
		},
	},

	{
		'folke/zen-mode.nvim',
		cmd = 'ZenMode',
		lazy = true,
		keys = { { '<leader>mz', '<cmd>ZenMode<cr>',  { noremap = true, silent = true, desc = "zen mode" } } }
	},


	-- { 'folke/neoconf.nvim', cmd = "Neoconf" },
	-- { "folke/neodev.nvim", opts = { } },



	--{
	--	'Wansmer/treesj',
	--	keys = { '<leader>m', '<leader>j', '<space>s' },

	--	dependencies = { 'nvim-treesitter/nvim-treesitter' },
	--	config = function()
	--		require('treesj').setup({--[[ your config ]]})
	--	end,
	--	-- keys = {
	--	--     { "J", "<cmd>TSJToggle<cr>", desc = "Join Toggle" },
	--	-- },
	--	-- opts = { use_default_keymaps = false, max_join_length = 150 },
	--},


	-- https://github.com/ray-x/go.nvim
	{ "rcarriga/nvim-dap-ui", dependencies = { "mfussenegger/nvim-dap", "nvim-neotest/nvim-nio" } },
	{
		"ray-x/go.nvim",
		ft = { "go", 'gomod' },
		event = { "CmdlineEnter" },
		config = function() require("go").setup() end,
		build = ':lua require("go.install").update_all_sync()', -- if you need to install/update all binaries
		dependencies = {                                  -- optional packages
			'ray-x/guihua.lua',
			'neovim/nvim-lspconfig',
			'nvim-treesitter/nvim-treesitter',

			'mfussenegger/nvim-dap',
			'rcarriga/nvim-dap-ui',
			'theHamsta/nvim-dap-virtual-text',

		},
	}
}

--vim.list_extend(P or {}, plugs)
--return P
