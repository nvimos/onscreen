-- git status in oil
-- colored names and symbols (+ ~ ? D !),
-- dirs show the top status inside.
--
-- Alternative: refractalize/oil-git-status.nvim (two sign columns like `git status -s`;
-- needs signcolumn = 'yes:2' in oil.lua win_options).

---@type LazySpec
return {
	{
		'malewicz1337/oil-git.nvim',
		dependencies = { 'stevearc/oil.nvim' },
		event = 'VeryLazy', -- refreshes on BufEnter, so oil buffers opened earlier get status on re-entry
		opts = {
			-- symbol_position = 'signcolumn', -- default 'eol'; oil.lua already has signcolumn = 'yes'
		},
	},
}
