-- The right-click menu (lua/genja/popup.lua): per-buffer entries come and go on MenuPopup.

local C = require('helpers.child')
local eq = MiniTest.expect.equality

local child, T = C.fresh(C.NOTES .. [[
	require('genja.popup').setup()
	-- the item names of a menu, as :menu lists them
	_G.items = function(menu)
		local out = {}
		for _, line in ipairs(vim.split(vim.fn.execute('silent! menu ' .. menu), '\n')) do
			local name = line:match('^%s+%d+%s+(.-)%s*$')
			if name and not line:find('^%s+%d+%s+%-') then
				table.insert(out, name)
			end
		end
		return out
	end
	_G.has = function(menu, name)
		return vim.tbl_contains(items(menu), name)
	end
]])

local function right_click()
	child.lua([[vim.api.nvim_exec_autocmds('MenuPopup', {})]])
end

T['markdown buffer: the markdown entries, and Morning'] = function()
	child.lua([[vim.bo.filetype = 'markdown']])
	right_click()
	eq(C.eval(child, [[has('PopUp', 'Markdown: toggle checkbox')]]), true)
	eq(C.eval(child, [[has('PopUp', 'Morning')]]), true)
	eq(C.eval(child, 'notes'), {})
end

T['the next buffer drops the entries of the last one'] = function()
	child.lua([[vim.bo.filetype = 'markdown']])
	right_click()
	child.lua([[vim.cmd.enew() vim.bo.filetype = 'lua']])
	right_click()
	eq(C.eval(child, [[has('PopUp', 'Markdown: toggle checkbox')]]), false)
	eq(C.eval(child, [[has('PopUp', 'Morning')]]), true)
end

T['the LSP submenu: a hidden menu and one item that opens it'] = function()
	right_click()
	eq(C.eval(child, [[has('PopUp', 'LSP actions')]]), true)
	eq(C.eval(child, [[#items(']LSP\\ submenu') > 0]]), true)
end

return T
