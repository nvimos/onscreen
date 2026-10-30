-- lua/genja/ext/messages.lua (:Messages, F2 source) and lua/genja/ext/messages-capture.lua.
-- Errors are real: a Lua file in a temp dir raises one, so :messages holds a real traceback.

local child = MiniTest.new_child_neovim()
local eq = MiniTest.expect.equality

local T = MiniTest.new_set({
	hooks = {
		pre_case = function()
			child.restart({ '-u', 'tests/minimal_init.lua' })
			child.lua([[
				vim.cmd('runtime plugin/messages.lua')
				_G.M = require('genja.ext.messages')
				_G.tmp = vim.fs.normalize(vim.fn.tempname())
				vim.fn.mkdir(tmp, 'p')
				_G.bad = tmp .. '/bad.lua'
				vim.fn.writefile({ 'local x = 1', 'error("boom")' }, bad)
				-- an error in :messages, as a failing :luafile leaves it
				_G.fail = function()
					local ok, err = pcall(vim.cmd, 'luafile ' .. bad)
					vim.api.nvim_echo({ { tostring(err) } }, true, { err = true })
				end
			]])
		end,
		post_once = child.stop,
	},
})

T['locations: Lua path:line from a real error'] = function()
	child.lua([[fail()]])
	local locs = child.lua([[return M.locations(M.lines())]])
	eq(#locs >= 1, true)
	eq(locs[1].filename, child.lua([[return bad]]))
	eq(locs[1].lnum, 2)
end

T['locations: shortened traceback paths are found in the runtimepath'] = function()
	local file = child.lua([[return M.resolve('...ocal/nvim/lua/genja/ext/messages.lua')]])
	eq(vim.endswith(file, '/lua/genja/ext/messages.lua'), true)
	eq(child.lua([[return M.resolve('...nowhere/lua/genja/nope.lua')]]), vim.NIL)
end

T['locations: Vim script errors (processing <file>, line <n>)'] = function()
	local vim_file = child.lua([[
		local f = tmp .. '/bad.vim'
		vim.fn.writefile({ '" c', 'call NoSuchFunction()' }, f)
		return f
	]])
	local locs = child.lua('return M.locations(...)', { {
		'Error detected while processing ' .. vim_file .. ':',
		'line    2:',
		'E117: Unknown function: NoSuchFunction',
	} })
	eq(#locs, 1)
	eq({ locs[1].filename, locs[1].lnum }, { vim_file, 2 })
end

T['locations: each file:line once, missing files skipped'] = function()
	local locs = child.lua('return M.locations(...)', { {
		'E5108: ' .. child.lua([[return bad]]) .. ':2: boom',
		'  ' .. child.lua([[return bad]]) .. ':2: in main chunk',
		'C:/no/such/file.lua:9: gone',
	} })
	eq(#locs, 1)
end

T[':Messages -dump: one scratch buffer that does not block :q'] = function()
	child.lua([[fail()]])
	child.cmd('Messages -dump')
	eq(child.bo.buftype, 'nofile')
	eq(child.bo.bufhidden, 'wipe')
	eq(child.bo.modified, false)
	eq(child.bo.filetype, 'messages')
	-- only one new buffer, unlike the old :DumpMessages
	eq(#child.lua([[return vim.tbl_filter(function(b) return vim.bo[b].buflisted end, vim.api.nvim_list_bufs())]]), 1)
end

T[':Messages -dump: <CR> on an error line opens file:line'] = function()
	child.lua([[fail()]])
	child.cmd('Messages')
	child.lua([[
		for i, l in ipairs(vim.api.nvim_buf_get_lines(0, 0, -1, false)) do
			if l:find('bad.lua:2', 1, true) then vim.api.nvim_win_set_cursor(0, { i, 0 }) break end
		end
	]])
	child.type_keys('<CR>')
	eq(child.lua([[return vim.fs.normalize(vim.api.nvim_buf_get_name(0)) == bad]]), true)
	eq(child.lua([[return vim.api.nvim_win_get_cursor(0)[1] ]]), 2)
end

T[':Messages -quick appends to the quickfix list'] = function()
	child.lua([[
		vim.fn.setqflist({ { filename = bad, lnum = 1, text = 'earlier' } })
		fail()
	]])
	child.cmd('Messages -quick')
	local qf = child.lua([[return vim.tbl_map(function(i) return i.lnum end, vim.fn.getqflist())]])
	eq(qf[1], 1)
	eq(vim.tbl_contains(qf, 2), true)
	eq(child.lua([[return vim.fn.getqflist({ title = 1 }).title]]), ':Messages')
end

T[':Messages -loc fills the location list'] = function()
	child.lua([[fail()]])
	child.cmd('Messages -loc')
	child.cmd('wincmd p')
	eq(#child.lua([[return vim.fn.getloclist(0)]]) >= 1, true)
end

T['F2 source: newest first, relative labels'] = function()
	child.lua([[
		fail()
		_G.bad2 = tmp .. '/bad2.lua'
		vim.fn.writefile({ 'error("two")' }, bad2)
		local ok, err = pcall(vim.cmd, 'luafile ' .. bad2)
		vim.api.nvim_echo({ { tostring(err) } }, true, { err = true })
	]])
	local items = child.lua([[
		local out
		require('genja.f2.collect.messages').collect({}, function(t) out = t end)
		return vim.tbl_map(function(t) return t.label end, out)
	]])
	eq(vim.endswith(items[1], 'bad2.lua:1'), true)
	eq(vim.endswith(items[2], 'bad.lua:2'), true)
end

T['capture: off until enable(), records WARN with the call site'] = function()
	local got = child.lua([[
		local C = require('genja.ext.messages-capture')
		local f = tmp .. '/warn.lua'
		vim.fn.writefile({ 'vim.notify("careful", vim.log.levels.WARN)' }, f)
		vim.cmd('luafile ' .. f)
		local before = #C.entries()
		C.enable()
		vim.cmd('luafile ' .. f)
		vim.notify('just info')
		C.disable()
		local e = C.entries()[1]
		return { before, #C.entries(), e.msg, e.file == vim.fs.normalize(f), e.lnum }
	]])
	eq(got, { 0, 1, 'careful', true, 1 })
end

T[':Messages -yank puts all of :messages into the + register'] = function()
	local got = child.lua([[
		fail()
		vim.api.nvim_echo({ { 'second line' } }, true, {})
		local reg = {}
		vim.fn.setreg = function(name, text) reg[name] = text end
		local before = M.lines()
		vim.cmd('Messages -yank')
		return { reg['+'], before }
	]])
	eq(got[1], table.concat(got[2], '\n'))
	eq(vim.endswith(got[1], 'second line'), true)
end

return T
