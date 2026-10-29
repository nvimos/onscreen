-- :Unsaved [cmd]: pick what to do with modified buffers, then run cmd (lua/genja/ext/unsaved.lua).
-- No -bar: `|` belongs to cmd, so `:Unsaved call X() | qa` runs both after the picker.
vim.api.nvim_create_user_command('Unsaved', function(cmd) require('genja.ext.unsaved').run(cmd.args) end,
	{ nargs = '*', complete = 'command', desc = 'Unsaved buffers: write or discard, then run a command' })
