-- Keys for lua/lazyp/git/diffview.lua.

local SRC = 'lua/genja/map-plugin/diffview.lua: '

-- Same as the F2 item `diffview toggle mode`; diffview is on the runtimepath only after its first command.
local function toggle_mode()
	if not package.loaded['diffview.lib'] or not package.loaded['diffview.lib'].get_current_view() then
		vim.notify(SRC .. 'no diffview open')
		return
	end
	require('diffview.actions').cycle_layout()
end

---@param Maps genja.MapPlugin
return function(Maps)
	local spec_name = Maps.current_file()

	Maps:add_keys(spec_name, {
		{ '<leader>md', '<cmd>DiffviewOpen<cr>',          desc = 'UI: git diff, changes (diffview)' },
		{ '<leader>mh', '<cmd>DiffviewFileHistory %<cr>', desc = 'UI: git history, this file (diffview)' },
		{ '<leader>mH', '<cmd>DiffviewFileHistory<cr>',   desc = 'UI: git history, repo (diffview)' },
		{ '<leader>mxd', '<cmd>DiffviewClose<cr>',        desc = 'UI: close diffview' },
		{ '<leader>mGd', toggle_mode,                     desc = 'UI: git diff view mode, side by side / inline (diffview)' },
	})
end
