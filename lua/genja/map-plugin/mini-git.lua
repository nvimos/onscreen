-- Keys for lua/lazyp/git/mini-git.lua.

---@param Maps genja.MapPlugin
return function(Maps)
	local spec_name = Maps.current_file()

	Maps:add_mappings(spec_name, function(_)
		-- normal: commit of the line (or diff hunk / log entry) under the cursor;
		-- visual: log of the selected lines
		vim.keymap.set({ 'n', 'x' }, '<leader>hc', function()
			require('mini.git').show_at_cursor()
		end, { desc = 'Git: blame commit at cursor (mini.git)' })
	end)
end
