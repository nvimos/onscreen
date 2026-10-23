-- :Morning (idea 30/31): clickable page with start dirs, recent files, todo, untested (lua/genja/morning.lua).
vim.api.nvim_create_user_command('Morning', function() require('genja.morning').open() end,
	{ desc = 'Morning: start dirs, recent files, todo, untested' })
