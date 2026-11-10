-- :ReloadLua and :ReloadLuaGenja (lua/genja/ext/user-command/reload-lua.lua).

local C = require('helpers.child')
local eq = MiniTest.expect.equality

local child, T = C.fresh(C.NOTES .. [[
	require('genja.ext.user-command.reload-lua').setup_user_command()
	-- a module that loads once and fails on every reload
	_G.loads = 0
	package.preload['zz_flaky'] = function()
		loads = loads + 1
		if loads > 1 then
			error('broken on reload')
		end
		return { version = loads }
	end
	require('zz_flaky')
]])

T['ReloadLua requires the module again'] = function()
	child.lua([[package.preload['zz_ok'] = function() return { at = vim.uv.hrtime() } end]])
	local first = C.eval(child, [[require('zz_ok').at]])
	child.cmd('ReloadLua zz_ok')
	eq(C.eval(child, [[require('zz_ok').at ~= ...]], { first }), true)
end

T['ReloadLua keeps the old module when the reload fails'] = function()
	child.cmd('ReloadLua zz_flaky')
	eq(C.eval(child, [[package.loaded['zz_flaky'].version]]), 1)
	eq(C.eval(child, [[notes[#notes]:find('kept the old version', 1, true) ~= nil]]), true)
end

T['ReloadLuaGenja keeps the cwd'] = function()
	local cwd = C.eval(child, 'vim.fn.getcwd()')
	child.cmd('ReloadLuaGenja')
	eq(C.eval(child, 'vim.fn.getcwd()'), cwd)
end

return T
