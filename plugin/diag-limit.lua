-- Diagnostics limit: the first 3 per severity and buffer are drawn (lua/genja/diag-limit.lua).
require('genja.diag-limit').setup()

vim.keymap.set('n', '<leader>tt3', function() require('genja.diag-limit').toggle() end,
	{ desc = 'Toggle: diag limit, first 3 per severity' })
