-- lua/genja/ext/md-abbrev.lua and lua/genja/ext/md-fix.lua. Fresh child nvim per case.

local child = MiniTest.new_child_neovim()
local eq = MiniTest.expect.equality

local T = MiniTest.new_set({
	hooks = {
		pre_case = function()
			child.restart({ '-u', 'tests/minimal_init.lua' })
			child.lua([[
				_G.A = require('genja.ext.md-abbrev')
				_G.F = require('genja.ext.md-fix')
				_G.tmp = vim.fs.normalize(vim.fn.tempname())
				vim.fn.mkdir(tmp, 'p')
			]])
		end,
		post_once = child.stop,
	},
})

T['abbrev: parse skips comments and blanks, right side may have spaces'] = function()
	eq(child.lua([[return A.parse({ '# c', '', 'teh the', '  adn   and ', 'ty thank you', 'single' })]]),
		{ { 'teh', 'the' }, { 'adn', 'and' }, { 'ty', 'thank you' } })
end

T['abbrev: the shipped list parses'] = function()
	eq(child.lua([[return #A.parse(vim.fn.readfile(A.FILE)) > 5]]), true)
end

T['abbrev: apply sets buffer-local insert abbreviations'] = function()
	child.lua([[
		vim.fn.writefile({ 'teh the' }, tmp .. '/ab.txt')
		A.apply(0, tmp .. '/ab.txt')
	]])
	eq(child.lua([[return vim.fn.maparg('teh', 'i', true)]]), 'the')
	child.type_keys('i', 'teh ', '<Esc>')
	eq(child.lua([[return vim.api.nvim_get_current_line()]]), 'the ')
end

T['fix: commands, shared markdownlint config without a project one'] = function()
	local got = child.lua([[
		vim.fn.executable = function() return 1 end
		return F.commands(tmp .. '/a.md')
	]])
	eq(got[1][1], 'typos')
	eq(got[2][1], 'markdownlint-cli2')
	eq(got[2][3], '--config')
end

T['fix: a project config wins over the shared one'] = function()
	local got = child.lua([[
		vim.fn.executable = function() return 1 end
		vim.fn.writefile({ '{}' }, tmp .. '/.markdownlint.jsonc')
		return F.commands(tmp .. '/a.md')
	]])
	eq(got[2], { 'markdownlint-cli2', '--fix', child.lua([[return tmp .. '/a.md']]) })
end

T['fix: missing tools are left out'] = function()
	eq(child.lua([[
		vim.fn.executable = function() return 0 end
		return F.commands(tmp .. '/a.md')
	]]), {})
end

T['keys: key notation gets backticks, adjacent keys share one span'] = function()
	local got = child.lua([[return {
		F.escape_keys_line('<M-v> toggles; <Esc> cancels'),
		F.escape_keys_line('also in the <leader>pC / <M-?> popup'),
		F.escape_keys_line('complete with <C-x><C-o>, <F5>, <2-LeftMouse>'),
	}]])
	eq(got, {
		'`<M-v>` toggles; `<Esc>` cancels',
		'also in the `<leader>pC` / `<M-?>` popup',
		'complete with `<C-x><C-o>`, `<F5>`, `<2-LeftMouse>`',
	})
end

T['keys: code spans, html and links are left alone'] = function()
	local got = child.lua([[return {
		F.escape_keys_line('`:map <C-x> foo` and <br> and <https://x.org> and <mic>'),
		F.escape_keys_line('`<C-x>` already done'),
	}]])
	eq(got, {
		'`:map <C-x> foo` and <br> and <https://x.org> and <mic>',
		'`<C-x>` already done',
	})
end

T['keys: file pass skips fenced and indented code blocks, not nested list items'] = function()
	local got = child.lua([[
		local f = tmp .. '/k.md'
		vim.fn.writefile({
			'Title',
			'',
			'    <C-w>T  code block',
			'',
			'```',
			'<C-x> in a fence',
			'```',
			'- item <Esc>',
			'    - nested <M-v>',
		}, f)
		F.escape_keys(f)
		return vim.fn.readfile(f)
	]])
	eq(got[3], '    <C-w>T  code block')
	eq(got[6], '<C-x> in a fence')
	eq(got[8], '- item `<Esc>`')
	eq(got[9], '    - nested `<M-v>`')
end

-- expand_tabs: leading tabs to spaces at CommonMark tab stops (4); one aspect per case
---Run F.expand_tabs on a file holding `lines`; returns the file's lines.
---@param lines string[]
---@return string[]
local function expand(lines)
	return child.lua([[
		local f = tmp .. '/t.md'
		vim.fn.writefile(..., f)
		F.expand_tabs(f)
		return vim.fn.readfile(f)
	]], { lines })
end

T['tabs: a leading tab becomes 4 spaces'] = function()
	eq(expand({ '\t- item' }), { '    - item' })
end

T['tabs: two leading tabs become 8 spaces'] = function()
	eq(expand({ '\t\t- item' }), { '        - item' })
end

T['tabs: spaces before a tab fill up to the next tab stop'] = function()
	eq(expand({ '  \t- item' }), { '    - item' })
end

T['tabs: a tab after the text is kept'] = function()
	eq(expand({ '- a\tb' }), { '- a\tb' })
end

T['tabs: fenced code keeps its tabs'] = function()
	eq(expand({ '```', '\tcode', '```' }), { '```', '\tcode', '```' })
end

T['tabs: lines without tabs are unchanged'] = function()
	eq(expand({ '  - item', '- [ ] task' }), { '  - item', '- [ ] task' })
end

T['tabs: tab stop 2 when editorconfig says so'] = function()
	eq(child.lua([[
		local f = tmp .. '/t.md'
		vim.fn.writefile({ '\t- item' }, f)
		F.expand_tabs(f, 2)
		return vim.fn.readfile(f)
	]]), { '  - item' })
end

-- editorconfig: only sections written for markdown count; one aspect per case
---F.editorconfig_indent for tmp/sub/a.md, with `top` in tmp/.editorconfig (root) and `sub` in
---tmp/sub/.editorconfig (nil: no file).
---@param top string[]
---@param sub? string[]
local function ec(top, sub)
	return child.lua([[
		local top, sub = ...
		vim.fn.mkdir(tmp .. '/sub', 'p')
		vim.fn.writefile(vim.list_extend({ 'root = true' }, top), tmp .. '/.editorconfig')
		if sub ~= vim.NIL then
			vim.fn.writefile(sub, tmp .. '/sub/.editorconfig')
		end
		return F.editorconfig_indent(tmp .. '/sub/a.md') or false
	]], { top, sub or vim.NIL })
end

T['editorconfig: a [*] section does not count, markdown stays spaces'] = function()
	eq(ec({ '[*]', 'indent_style = tab' }), false)
end

T['editorconfig: [*.md] indent_style = tab with its size'] = function()
	eq(ec({ '[*.md]', 'indent_style = tab', 'indent_size = 2' }), { style = 'tab', size = 2 })
end

T['editorconfig: [*.{md,txt}] counts'] = function()
	eq(ec({ '[*.{md,txt}]', 'indent_style = space', 'indent_size = 2' }), { style = 'space', size = 2 })
end

T['editorconfig: a section for other files does not count'] = function()
	eq(ec({ '[*.lua]', 'indent_style = tab' }), false)
end

T['editorconfig: no size given means 4'] = function()
	eq(ec({ '[*.md]', 'indent_style = tab' }), { style = 'tab', size = 4 })
end

T['editorconfig: the nearer file wins'] = function()
	eq(ec({ '[*.md]', 'indent_style = space' }, { '[*.md]', 'indent_style = tab' }), { style = 'tab', size = 4 })
end

T['editorconfig: root = true stops the search'] = function()
	eq(ec({ '[*.md]', 'indent_style = tab' }, { 'root = true', '[*.lua]', 'indent_style = tab' }), false)
end

-- indent_to_tabs: leading spaces to tabs (editorconfig indent_style = tab); one aspect per case
---@param lines string[]
---@param size integer
---@return string[]
local function to_tabs(lines, size)
	return child.lua([[
		local lines, size = ...
		local f = tmp .. '/t.md'
		vim.fn.writefile(lines, f)
		F.indent_to_tabs(f, size)
		return vim.fn.readfile(f)
	]], { lines, size })
end

T['to tabs: each full tab stop of spaces becomes a tab'] = function()
	eq(to_tabs({ '    - item', '        - nested' }, 4), { '\t- item', '\t\t- nested' })
end

T['to tabs: spaces short of a tab stop stay'] = function()
	eq(to_tabs({ '      - item', '  - two' }, 4), { '\t  - item', '  - two' })
end

T['to tabs: size 2'] = function()
	eq(to_tabs({ '  - item', '    - nested' }, 2), { '\t- item', '\t\t- nested' })
end

T['to tabs: fenced code keeps its spaces'] = function()
	eq(to_tabs({ '```', '    code', '```' }, 4), { '```', '    code', '```' })
end

-- fix(): the whole run with a stand-in fixer (nvim exiting at once), so no tools are needed
---Run F.fix on tmp/f.md holding `lines`, with `ec_lines` as tmp/.editorconfig; returns the file.
---@param lines string[]
---@param ec_lines string[]
---@return string[]
local function fix_file(lines, ec_lines)
	child.lua([[
		local lines, ec_lines = ...
		vim.fn.writefile(vim.list_extend({ 'root = true' }, ec_lines), tmp .. '/.editorconfig')
		vim.fn.writefile(lines, tmp .. '/f.md')
		F.commands = function() return { { vim.v.progpath, '--clean', '--headless', '+qa!' } } end
		vim.cmd('edit ' .. tmp .. '/f.md')
		F.fix(0, false)
	]], { lines, ec_lines })
	-- the stand-in fixer is async; the file is final once it changed or 5 s passed
	local before = table.concat(lines, '\n')
	local got = lines
	local stop = vim.uv.hrtime() + 5e9
	while vim.uv.hrtime() < stop do
		got = child.lua([[return vim.fn.readfile(tmp .. '/f.md')]])
		if table.concat(got, '\n') ~= before then
			break
		end
		vim.uv.sleep(100)
	end
	return got
end

T['fix: without markdown editorconfig, tabs become spaces'] = function()
	eq(fix_file({ '- a', '\t- b' }, { '[*]', 'indent_style = tab' }), { '- a', '    - b' })
end

T['fix: [*.md] indent_style = tab, spaces become tabs after the fixers'] = function()
	eq(fix_file({ '- a', '    - b' }, { '[*.md]', 'indent_style = tab', 'indent_size = 4' }), { '- a', '\t- b' })
end

T['fix: [*.md] indent_style = space with size 2, a tab becomes 2 spaces'] = function()
	eq(fix_file({ '- a', '\t- b' }, { '[*.md]', 'indent_style = space', 'indent_size = 2' }), { '- a', '  - b' })
end

T['save: :w with [*.md] indent_style = tab turns space indents into tabs, the buffer reloads'] = function()
	child.lua([[
		vim.fn.writefile({ 'root = true', '[*.md]', 'indent_style = tab', 'indent_size = 4' }, tmp .. '/.editorconfig')
		F.commands = function() return { { vim.v.progpath, '--clean', '--headless', '+qa!' } } end
		vim.cmd('edit ' .. tmp .. '/s.md')
		F.register(0)
		vim.api.nvim_buf_set_lines(0, 0, -1, false, { '- a', '    - b', '        - c' })
		vim.cmd('write')
	]])
	local want = { '- a', '\t- b', '\t\t- c' }
	local got = nil
	local stop = vim.uv.hrtime() + 5e9
	while vim.uv.hrtime() < stop do
		got = child.lua([[return vim.api.nvim_buf_get_lines(0, 0, -1, false)]])
		if vim.deep_equal(got, want) then
			break
		end
		vim.uv.sleep(100)
	end
	eq(got, want)
	eq(child.lua([[return vim.fn.readfile(tmp .. '/s.md')]]), want)
end

T['fix: typos rewrites the file, the buffer reloads'] = function()
	-- mason's bin is not on PATH in the bare child
	local bin = vim.fn.stdpath('data') .. '/mason/bin'
	child.lua('vim.env.PATH = ... .. (vim.fn.has("win32") == 1 and ";" or ":") .. vim.env.PATH', { bin })
	if child.lua([[return vim.fn.executable('typos')]]) == 0 then
		MiniTest.skip('typos not installed')
	end
	child.lua([[
		vim.fn.writefile({ '# Title', '', 'This is teh text.' }, tmp .. '/a.md')
		vim.cmd('edit ' .. tmp .. '/a.md')
		F.fix(0, true)
	]])
	local stop = vim.uv.hrtime() + 8e9
	local line = ''
	while vim.uv.hrtime() < stop do
		line = child.lua([[return vim.api.nvim_buf_get_lines(0, 2, 3, false)[1] ]])
		if line == 'This is the text.' then
			break
		end
		vim.uv.sleep(100)
	end
	eq(line, 'This is the text.')
end

return T
