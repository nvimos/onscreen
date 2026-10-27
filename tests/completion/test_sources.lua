-- blink.cmp in the real config: which items each source gives, per filetype.
-- `make test D=completion` in tests/. LSP items: the `cmp` group of tests/comps011.
local Helpers = require('helpers.completion')
local child = MiniTest.new_child_neovim()
local C = Helpers.new(child)

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

-- {{{ built-in sources

T['path: file names after ./'] = function()
	C.scratch('conf', './ab')
	check(Helpers.has_match(C.labels('path'), '^path:abcdir'))
end

T['buffer: words when no language server has items'] = function()
	C.scratch('conf', 'zeb', { 'zebrafish one two', '' })
	check(Helpers.has(C.labels(), 'buffer:zebrafish'))
end

T['lazydev: module names in require()'] = function()
	if child.lua('return vim.fn.executable("lua-language-server")') == 0 then
		MiniTest.skip('lua-language-server not installed')
	end
	-- the Makefile turns lazydev off for lua_ls speed; this case needs it on
	child.lua('vim.env.GENJA_LUA_NO_LIB = nil')
	C.scratch('lua', "require('genja.comp")
	-- lazydev's source works only once lua_ls has attached the buffer
	local attached = require('helpers.timing').wait(function()
		return child.lua('return require("lazydev.buf").attached[vim.api.nvim_get_current_buf()] ~= nil')
	end, 15000)
	check(attached, 'lazydev never attached (lua_ls not started?)')
	check(Helpers.has_match(C.labels('lazydev'), '^lazydev:genja%.comps'))
end
-- }}}

-- {{{ dictionary

T['dictionary: words in markdown'] = function()
	C.scratch('markdown', 'the hou')
	check(Helpers.has(C.labels('dictionary'), 'dictionary:hour'))
end

T['dictionary: capitalised after a capital, at most 20'] = function()
	C.scratch('markdown', 'the Hou')
	local items = C.labels('dictionary')
	check(Helpers.has(items, 'dictionary:Hour'))
	check(#items <= 20, #items .. ' items')
	for _, item in ipairs(items) do
		check(item:match('^dictionary:%u') ~= nil, item)
	end
end

T['dictionary: not in other filetypes'] = function()
	C.scratch('conf', 'hou')
	local ok = Helpers.has_match(C.labels(), '^dictionary:')
	check(not ok, 'dictionary items in a conf buffer')
end
-- }}}

-- {{{ gitignore

T['gitignore: names in the folder'] = function()
	C.scratch('gitignore', 'ab')
	check(Helpers.has(C.labels('gitignore'), 'gitignore:abcdir/'))
end

T['gitignore: one level deeper after /'] = function()
	C.scratch('gitignore', 'abcdir/')
	check(Helpers.has(C.labels('gitignore'), 'gitignore:inner/'))
end
-- }}}

-- {{{ sshconfig

T['sshconfig: option names at line start'] = function()
	C.scratch('sshconfig', 'Strict')
	check(Helpers.has(C.labels('sshconfig'), 'sshconfig:StrictHostKeyChecking'))
end

T['sshconfig: values open by themselves after a space'] = function()
	C.scratch('sshconfig', 'StrictHostKeyChecking ')
	check(C.wait_menu(), 'no menu after the space')
	check(Helpers.has(C.items(), 'sshconfig:accept-new'))
end

T['sshconfig: accepting replaces the whole value'] = function()
	C.scratch('sshconfig', 'StrictHostKeyChecking acc')
	check(Helpers.has(C.labels('sshconfig'), 'sshconfig:accept-new'))
	child.type_keys('<CR>')
	MiniTest.expect.equality(C.line(), 'StrictHostKeyChecking accept-new')
end

T['sshconfig: ssh -Q values with @ are replaced whole'] = function()
	if child.lua('return vim.fn.executable("ssh")') == 0 then
		MiniTest.skip('no ssh on PATH')
	end
	C.scratch('sshconfig', 'MACs hmac-sha2-256@')
	check(Helpers.has_match(C.labels('sshconfig'), '^sshconfig:hmac%-sha2%-256'))
	local picked = child.lua('return require("blink.cmp").get_selected_item().label')
	child.type_keys('<CR>')
	-- the typed `hmac-sha2-256@` is gone, not left in front of the item
	MiniTest.expect.equality(C.line(), 'MACs ' .. picked)
end
-- }}}

-- {{{ gitcommit

---A repo whose log has `feat(core): ...`, for the scopes.
---@return string dir
local function repo_with_scope()
	local dir = vim.fs.normalize(vim.fn.tempname())
	vim.fn.mkdir(dir, 'p')
	local git = { 'git', '-c', 'user.name=t', '-c', 'user.email=t@t' }
	vim.system({ 'git', 'init', '-q', dir }):wait()
	vim.system(vim.list_extend(vim.deepcopy(git), { 'commit', '-q', '--allow-empty', '-m', 'feat(core): x' }), { cwd = dir }):wait()
	return dir
end

T['gitcommit: types with Conventional Commits on'] = function()
	C.scratch('gitcommit')
	child.lua('vim.b.genja_commit_conventional = true')
	child.type_keys('fe')
	check(Helpers.has(C.labels('gitcommit'), 'gitcommit:feat'))
end

T['gitcommit: scopes from git log'] = function()
	local dir = repo_with_scope()
	C.scratch('gitcommit')
	child.lua('vim.b.genja_commit_conventional = true; vim.b.genja_commit_dir = ...', { dir })
	child.type_keys('feat(')
	check(Helpers.has(C.labels('gitcommit'), 'gitcommit:core'))
end

T['gitcommit: footers in the body'] = function()
	C.scratch('gitcommit', '', { 'feat: x', '', '' })
	child.lua('vim.b.genja_commit_conventional = true')
	child.type_keys('BRE')
	check(Helpers.has(C.labels('gitcommit'), 'gitcommit:BREAKING CHANGE: '))
end

T['gitcommit: nothing with Conventional Commits off'] = function()
	C.scratch('gitcommit', 'fe')
	child.lua('vim.b.genja_commit_conventional = false')
	MiniTest.expect.equality(C.labels('gitcommit'), {})
end
-- }}}

return T
