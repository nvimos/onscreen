-- Keys for lua/lazyp/new/genja-paste-ai.lua.

---@param Maps genja.MapPlugin
return function(Maps)
	local spec_name = Maps.current_file()
	local function ps() return require('genja-paste-ai') end

	Maps:add_keys(spec_name, {
		{ '<leader>pl', function() ps().search(vim.api.nvim_get_current_line()) end, desc = 'Lookup: paste search line' },
		{ '<leader>pw', function() ps().search(vim.fn.expand('<cword>')) end, desc = 'Lookup: paste search word' },
		{ '<leader>py', function() ps().search(vim.fn.getreg('"')) end, desc = 'Lookup: paste search yank' },
		{ '<leader>ps', function() ps().selection() end, mode = 'x', desc = 'Lookup: paste search selection' },
	})
end
