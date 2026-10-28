-- blink.cmp on the command line (plug-wip/genja-completion011.nvim/lua/genja/completion/cmdline.lua).
-- `make test D=completion` in tests/.
local Helpers = require('helpers.completion')
local child = MiniTest.new_child_neovim()
local C = Helpers.new(child)
local eq = MiniTest.expect.equality

---@param ok boolean
---@param msg? string
local function check(ok, msg)
	if not ok then
		error(msg or 'check failed', 2)
	end
end

local T = MiniTest.new_set({
	hooks = {
		pre_once = C.boot,
		post_case = C.esc,
		post_once = function() child.stop() end,
	},
})

---Wait for items on the command line; their labels. 8 s: the first cmdline completion of a
---fresh child is slow.
---@return string[]
local function cmd_items()
	local got = {}
	require('helpers.timing').wait(function()
		got = C.items()
		return #got > 0
	end, 8000)
	return got
end

T[': commands, menu opens by itself'] = function()
	child.type_keys(':', 'echoh')
	check(Helpers.has(cmd_items(), 'cmdline:echohl'))
	eq(C.wait_menu(), true)
end

T[': file names'] = function()
	local dir = C.scratch('conf')
	C.esc()
	child.cmd('cd ' .. vim.fn.fnameescape(dir))
	child.type_keys(':', 'e ab')
	check(Helpers.has_match(cmd_items(), '^cmdline:abcdir'))
end

T[': help topics'] = function()
	child.type_keys(':', 'h nvim_buf_get_li')
	check(Helpers.has_match(cmd_items(), '^cmdline:nvim_buf_get_lines'))
end

T['<C-j> / <C-k> walk the open menu'] = function()
	child.type_keys(':', 'ec')
	cmd_items()
	-- the menu and its first selection come a moment after the items
	local first = require('helpers.timing').wait(C.selected, 3000)
	child.type_keys('<C-j>')
	check(C.selected() ~= first, 'selection did not move')
	child.type_keys('<C-k>')
	eq(C.selected(), first)
end

T['<Down> / <Up> walk the open menu'] = function()
	child.type_keys(':', 'ec')
	cmd_items()
	local first = require('helpers.timing').wait(C.selected, 3000)
	child.type_keys('<Down>')
	check(C.selected() ~= first, 'selection did not move')
	child.type_keys('<Up>')
	eq(C.selected(), first)
end

T['<Up> without a menu: history'] = function()
	child.type_keys(':', 'let g:hist_probe = 1', '<CR>')
	child.type_keys(':', '<Up>')
	eq(child.fn.getcmdline(), 'let g:hist_probe = 1')
end

T['/ search: buffer words'] = function()
	C.scratch('conf', '', { 'zebrafish one', '' })
	C.esc()
	child.type_keys('/', 'zebr')
	check(Helpers.has(cmd_items(), 'buffer:zebrafish'))
end

return T
