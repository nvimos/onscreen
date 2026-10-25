-- idea 13: symbol outline sidebar, nav float and telescope picker.
-- Treesitter first (json, yaml and 70+ more), LSP as fallback.
-- Usage and keys: doc-wip/readme.idea13-dropbar-aerial.outer-key.md

local Maps = require('genja.map-plugin')

---@type LazySpec
return {
	'stevearc/aerial.nvim',
	dependencies = {
		'nvim-treesitter/nvim-treesitter',
		'nvim-tree/nvim-web-devicons',
	},
	cmd = { 'AerialToggle', 'AerialOpen', 'AerialNavToggle', 'AerialNavOpen', 'AerialNext', 'AerialPrev' },
	keys = Maps:keys(),
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
		-- the nav float closes on <C-c> only by default; the listed keys are merged into aerial's
		nav = {
			keymaps = { ['<Esc>'] = 'actions.close' },
			-- 5% see-through (aerial's default is 10); the sidebar is a split, winblend doesn't apply
			win_opts = { cursorline = true, winblend = 5 },
		},
		highlight_on_hover = true,
		-- defaults kept: off above 10000 lines or 2 MB; json shows object keys
		-- (Class), yaml mappings, lists and `name:` items (Class, Enum, Module)
	},
}
