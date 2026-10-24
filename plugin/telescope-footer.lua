-- Prototype: key footer in every telescope picker (lua/genja/telescope-footer.lua).
vim.api.nvim_create_autocmd('FileType', {
	pattern = 'TelescopePrompt',
	group = vim.api.nvim_create_augroup('genja_telescope_footer', { clear = true }),
	callback = function(ev)
		-- the layout and the picker's own maps exist once find() is done
		vim.schedule(function() require('genja.telescope-footer').attach(ev.buf) end)
	end,
})

vim.api.nvim_create_user_command('TelescopeFooter', function() require('genja.telescope-footer').toggle() end,
	{ desc = 'Telescope: key footer on/off (prototype)' })
