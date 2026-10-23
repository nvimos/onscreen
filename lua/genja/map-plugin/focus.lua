-- Keys for lua/lazyp/ui/focus.lua.

local SRC = 'lua/genja/map-plugin/focus.lua: '

---<leader>tPf: focus on/off for all windows.
---Not focus's own toggle: it counts an excluded buffer as "off" and turns focus on instead.
local function toggle_focus()
	local focus = require('focus')
	if vim.g.focus_disable then
		vim.g.focus_disable = false
		focus.resize('autoresize')
		vim.notify(SRC .. 'focus on')
	else
		vim.g.focus_disable = true
		vim.cmd('wincmd =')
		vim.notify(SRC .. 'focus off')
	end
end

---@param Maps genja.MapPlugin
return function(Maps)
	local spec_name = Maps.current_file()

	Maps:add_keys(spec_name, {
		{ '<leader>tPf', toggle_focus, desc = 'Toggle: focus (auto-resize splits)' },
	})
end
