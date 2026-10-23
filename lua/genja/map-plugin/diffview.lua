-- Keys for lua/lazyp/git/diffview.lua.

---@param Maps genja.MapPlugin
return function(Maps)
	local spec_name = Maps.current_file()

	Maps:add_keys(spec_name, {
		{ '<leader>md', '<cmd>DiffviewOpen<cr>',          desc = 'UI: git diff, changes (diffview)' },
		{ '<leader>mh', '<cmd>DiffviewFileHistory %<cr>', desc = 'UI: git history, this file (diffview)' },
		{ '<leader>mH', '<cmd>DiffviewFileHistory<cr>',   desc = 'UI: git history, repo (diffview)' },
		{ '<leader>mxd', '<cmd>DiffviewClose<cr>',        desc = 'UI: close diffview' },
	})
end
