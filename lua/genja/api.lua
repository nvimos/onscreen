-- common-ish function from the nvim api
-- that i want to have shorter names for.


local CONFIG  = vim.fn.stdpath('config')


---@param msg string
local function err(msg) vim.api.nvim_echo({ { msg } }, true, { err = true }) end

---require() that reports instead of throwing.
---@param modname string
---@param cb? fun(module: any) called with the module when it loaded
---@return boolean loaded
local function Safeload(modname, cb)
	local has_modname, module = pcall(require, modname)
	if not has_modname then
		-- require('genja.api').err(string.format('cannot load «%s»', modname))
		err(string.format('cannot load «%s»', modname))
	else
		if cb then
			cb(module)
		end
	end
	return has_modname
end


return {
	CONFIG = CONFIG,
	--
	UserComm = vim.api.nvim_create_user_command,
	Safeload = Safeload,
	err = err,
	---@type fun(text?: string): vim.keymap.set.Opts
	nosi = function(text) return { silent = true, noremap = true, desc = text } end,
	---@type fun(c: string): string '<cmd>c<cr>'
	cmd = function(c) return string.format('<cmd>%s<cr>', c) end,
	---@type fun(c: string, f?: string): string '<cmd>c CONFIG/lua/genja/f<cr>'
	cfg = function(c, f) return string.format('<cmd>%s %s/lua/genja/%s<cr>', c, CONFIG, (f or '')) end,
}
