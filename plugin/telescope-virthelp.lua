-- Prototype: key help in the results of every telescope picker (lua/genja/telescope-virthelp.lua).
vim.api.nvim_create_autocmd('FileType', {
	pattern = 'TelescopePrompt',
	group = vim.api.nvim_create_augroup('genja_telescope_virthelp', { clear = true }),
	callback = function(ev)
		-- the layout and the picker's own maps exist once find() is done
		vim.schedule(function() require('genja.telescope-virthelp').help_attach(ev.buf) end)
	end,
})
