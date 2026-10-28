-- :Messages [-dump|-quick|-loc]: :messages as a jump list (lua/genja/ext/messages.lua).
vim.api.nvim_create_user_command('Messages', function(cmd)
	require('genja.ext.messages').command(cmd.args)
end, {
	nargs = '?',
	complete = function() return { '-dump', '-quick', '-loc' } end,
	desc = 'Messages: scratch buffer (-dump), append file:line to quickfix (-quick) or loclist (-loc)',
})
