---@type LazySpec
return {
	{
		'folke/which-key.nvim',
		dependencies = {
			'echasnovski/mini.icons',
			'nvim-tree/nvim-web-devicons',
		},
		event = "VeryLazy",
		-- config = function()
		-- 	-- DEPRECATED https://medium.com/@shaikzahid0713/which-key-7554ac347c9d
		-- 	-- local status_ok, which_key = pcall(require, "which-key")
		-- 	-- if not status_ok then vim.notify('failed to load which-key.nvim') return
		-- 	-- end
		--
		-- 	local setup = {
		-- 		keys = {
		-- 			-- scroll_down = "<c-d>", -- binding to scroll down inside the popup
		-- 			-- scroll_up = "<c-u>", -- binding to scroll up inside the popup
		-- 			scroll_down = "<F3>", -- binding to scroll down inside the popup
		-- 			scroll_up = "<F2>", -- binding to scroll up inside the popup
		-- 		},
		--
		-- 		icons = {
		-- 			breadcrumb = "»", -- symbol used in the command line area that shows your active key combo
		-- 			-- separator = "➜", -- symbol used between a key and it's label
		-- 			separator = "-", -- symbol used between a key and it's label
		-- 			group = "+", -- symbol prepended to a group
		-- 		},
		--
		-- 		win = {
		-- 			border = "rounded", -- none, single, double, shadow
		-- 			position = "bottom", -- bottom, top
		-- 			margin = { 1, 3, 1, 3 }, -- extra window margin [top, right, bottom, left]
		-- 			padding = { 0, 0, 0, 0 }, -- extra window padding [top, right, bottom, left]
		-- 			winblend = 0,
		-- 		},
		-- 		preset = "modern",
		-- 		layout = {
		-- 			-- height = { min = 3, max = 25 }, -- min and max height of the columns
		-- 			-- width = { min = 20, max = 50 }, -- min and max width of the columns
		-- 			spacing = 0, -- spacing between columns
		-- 			align = "center", -- align columns left, center or right
		-- 		},
		-- 	}
		-- 	require("which-key").setup(setup)
		--
		-- 	-- local mappings = {
		-- 	-- 	-- ["k"] = { "<cmd>bdelete<CR>", "Kill Buffer" },  -- Close current file
		-- 	-- 	-- ["p"] = { "<cmd>Lazy<CR>", "Plugin Manager" }, -- Invoking plugin manager
		-- 	-- 	-- ["q"] = { "<cmd>wqall!<CR>", "Quit" }, -- Quit Neovim after saving the file
		-- 	-- 	-- ["w"] = { "<cmd>w!<CR>", "Save" }, -- Save current file
		-- 	-- }
		-- 	-- local map_opts = {
		-- 	-- 	mode = "n", -- NORMAL mode
		-- 	-- 	prefix = "<leader>",
		-- 	-- 	buffer = nil, -- Global mappings. Specify a buffer number for buffer local mappings
		-- 	-- 	silent = true, -- use `silent` when creating keymaps
		-- 	-- 	noremap = true, -- use `noremap` when creating keymaps
		-- 	-- 	nowait = true, -- use `nowait` when creating keymaps
		-- 	-- }
		-- 	-- require("which-key").register()
		-- end,

		init = function()
			vim.o.timeout = true
			-- 'timeoutlen': ms Neovim waits for the next key of a mapped sequence
			-- (<leader>f, then f for <leader>ff) before it gives up, or before it
			-- runs a shorter mapping that is also a prefix (<leader>f vs <leader>ff).
			-- which-key opens its popup after its own opts.delay, not this value,
			-- but this still decides how long ambiguous prefixes wait.
			-- Low (1-200): ambiguous mappings fire almost at once; slow multi-key
			--   sequences get cut off. For fast typists with few overlapping maps.
			-- High (500-1000): time to finish long sequences, but a shorter
			--   overlapping map waits that long before it runs.
			-- Set to 300 in lua/genja/opt.lua; uncomment to override it here.
			-- vim.o.timeoutlen = 800
			-- vim.o.timeoutlen = 200
			-- vim.o.timeoutlen = 1
		end,
		---@type wk.Opts
		opts = {
			-- preset = "helix",
		},
		-- keys = {
		-- 	{
		-- 		"<leader>?", function() require("which-key").show({ global = false }) end, desc = "local maps (which-key)",
		-- 	},
		-- },

	},

}
