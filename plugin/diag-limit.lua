-- Diagnostics limit: the first 3 per severity and buffer are drawn (lua/genja/ext/diag-limit.lua).
require('genja.ext.diag-limit').setup()

vim.keymap.set('n', '<leader>tt3', function() require('genja.ext.diag-limit').toggle() end,
	{ desc = 'Toggle: diag limit, first 3 per severity' })
