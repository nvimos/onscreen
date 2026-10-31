-- Diagnostic virtual text in one column per paragraph (lua/genja/ext/diag-align.lua).
-- Loads before plugin/diag-limit.lua, so the limit wrapper sits outside this one.
require('genja.ext.diag-align').setup()

vim.keymap.set('n', '<leader>tta', function() require('genja.ext.diag-align').toggle() end,
	{ desc = 'Toggle: diag align, one column per paragraph' })
