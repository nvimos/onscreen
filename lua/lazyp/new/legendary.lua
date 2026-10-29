-- legendary.nvim: palette of keymaps, commands, autocmds (vim.ui.select). Keys: lua/genja/map-plugin/legendary.lua.
-- Source: fork 0king/legendary.nvim (adds a command palette, explorer and layout catalogues).
-- Original: mrjones2014/legendary.nvim -- archived: 2025-04
local Maps = require('genja.map-plugin')

---@type LazySpec
return {
	'0king/legendary.nvim',
	cmd = 'Legendary',
	keys = Maps:keys(),
	opts = {
		-- keys from lazy specs' `keys` (with their desc) show up in the list
		extensions = { lazy_nvim = true },
		-- frecency needs sqlite.lua; plain most-recent-first instead
		sort = { frecency = false },
	},
	config = function(_, opts)
		require('legendary').setup(opts)
		Maps:mappings(opts)
	end,
}
