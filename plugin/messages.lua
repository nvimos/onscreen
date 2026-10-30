-- :Messages [-dump|-quick|-loc|-yank]: :messages as a jump list (lua/genja/ext/messages.lua).
vim.api.nvim_create_user_command('Messages', function(cmd)
	require('genja.ext.messages').command(cmd.args)
end, {
	nargs = '?',
	complete = function() return { '-dump', '-quick', '-loc', '-yank' } end,
	desc = 'Messages: scratch buffer (-dump), append file:line to quickfix (-quick) or loclist (-loc), clipboard (-yank)',
})
