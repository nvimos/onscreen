-- idea 13: symbol outline sidebar, nav float and telescope picker.
-- Treesitter first (json, yaml and 70+ more), LSP as fallback.
-- Usage and keys: doc-wip/readme.idea13-dropbar-aerial.outer-key.md

---@type LazySpec
return {
	'stevearc/aerial.nvim',
	dependencies = {
		'nvim-treesitter/nvim-treesitter',
		'nvim-tree/nvim-web-devicons',
	},
	cmd = { 'AerialToggle', 'AerialOpen', 'AerialNavToggle', 'AerialNavOpen', 'AerialNext', 'AerialPrev' },
	keys = {
		-- ! keeps the cursor in the code
		{ '<leader>mo', '<cmd>AerialToggle!<cr>', desc = 'UI: outline sidebar (aerial)' },
		{ '<leader>mO', '<cmd>AerialNavToggle<cr>', desc = 'UI: outline nav float (aerial)' },
		-- extension loaded here, so [o ]o don't pull in telescope
		{ '<leader>ja', function()
			require('telescope').load_extension('aerial')
			vim.cmd('Telescope aerial')
		end, desc = 'Telescope: aerial symbols' },
		-- not { }: those stay paragraph motions; [a ]a are nvim's arglist maps
		{ '[o', '<cmd>AerialPrev<cr>', desc = 'Outline: previous symbol' },
		{ ']o', '<cmd>AerialNext<cr>', desc = 'Outline: next symbol' },
	},
	---@module 'aerial'
	---@type aerial.SetupOpts
	opts = {
		attach_mode = 'global', -- one sidebar that follows the current window
		layout = {
			default_direction = 'prefer_right',
			max_width = { 40, 0.25 },
		},
		-- close on buffers it can't outline (oil, terminal); help is supported (vimdoc query)
		close_automatic_events = { 'unsupported' },
		show_guides = true,
		highlight_on_hover = true,
		-- defaults kept: off above 10000 lines or 2 MB; json shows object keys
		-- (Class), yaml mappings, lists and `name:` items (Class, Enum, Module)
	},
}
