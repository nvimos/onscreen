-- lua/genja/md-abbrev.lua and lua/genja/md-fix.lua. Fresh child nvim per case.

local child = MiniTest.new_child_neovim()
local eq = MiniTest.expect.equality

local T = MiniTest.new_set({
	hooks = {
		pre_case = function()
			child.restart({ '-u', 'tests/minimal_init.lua' })
			child.lua([[
				_G.A = require('genja.md-abbrev')
				_G.F = require('genja.md-fix')
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
