-- common-ish function from the nvim api
-- that i want to have shorter names for.

local CONFIG  = vim.fn.stdpath('config')
return {
	CONFIG = CONFIG,
	--
	UserComm = vim.api.nvim_create_user_command,
	err = function(msg) vim.api.nvim_echo({ { msg } }, true, { err = true }) end,
	fn = {
		nosi = function(text) return { silent = true, noremap = true, desc = text } end,
		cmd = function(c) return string.format('<cmd>%s<cr>', c) end,

		cfg = function(c, f) return string.format('<cmd>%s %s/lua/genja/%s<cr>', c, CONFIG, (f or '')) end,
	}
}
