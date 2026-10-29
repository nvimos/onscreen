local pplx = require('genja.ext.perplexity')

local map = vim.keymap.set
map('n', '<leader>pl', function() pplx.search(vim.api.nvim_get_current_line()) end, { desc = 'Perplexity: line' })
map('n', '<leader>pw', function() pplx.search(vim.fn.expand('<cword>')) end, { desc = 'Perplexity: word' })
map('n', '<leader>py', function() pplx.search(vim.fn.getreg('"')) end, { desc = 'Perplexity: yank' })
map('x', '<leader>ps', function() pplx.selection() end, { desc = 'Perplexity: selection' })

vim.api.nvim_create_user_command(
	'Pplx',
	function(o) pplx.search(o.args) end,
	{ nargs = '+' })
