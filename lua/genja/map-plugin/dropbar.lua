-- Keys for lua/lazyp/ui/dropbar.lua.
-- Usage: doc-wip/readme.idea13-dropbar-aerial.outer-key.md

---@param Maps genja.MapPlugin
return function(Maps)
	local spec_name = Maps.current_file()

	Maps:add_keys(spec_name, {
		{ '<leader>;', function() require('dropbar.api').pick() end,                desc = 'Dropbar: pick a crumb' },
		{ '[;',        function() require('dropbar.api').goto_context_start() end,  desc = 'Dropbar: start of context' },
		{ '];',        function() require('dropbar.api').select_next_context() end, desc = 'Dropbar: next context' },
	})
end
