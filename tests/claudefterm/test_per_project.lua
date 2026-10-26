-- genja-claudefterm: one claude floaterm per project (doc-wip/readme.2026-10-23.claude-per-project.md).
-- Real vim-floaterm; claude is tests/claudefterm/fake_claude.cmd / .sh, which logs its cwd and args
-- to $FAKE_LOG (headless nvim on Windows sends terminal output to the outer console, not the buffer).
-- Pastes are recorded by stubbing nvim_chan_send. Needs vim-floaterm (and telescope + plenary for
-- the picker cases) in lazy's data dir; cases skip without them. Fresh child nvim per case.

local child = MiniTest.new_child_neovim()
local eq = MiniTest.expect.equality

local lazy = vim.fn.stdpath('data') .. '/lazy/'
local function installed(name) return vim.uv.fs_stat(lazy .. name) ~= nil end
local have_floaterm = installed('vim-floaterm')
local have_telescope = installed('telescope.nvim') and installed('plenary.nvim')

---Poll `expr` (Lua, returns a value) in the child until truthy or `ms` pass.
---@param expr string
---@param ms? integer
---@return any last value
local function wait_for(expr, ms)
	local stop = vim.uv.hrtime() + (ms or 5000) * 1e6
	local got = nil
	while vim.uv.hrtime() < stop do
		got = child.lua('return ' .. expr)
		if got then
			return got
		end
		vim.uv.sleep(100)
	end
	return got
end

local function settle()
	vim.uv.sleep(200)
	child.lua([[vim.wait(50)]])
end

local T = MiniTest.new_set({
	hooks = {
		pre_case = function()
			if not have_floaterm then
				return
			end
			child.restart({ '-u', 'tests/minimal_init.lua' })
			child.o.lines = 50
			child.o.columns = 250
			child.lua([[
				local lazy = vim.fn.stdpath('data') .. '/lazy/'
				local config = vim.fn.stdpath('config')
				vim.opt.rtp:prepend(lazy .. 'vim-floaterm')
				vim.opt.rtp:prepend(lazy .. 'plenary.nvim')
				vim.opt.rtp:prepend(lazy .. 'telescope.nvim')
				vim.opt.rtp:prepend(config .. '/plug-wip/genja-claudefterm.nvim')
				vim.opt.rtp:prepend(config .. '/plug-wip/genja-util.nvim')
				-- rtp added after startup: plugin/ files are not sourced on their own
				vim.cmd('runtime plugin/floaterm.vim')
				vim.cmd('runtime plugin/genja-claudefterm.lua')

				_G.tmp = vim.fs.normalize(vim.fn.tempname())
				vim.fn.mkdir(tmp, 'p')
				vim.env.CLAUDE_CONFIG_DIR = tmp .. '/claude-config'
				_G.fake_log = tmp .. '/fake.log'

				local fake = config .. '/tests/claudefterm/fake_claude.sh'
				vim.env.FAKE_LOG = fake_log
				if vim.fn.has('win32') == 1 then
					fake = (config .. '/tests/claudefterm/fake_claude.cmd'):gsub('/', '\\')
					vim.env.FAKE_LOG = fake_log:gsub('/', '\\')
					-- nvim's Windows defaults; make under Git Bash passes SHELL=bash on
					vim.o.shell = 'cmd.exe'
					vim.o.shellcmdflag = '/s /c'
					vim.o.shellxquote = '"'
					vim.o.shellquote = ''
				end
				_G.CF = require('genja-claudefterm')
				CF.setup({ term = { cmd = fake } })

				-- a git repo with one file; returns its root and the file
				_G.repo = function(path)
					local root = tmp .. '/' .. path
					vim.fn.mkdir(root .. '/.git', 'p')
					vim.fn.mkdir(root .. '/src', 'p')
					local file = root .. '/src/main.lua'
					vim.fn.writefile({ 'local a = 1', 'local b = 2', 'return a + b' }, file)
					return root, file
				end

				-- an editor window to come back to
				_G.editor = vim.api.nvim_get_current_win()
				_G.edit = function(file)
					vim.cmd('stopinsert')
					vim.api.nvim_set_current_win(editor)
					vim.cmd('edit ' .. vim.fn.fnameescape(file))
				end

				_G.names = function()
					return vim.tbl_map(function(r) return r.name end, CF.running())
				end
				_G.bufnr_of = function(name) return vim.fn['floaterm#terminal#get_bufnr'](name) end
				_G.shown = function(name)
					return #vim.fn.win_findbuf(bufnr_of(name)) > 0
				end
				_G.label_of = function(name)
					return vim.fn.fnamemodify(vim.api.nvim_buf_get_name(bufnr_of(name)), ':t')
				end

				-- the fake's start of terminal `name`: { cwd, args }, found by its session id
				_G.launch_of = function(name)
					local bufnr = bufnr_of(name)
					if bufnr == -1 or vim.fn.filereadable(fake_log) == 0 then
						return nil
					end
					local id = vim.b[bufnr].claude_session_id
					for _, line in ipairs(vim.fn.readfile(fake_log)) do
						local cwd, args = line:gsub('\\', '/'):match('^start cwd=(.-) args=(.-)%s*$')
						if args and id and args:find(id, 1, true) then
							return { cwd = cwd:lower(), args = args }
						end
					end
					return nil
				end

				-- what paste() sends, by floaterm name
				_G.sent = {}
				vim.api.nvim_chan_send = function(chan, data)
					local name = '?'
					for _, r in ipairs(CF.running()) do
						if vim.bo[bufnr_of(r.name)].channel == chan then
							name = r.name
						end
					end
					table.insert(sent, { name = name, data = data })
				end
			]])
		end,
		post_case = function()
			if have_floaterm then
				-- stop the fake claude jobs before the child goes, one at a time:
				-- several FloatermKills in a row sometimes crash the headless child on Windows
				child.lua([[
					for _, r in ipairs(CF.running()) do
						vim.cmd('FloatermKill ' .. r.name)
						vim.wait(500)
					end
					CF.kill()
				]])
			end
		end,
		post_once = child.stop,
	},
})

---Skip when the plugins are missing (MiniTest.skip only ends the function it is called in).
---@param fn fun()
---@param telescope? boolean needs telescope too
local function case(fn, telescope)
	return function()
		if not have_floaterm then
			MiniTest.skip('vim-floaterm not in ' .. lazy)
		end
		if telescope and not have_telescope then
			MiniTest.skip('telescope or plenary not in ' .. lazy)
		end
		fn()
	end
end

---Start claude for `file` with :ClaudeFterm and wait until the fake has logged its start.
---@param file_expr string Lua expression for the file
---@param name string expected floaterm name
local function start(file_expr, name)
	child.lua('edit(' .. file_expr .. ')')
	child.cmd('ClaudeFterm')
	eq(wait_for(string.format([[launch_of(%q) ~= nil]], name)), true)
end

-- guide steps 1-2
T['two repos: two terminals, each started in its root'] = case(function()
	child.lua([[_G.a_root, _G.a_file = repo('alpha'); _G.b_root, _G.b_file = repo('beta')]])
	start('a_file', 'claude-alpha')
	start('b_file', 'claude-beta')
	eq(child.lua([[return names()]]), { 'claude-alpha', 'claude-beta' })
	eq(child.lua([[return CF.running()[1].root == a_root and CF.running()[2].root == b_root]]), true)
	eq(child.lua([[return launch_of('claude-alpha').cwd == a_root:lower()]]), true)
	eq(child.lua([[return launch_of('claude-beta').cwd == b_root:lower()]]), true)
	eq(child.lua([[return label_of('claude-alpha')]]), 'claude-ft «alpha»')
end)

T['same basename in two places: the second name gets a hash'] = case(function()
	child.lua([[_G.a_root, _G.a_file = repo('one/proj'); _G.b_root, _G.b_file = repo('two/proj')]])
	start('a_file', 'claude-proj')
	local second = child.lua([[return 'claude-proj-' .. vim.fn.sha256(b_root:lower()):sub(1, 6)]])
	start('b_file', second)
	eq(child.lua([[return names()]]), { 'claude-proj', second })
end)

-- the temp dir may sit below a repo (e.g. a dotfiles repo in ~), then that repo is the root
T['a file without a repo of its own: the git root above, else :pwd'] = case(function()
	child.lua([[
		_G.plain = tmp .. '/plain'
		vim.fn.mkdir(plain, 'p')
		vim.fn.writefile({ 'x' }, plain .. '/notes.lua')
		vim.cmd.cd(plain)
		_G.want = vim.fs.root(plain, '.git')
		if not want then
			want = vim.fn.getcwd()
		end
		want = vim.fs.normalize(want)
	]])
	local name = child.lua([[return 'claude-' .. vim.fs.basename(want)]])
	start([[plain .. '/notes.lua']], name)
	eq(child.lua([[return CF.running()[1].root == want]]), true)
end)

T[':ClaudeFterm again hides it, a third time shows the same one'] = case(function()
	child.lua([[_G.a_root, _G.a_file = repo('alpha')]])
	start('a_file', 'claude-alpha')
	local job = child.lua([[return vim.bo[bufnr_of('claude-alpha')].channel]])
	child.lua([[edit(a_file)]])
	child.cmd('ClaudeFterm')
	settle()
	eq(child.lua([[return shown('claude-alpha')]]), false)
	eq(child.lua([[return names()]]), { 'claude-alpha' })
	child.cmd('ClaudeFterm')
	settle()
	eq(child.lua([[return shown('claude-alpha')]]), true)
	eq(child.lua([[return vim.bo[bufnr_of('claude-alpha')].channel]]), job)
end)

T[':ClaudeFterm inside the claude terminal hides that terminal'] = case(function()
	child.lua([[_G.a_root, _G.a_file = repo('alpha'); _G.b_root, _G.b_file = repo('beta')]])
	start('a_file', 'claude-alpha')
	start('b_file', 'claude-beta')
	-- focus is in beta's terminal now
	eq(child.lua([[return vim.b.claude_term]]), 'claude-beta')
	child.cmd('ClaudeFterm')
	settle()
	eq(child.lua([[return shown('claude-beta')]]), false)
	eq(child.lua([[return names()]]), { 'claude-alpha', 'claude-beta' })
end)

T['show(name) shows a hidden terminal and jumps in'] = case(function()
	child.lua([[_G.a_root, _G.a_file = repo('alpha')]])
	start('a_file', 'claude-alpha')
	child.lua([[edit(a_file)]])
	child.cmd('ClaudeFterm')
	settle()
	child.lua([[CF.show('claude-alpha')]])
	settle()
	eq(child.lua([[return shown('claude-alpha')]]), true)
	eq(child.lua([[return vim.b.claude_term]]), 'claude-alpha')
end)

-- guide step 5
T['paste in repo A while B is shown goes to A'] = case(function()
	child.lua([[_G.a_root, _G.a_file = repo('alpha'); _G.b_root, _G.b_file = repo('beta')]])
	start('a_file', 'claude-alpha')
	start('b_file', 'claude-beta')
	child.lua([[edit(a_file); CF.paste_context()]])
	settle()
	eq(child.lua([[return sent]]), { { name = 'claude-alpha', data = '\27[200~@src/main.lua \27[201~' } })
	-- jumps into A's terminal to type the question
	eq(child.lua([[return vim.b.claude_term]]), 'claude-alpha')
end)

T['visual paste: path:lines relative to the root, fenced code, not submitted'] = case(function()
	child.lua([[
		_G.a_root, _G.a_file = repo('alpha')
		vim.keymap.set('x', '<F9>', function() CF.paste_context() end)
	]])
	start('a_file', 'claude-alpha')
	child.lua([[edit(a_file); vim.api.nvim_win_set_cursor(0, { 2, 0 })]])
	child.type_keys('V', 'j', '<F9>')
	settle()
	eq(child.lua([[return sent]]), {
		{ name = 'claude-alpha', data = '\27[200~src/main.lua:2-3\n```lua\nlocal b = 2\nreturn a + b\n```\n\n\27[201~' },
	})
end)

-- the paste waits for claude's first output on screen
T['paste with no claude running starts it in the root, pastes once it is up'] = case(function()
	local reaches = child.lua([[
		vim.cmd('new')
		vim.fn.jobstart({ vim.o.shell, vim.o.shellcmdflag, 'echo probe' }, { term = true })
		vim.wait(1500, function() return vim.trim(table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false))) ~= '' end)
		local text = vim.trim(table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false)))
		vim.cmd('bwipeout!')
		return text ~= ''
	]])
	if not reaches then
		MiniTest.skip('terminal output does not reach the buffer here (headless nvim on Windows)')
	end
	child.lua([[_G.a_root, _G.a_file = repo('alpha'); edit(a_file); CF.paste_context()]])
	eq(wait_for([[#sent > 0]], 8000), true)
	eq(child.lua([[return sent]]), { { name = 'claude-alpha', data = '\27[200~@src/main.lua \27[201~' } })
	eq(child.lua([[return launch_of('claude-alpha').cwd == a_root:lower()]]), true)
end)

T['send() to a running claude: paste, then Enter; the cursor stays in the editor'] = case(function()
	child.lua([[_G.a_root, _G.a_file = repo('alpha')]])
	start('a_file', 'claude-alpha')
	child.lua([[edit(a_file); CF.send('say hi')]])
	eq(wait_for([[#sent == 2]]), true)
	eq(child.lua([[return sent]]), {
		{ name = 'claude-alpha', data = '\27[200~say hi\27[201~' },
		{ name = 'claude-alpha', data = '\r' },
	})
	eq(child.lua([[return vim.api.nvim_get_current_win() == editor]]), true)
end)

-- guide steps 3-4
T['picker: <CR> shows the picked terminal'] = case(function()
	child.lua([[_G.a_root, _G.a_file = repo('alpha')]])
	start('a_file', 'claude-alpha')
	child.lua([[edit(a_file)]])
	child.cmd('ClaudeFterm')
	settle()
	child.cmd('ClaudeFterm!')
	settle()
	eq(child.bo.filetype, 'TelescopePrompt')
	child.type_keys('<CR>')
	settle()
	eq(child.lua([[return shown('claude-alpha')]]), true)
	eq(child.lua([[return vim.b.claude_term]]), 'claude-alpha')
end, true)

T['picker: <M-d> kills one, the list reopens with the rest'] = case(function()
	child.lua([[_G.a_root, _G.a_file = repo('alpha'); _G.b_root, _G.b_file = repo('beta')]])
	start('a_file', 'claude-alpha')
	start('b_file', 'claude-beta')
	child.lua([[edit(a_file)]])
	child.cmd('ClaudeFterm!')
	settle()
	child.type_keys('<M-d>')
	settle()
	eq(#child.lua([[return names()]]), 1)
	eq(child.bo.filetype, 'TelescopePrompt')
	child.type_keys('<C-c>')
end, true)

-- guide step 7
T['kill() stops every terminal'] = case(function()
	child.lua([[_G.a_root, _G.a_file = repo('alpha'); _G.b_root, _G.b_file = repo('beta')]])
	start('a_file', 'claude-alpha')
	start('b_file', 'claude-beta')
	child.lua([[CF.kill()]])
	eq(wait_for([[#names() == 0]]), true)
end)

-- guide step 6: session markers
local function transcript(id, lines)
	child.lua(string.format([[
		local dir = vim.env.CLAUDE_CONFIG_DIR .. '/projects/some-project'
		vim.fn.mkdir(dir, 'p')
		vim.fn.writefile(%s, dir .. '/' .. %q .. '.jsonl', 'a')
	]], vim.inspect(lines), id))
end

T['marker in a file: resumes that session in its cwd, named after its title'] = case(function()
	local id = '11111111-2222-4333-8444-555555555555'
	child.lua([[_G.a_root, _G.a_file = repo('alpha'); _G.b_root, _G.b_file = repo('beta')]])
	local b_root = child.lua([[return b_root]])
	transcript(id, {
		vim.json.encode({ type = 'user', cwd = b_root }),
		'{"type":"custom-title","customTitle":"fix the tabline"}',
	})
	-- the marker is in a file of repo A, the session ran in repo B
	child.lua(string.format([[vim.fn.writefile({ '-- claude-session: %s fix the tabline', 'local x = 1' }, a_file)]], id))
	start('a_file', 'claude-beta')
	eq(child.lua([[return CF.running()[1].root == b_root]]), true)
	local launch = child.lua([[return launch_of('claude-beta')]])
	eq(launch.cwd, b_root:lower())
	eq(launch.args:find('--resume ' .. id, 1, true) ~= nil, true)
	eq(child.lua([[return label_of('claude-beta')]]), 'claude-ft «fix the tabline»')
end)

T['/rename in claude writes the marker into the origin file (not saved)'] = case(function()
	child.lua([[_G.a_root, _G.a_file = repo('alpha')]])
	start('a_file', 'claude-alpha')
	local id = child.lua([[return vim.b[bufnr_of('claude-alpha')].claude_session_id]])
	eq(child.lua([[return launch_of('claude-alpha').args]]):find('--session-id ' .. id, 1, true) ~= nil, true)
	-- what claude appends on /rename
	transcript(id, { '{"type":"custom-title","customTitle":"my session"}' })
	local marker = '-- claude-session: ' .. id .. ' my session'
	eq(wait_for(string.format([[vim.tbl_contains(vim.api.nvim_buf_get_lines(vim.fn.bufnr(a_file), 0, -1, false), %q)]], marker), 8000), true)
	eq(child.lua([[return vim.bo[vim.fn.bufnr(a_file)].modified]]), true)
	eq(child.lua([[return label_of('claude-alpha')]]), 'claude-ft «my session»')
end)

return T
