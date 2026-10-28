-- :Morning (idea 30/31): clickable page with start dirs, recent files, todo, untested (lua/genja/ext/morning.lua).
vim.api.nvim_create_user_command('Morning', function() require('genja.ext.morning').open() end,
	{ desc = 'Morning: start dirs, recent files, todo, untested' })
