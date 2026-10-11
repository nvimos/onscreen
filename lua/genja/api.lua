-- common-ish function from the nvim api
-- that i want to have shorter names for.


local CONFIG  = vim.fn.stdpath('config')


local function err(msg) vim.api.nvim_echo({ { msg } }, true, { err = true }) end

---@param modname string
---@param cb function(e)  -- callback when loaded. e is the loaded module.
---@return boolean
local function Safeload(...)
	modname, cb = unpack({...})
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
	nosi = function(text) return { silent = true, noremap = true, desc = text } end,
	cmd = function(c) return string.format('<cmd>%s<cr>', c) end,
	cfg = function(c, f) return string.format('<cmd>%s %s/lua/genja/%s<cr>', c, CONFIG, (f or '')) end,
}
