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

---Type a menu key and wait until the selection moved. After an item is inserted blink redraws the
---menu; a key typed during that redraw finds no menu and falls back and the key is typed into the line.
---@param key string
---@return integer|nil selected index after the move
local function walk(key)
	local before = C.selected()
	child.type_keys(key)
	local now = require('helpers.timing').wait(function()
		local idx = C.selected()
		return idx ~= before and idx or nil
	end, 1500)
	-- the index moves first; then the item is inserted: wait until the line holds for one read
	-- (the menu may close on the walk, e.g. <Tab> inserting the last item; waiting for it to show
	-- again cost 1.5 s per key)
	local line = child.fn.getcmdline()
	require('helpers.timing').wait(function()
		vim.uv.sleep(100)
		local same = child.fn.getcmdline() == line
		line = child.fn.getcmdline()
		return same
	end, 1500)
	return now
end

T['<M-j> / <M-k> walk the open menu'] = function()
	child.type_keys(':', 'ec')
	cmd_items()
	-- nothing is preselected: the first <M-j> selects item 1
	eq(C.wait_menu(), true)
	eq(C.selected(), nil)
	eq(walk('<M-j>'), 1)
	eq(walk('<M-j>'), 2)
	eq(walk('<M-k>'), 1)
end

T['<Tab> on the open menu inserts the first item'] = function()
	child.type_keys(':', 'term')
	local items = cmd_items()
	eq(C.wait_menu(), true)
	local first = items[1]:gsub('^cmdline:', '')
	eq(walk('<Tab>'), 1)
	eq(child.fn.getcmdline(), first)
end

T['<M-j>, then <Down> / <Up> walk the open menu'] = function()
	child.type_keys(':', 'ec')
	cmd_items()
	eq(C.wait_menu(), true)
	local second = walk('<M-j>')
	check(second ~= nil, '<M-j> did not move')
	check(walk('<Down>') ~= nil, '<Down> did not move')
	eq(walk('<Up>'), second)
end

T['<Up> without a menu: history'] = function()
	child.type_keys(':', 'let g:hist_probe = 1', '<CR>')
	child.type_keys(':', '<Up>')
	eq(child.fn.getcmdline(), 'let g:hist_probe = 1')
end

-- {{{ history: <Up>/<Down> must behave as in plain Vim, menu or not

---Fresh history for `type` (':' or '/') with `entries`, oldest first.
---@param type string
---@param entries string[]
local function history(type, entries)
	child.fn.histdel(type)
	for _, entry in ipairs(entries) do
		child.fn.histadd(type, entry)
	end
end

---Type `key`, give blink time to react (the menu may open on the recalled line), then the cmdline.
---@param key string
---@return string
local function after(key)
	child.type_keys(key)
	vim.uv.sleep(300)
	return child.fn.getcmdline()
end

T['history: <Up> <Up> <Down> <Down> walk back, forward, then the empty line'] = function()
	history(':', { 'let g:h1 = 1', 'let g:h2 = 2' })
	child.type_keys(':')
	eq(after('<Up>'), 'let g:h2 = 2')
	eq(after('<Up>'), 'let g:h1 = 1')
	eq(after('<Down>'), 'let g:h2 = 2')
	eq(after('<Down>'), '')
end

T['history: <Up> after a prefix recalls only matching entries, though the menu is open'] = function()
	history(':', { 'echo "one"', 'let g:y = 1' })
	child.type_keys(':', 'ec')
	cmd_items()
	eq(C.wait_menu(), true)
	eq(after('<Up>'), 'echo "one"')
end

T['history: <Down> on the newest line keeps what was typed'] = function()
	history(':', { 'let g:h1 = 1' })
	child.type_keys(':', 'let g:typed')
	eq(after('<Down>'), 'let g:typed')
end

T['history: a typed key after a menu walk makes <Up> history again'] = function()
	history(':', { 'echo "one"' })
	child.type_keys(':', 'ec')
	cmd_items()
	eq(C.wait_menu(), true)
	walk('<M-j>')
	walk('<M-k>')
	-- the walk inserted an item; back to the prefix by typing, then history
	child.type_keys('<C-u>', 'ec')
	cmd_items()
	eq(after('<Up>'), 'echo "one"')
end

T['history: <C-p> / <C-n> walk it too'] = function()
	history(':', { 'let g:h1 = 1', 'let g:h2 = 2' })
	child.type_keys(':')
	eq(after('<C-p>'), 'let g:h2 = 2')
	eq(after('<C-p>'), 'let g:h1 = 1')
	eq(after('<C-n>'), 'let g:h2 = 2')
end

T['history: / search recalls earlier searches'] = function()
	history('/', { 'zebrafish', 'quokka' })
	C.scratch('conf', '', { 'zebrafish quokka', '' })
	C.esc()
	child.type_keys('/')
	eq(after('<Up>'), 'quokka')
	eq(after('<Up>'), 'zebrafish')
end
-- }}}

T['/ search: buffer words'] = function()
	C.scratch('conf', '', { 'zebrafish one', '' })
	C.esc()
	child.type_keys('/', 'zebr')
	check(Helpers.has(cmd_items(), 'buffer:zebrafish'))
end

-- shell names: shellcmd.lua keeps them in stdpath('state')/genja-completion011/shellcmd.txt

---The shell list file, in the child's state dir.
---@return string
local function shell_file()
	return child.lua_get([[vim.fs.joinpath(vim.fn.stdpath('state'), 'genja-completion011', 'shellcmd.txt')]])
end

T['shellcmd: PATH change rebuilds the disk list'] = function()
	local file = shell_file()
	-- a list made for another PATH, with a name that must go
	vim.fn.mkdir(vim.fs.dirname(file), 'p')
	vim.fn.writefile({ 'PATH=/elsewhere', 'zzstalecmd' }, file)
	child.lua([[vim.env.PATH = vim.env.PATH .. ';C:/zz_genja_probe']])
	local path = child.lua_get([[vim.env.PATH]])
	-- a one-char `!` opens no menu, so the first request comes with the second key
	child.type_keys(':', '!n')
	require('helpers.timing').wait(function()
		local lines = vim.fn.readfile(file)
		return lines[1] == 'PATH=' .. path and #lines > 1
	end, 8000)
	local lines = vim.fn.readfile(file)
	eq(lines[1], 'PATH=' .. path)
	check(not vim.tbl_contains(lines, 'zzstalecmd'), 'stale name still in the list')
end

T['shellcmd: :vert term lists shell names'] = function()
	-- the list written by the case above; wait for it so this case does not depend on a rebuild
	require('helpers.timing').wait(function()
		return vim.fn.filereadable(shell_file()) == 1
	end, 8000)
	-- the menu opens on a typed character, not on the space after `term`
	child.type_keys(':', 'vert term n')
	check(Helpers.has_match(cmd_items(), '^shellcmd:'))
end

return T
