-- https://github.com/LunarVim/Neovim-from-scratch/blob/master/lua/user/plugins.lua

-- pcall(require, 'genja.plugins-dashboard')
-- pcall(require, 'genja.plugins-lsp')

--local plugs = 
return {
	{
		'folke/which-key.nvim',
		event = "VeryLazy",
		init = function()
			vim.o.timeout = true
			vim.o.timeoutlen = 800
			vim.o.timeoutlen = 200
			vim.o.timeoutlen = 1
		end,
		opts = {}
	},

	{
		'numToStr/Comment.nvim',
		opts = { },
		lazy = false,
		config = function()
			require('Comment').setup {
				padding = true, ---Add a space b/w comment and the line
				sticky = true, ---Whether the cursor should stay at its position
				ignore = nil, ---Lines to be ignored while (un)comment
				toggler = { ---LHS of toggle mappings in NORMAL mode
					line = 'gcc', ---Line-comment toggle keymap
					block = 'gbc', ---Block-comment toggle keymap
				},
				opleader = { ---LHS of operator-pending mappings in NORMAL and VISUAL mode
					line = 'gc', ---Line-comment keymap
					block = 'gb', ---Block-comment keymap
				},
				extra = { ---LHS of extra mappings
					above = 'gcO', ---Add comment on the line above
					below = 'gco', ---Add comment on the line below
					eol = 'gcA', ---Add comment at the end of line
				},
				---Enable keybindings
				---NOTE: If given `false` then the plugin won't create any mappings
				mappings = {
					basic = true, ---Operator-pending mapping; `gcc` `gbc` `gc[count]{motion}` `gb[count]{motion}`
					extra = true, ---Extra mapping; `gco`, `gcO`, `gcA`
				},
				pre_hook = nil, ---Function to call before (un)comment
				post_hook = nil, ---Function to call after (un)comment
			}

		end
	},

	-- https://github.com/nvim-telescope/telescope-live-grep-args.nvim
	{
		'nvim-telescope/telescope.nvim',
		branch = '0.1.x',
		dependencies = {
			'nvim-lua/plenary.nvim',
			'LinArcX/telescope-env.nvim',
		},
		config = function()
		end
	},

	{
		"nvim-neo-tree/neo-tree.nvim",
		branch = "v3.x",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-lua/plenary.nvim",
			"nvim-tree/nvim-web-devicons",
			"MunifTanjim/nui.nvim",
			"3rd/image.nvim",
		},
		keys = { { "<leader>fw", "<cmd>Neotree toggle<cr>", desc = "NeoTree" }, },
		config = function() require("neo-tree").setup() end,
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



	-- {
	-- 	'MeanderingProgrammer/dashboard.nvim',
	-- 	event = 'VimEnter',
	-- 	dependencies = {
	-- 		{ 'MaximilianLloyd/ascii.nvim', dependencies = { 'MunifTanjim/nui.nvim' } },
	-- 	},
	-- 	config = function()
	-- 		-- local s = require('dashboard.sections');
	-- 		-- local t = s.startuptime();
	-- 		-- local v = s.version();

	-- 		local d = require('dashboard.sections')
	-- 		local t = d.startuptime()
	-- 		local v = d.version()


	-- 		require('dashboard').setup({
	-- 			-- require('ascii').get_random_global()
	-- 			date_format = '%Y-%m-%d %H:%M',
	-- 			header = require('ascii').art.text.neovim.dos_rebel,
	-- 			footer = { '...' , t , v },
	-- 			directories = START_DIRS,
	-- 		})
	-- 	end,
	-- }


	-- https://github.com/ray-x/go.nvim
	{ "rcarriga/nvim-dap-ui", dependencies = {"mfussenegger/nvim-dap", "nvim-neotest/nvim-nio"} },
	{
		"ray-x/go.nvim",
		ft = { "go", 'gomod' },
		event = { "CmdlineEnter" },
		config = function() require("go").setup() end,
		build = ':lua require("go.install").update_all_sync()', -- if you need to install/update all binaries
		dependencies = { -- optional packages
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
