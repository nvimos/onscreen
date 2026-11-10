-- lua/genja/ext/unsaved.lua (:Unsaved, the :qa/:q/:x abbreviations), driven by real keys.
-- The quit commands are recorded instead of run (vim.cmd wrapper), so the child stays up.
-- Needs telescope and plenary in lazy's data dir; cases skip without them. Fresh child per case.

local C = require('helpers.child')
local eq = MiniTest.expect.equality

local have_telescope = C.installed('telescope.nvim', 'plenary.nvim')

local child, T = C.fresh([[
	local lazy = vim.fn.stdpath('data') .. '/lazy/'
	local config = vim.fn.stdpath('config')
	vim.opt.rtp:prepend(lazy .. 'plenary.nvim')
	vim.opt.rtp:prepend(lazy .. 'telescope.nvim')
	require('telescope').setup({})
	vim.cmd('runtime plugin/unsaved.lua')
	vim.cmd('source ' .. config .. '/lua/genja/abbreviations.vim')
	_G.U = require('genja.ext.unsaved')

	-- record the quit commands instead of running them
	_G.ran = {}
	local QUITS = { q = true, ['q!'] = true, qa = true, ['qa!'] = true, x = true, ['x!'] = true }
	local orig = vim.cmd
	vim.cmd = setmetatable({}, {
		__call = function(_, c)
			if type(c) == 'string' and QUITS[c] then
				table.insert(ran, c)
				return
			end
			return orig(c)
		end,
		__index = function(_, k) return orig[k] end,
	})

	_G.tmp = vim.fs.normalize(vim.fn.tempname())
	vim.fn.mkdir(tmp, 'p')
	_G.file = tmp .. '/unsaved-file.txt'
	vim.fn.writefile({ 'disk' }, file)
	-- a modified file buffer, current
	_G.modify_file = function()
		vim.cmd.edit(file)
		vim.api.nvim_buf_set_lines(0, 0, -1, false, { 'changed' })
		return vim.api.nvim_get_current_buf()
	end
	-- a modified no-name buffer, current
	_G.modify_noname = function()
		vim.cmd.enew()
		vim.api.nvim_buf_set_lines(0, 0, -1, false, { 'hello there world' })
		return vim.api.nvim_get_current_buf()
	end
	_G.picker_open = function()
		return vim.bo[vim.api.nvim_get_current_buf()].filetype == 'TelescopePrompt'
	end
	-- buffer numbers listed in the open picker, sorted
	_G.listed = function()
		local p = require('telescope.actions.state').get_current_picker(vim.api.nvim_get_current_buf())
		local list = {}
		for entry in p.manager:iter() do
			table.insert(list, entry.value)
		end
		table.sort(list)
		return list
	end
]], nil, { only_if = have_telescope, lines = 40, columns = 160 })

-- telescope opens and closes on scheduled callbacks: each key gets 200 ms
local keys = C.typer(child, 200)

local function settle()
	vim.uv.sleep(200)
	child.lua([[vim.wait(50)]])
end

-- MiniTest.skip() only ends the function it is called in, so check per case
local function case(fn)
	return function()
		if not have_telescope then
			MiniTest.skip('telescope or plenary not installed (lazy data dir)')
		end
		fn()
	end
end

local function ran()
	return child.lua([[return ran]])
end

local function picker_open()
	return child.lua([[return picker_open()]])
end

T['first_words: three ASCII words, non-ASCII dropped'] = case(function()
	local words = child.lua([[
		local b = vim.api.nvim_create_buf(true, false)
		vim.api.nvim_buf_set_lines(b, 0, -1, false, { '  -- Hällo, wörld! foo_bar 42 more' })
		return U.first_words(b)
	]])
	eq(words, 'Hllo-wrld-foo_bar')
end)

T['first_words: no words gives "buffer"'] = case(function()
	eq(child.lua([[return U.first_words(vim.api.nvim_create_buf(true, false))]]), 'buffer')
end)

T['save_path: ~/tmp/bufw-<week>-<words>.txt'] = case(function()
	local path = child.lua([[modify_noname() return U.save_path(0)]])
	eq(path, '~/tmp/bufw-' .. os.date('%V') .. '-hello-there-world.txt')
end)

T['run: nothing modified runs the command at once'] = case(function()
	child.lua([[U.run('qa')]])
	settle()
	eq(picker_open(), false)
	eq(ran(), { 'qa' })
end)

T['run: modified buffers open the picker, the command waits'] = case(function()
	local bufs = child.lua([[return { modify_file(), modify_noname() }]])
	child.lua([[U.run('qa')]])
	settle()
	eq(picker_open(), true)
	table.sort(bufs)
	eq(child.lua([[return listed()]]), bufs)
	eq(ran(), {})
	eq(child.lua([[return vim.b.telescope_hint]]), '…')
end)

T['<M-w> on a file writes it, then the command runs'] = case(function()
	child.lua([[modify_file() U.run('qa')]])
	settle()
	keys('<M-w>')
	eq(child.lua([[return vim.fn.readfile(file)]]), { 'changed' })
	eq(ran(), { 'qa' })
end)

T['<M-w> on E13 asks; yes overwrites'] = case(function()
	child.lua([[
		vim.fn.delete(file)
		vim.cmd.edit(file)
		vim.api.nvim_buf_set_lines(0, 0, -1, false, { 'mine' })
		vim.fn.writefile({ 'theirs' }, file)
		vim.fn.confirm = function() _G.asked = true return 1 end
		U.run('qa')
	]])
	settle()
	keys('<M-w>')
	eq(child.lua([[return asked]]), true)
	eq(child.lua([[return vim.fn.readfile(file)]]), { 'mine' })
	eq(ran(), { 'qa' })
end)

T['<M-w> on E13 asks; no keeps it modified and in the list'] = case(function()
	child.lua([[
		vim.fn.delete(file)
		vim.cmd.edit(file)
		vim.api.nvim_buf_set_lines(0, 0, -1, false, { 'mine' })
		vim.fn.writefile({ 'theirs' }, file)
		vim.fn.confirm = function() return 2 end
		U.run('qa')
	]])
	settle()
	keys('<M-w>')
	eq(child.lua([[return vim.fn.readfile(file)]]), { 'theirs' })
	eq(picker_open(), true)
	eq(ran(), {})
end)

T['<M-x> on a file resets it to disk'] = case(function()
	local buf = child.lua([[return modify_file()]])
	child.lua([[U.run('qa')]])
	settle()
	keys('<M-x>')
	eq(child.lua('return vim.api.nvim_buf_get_lines(..., 0, -1, false)', { buf }), { 'disk' })
	eq(child.lua('return vim.bo[...].modified', { buf }), false)
	eq(ran(), { 'qa' })
end)

T['<M-x> on a no-name buffer wipes it'] = case(function()
	local buf = child.lua([[return modify_noname()]])
	child.lua([[U.run('qa')]])
	settle()
	keys('<M-x>')
	eq(child.lua('return vim.api.nvim_buf_is_valid(...)', { buf }), false)
	eq(ran(), { 'qa' })
end)

T['the picker reopens with what is left; the command runs after the last one'] = case(function()
	local file_buf = child.lua([[local f = modify_file() modify_noname() return f]])
	child.lua([[U.run('qa')]])
	settle()
	keys('hello', '<M-x>')
	eq(picker_open(), true)
	eq(child.lua([[return listed()]]), { file_buf })
	eq(ran(), {})
	keys('<M-x>')
	eq(ran(), { 'qa' })
end)

T['<M-w> on a no-name buffer puts :w <path> on the cmdline'] = case(function()
	child.lua([[modify_noname() U.run('qa')]])
	settle()
	keys('<M-w>')
	eq(child.fn.mode(), 'c')
	eq(child.fn.getcmdline(), 'w ~/tmp/bufw-' .. os.date('%V') .. '-hello-there-world.txt')
	keys('<Esc>')
	eq(ran(), {})
end)

T['<Esc> closes the picker; the command does not run'] = case(function()
	child.lua([[modify_file() U.run('qa')]])
	settle()
	keys('<Esc>', '<Esc>')
	eq(picker_open(), false)
	eq(ran(), {})
end)

T['<CR> goes to the buffer; the command does not run'] = case(function()
	local buf = child.lua([[local b = modify_file() vim.cmd.enew() return b]])
	child.lua([[U.run('qa')]])
	settle()
	keys('<CR>')
	eq(child.lua([[return vim.api.nvim_get_current_buf()]]), buf)
	eq(ran(), {})
end)

T['a command with ! runs at once'] = case(function()
	child.lua([[modify_file() U.run('qa!')]])
	settle()
	eq(picker_open(), false)
	eq(ran(), { 'qa!' })
end)

T[':q in a split closes the window, no picker'] = case(function()
	child.lua([[modify_file() vim.cmd.split() U.run('q')]])
	settle()
	eq(picker_open(), false)
	eq(ran(), { 'q' })
end)

T[':q in the last window opens the picker'] = case(function()
	child.lua([[modify_file() U.run('q')]])
	settle()
	eq(picker_open(), true)
	eq(ran(), {})
end)

T[':x leaves the current file out; it writes that one itself'] = case(function()
	child.lua([[modify_file() U.run('x')]])
	settle()
	eq(picker_open(), false)
	eq(ran(), { 'x' })
end)

T[':x still lists other modified buffers'] = case(function()
	local noname = child.lua([[local n = modify_noname() modify_file() return n]])
	child.lua([[U.run('x')]])
	settle()
	eq(picker_open(), true)
	eq(child.lua([[return listed()]]), { noname })
end)

T['abbreviations: typed :qa, :q, :x go through :Unsaved'] = case(function()
	keys(':qa<CR>', ':q<CR>', ':x<CR>')
	eq(ran(), { 'qa', 'q', 'x' })
	child.lua([[modify_file()]])
	keys(':q<CR>')
	eq(picker_open(), true)
end)

T['abbreviations: :q! and :qa! pass through'] = case(function()
	child.lua([[modify_file()]])
	keys(':q!<CR>', ':qa!<CR>')
	eq(picker_open(), false)
	eq(ran(), { 'q!', 'qa!' })
end)

T['abbreviations: q inside a longer command line stays q'] = case(function()
	-- b:, not g: : the config's `cnoreabbrev g q` turns g: into q:
	keys(':let b:t = "q"<CR>')
	eq(child.b.t, 'q')
end)

T['g alone quits like :q, through :Unsaved'] = case(function()
	keys(':g<CR>')
	eq(ran(), { 'q' })
	child.lua([[modify_file()]])
	keys(':g<CR>')
	eq(picker_open(), true)
end)

T['jj and s: still expand when <CR> runs them'] = case(function()
	keys(':jj<CR>')
	eq(ran(), { 'qa' })
	-- s: would save a session; check the expanded line only
	keys(':s:<C-]>')
	eq(vim.startswith(child.fn.getcmdline(), 'Unsaved call <SNR>'), true)
	keys('<Esc>')
end)

T[':g/pat/ and :g! stay :global'] = case(function()
	child.lua([[vim.api.nvim_buf_set_lines(0, 0, -1, false, { 'keep', 'drop', 'keep' })]])
	keys(':g/drop/d<CR>')
	eq(child.lua([[return vim.api.nvim_buf_get_lines(0, 0, -1, false)]]), { 'keep', 'keep' })
	keys(':g!/xyz/d<CR>')
	eq(child.lua([[return vim.api.nvim_buf_get_lines(0, 0, -1, false)]]), { '' })
	eq(ran(), {})
end)

return T
