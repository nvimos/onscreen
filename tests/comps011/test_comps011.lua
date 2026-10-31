-- Integration tests for genja-completion011 and lua/genja/ext/lint.lua: a child nvim boots the real
-- config (init.vim), opens a sample from tests/comps011/samples/ (copied to a temp dir) and waits
-- for a server to attach and report, for cmp to offer server items, for a linter to report.
--   make test D=comps011 G=<group> in tests/   groups: mason warmup lsp ready cmp lint fast slow gather,
--   or a case name (lua_ls, typos ...); `make list` shows them all
-- Timeouts, slow cutoffs and timings: tests/helpers/timing.lua. A server or linter that isn't
-- enabled or installed skips its case; `mason: servers installed` fails for a server an enabled
-- language wants but can't start. mason installs nothing here (g:genja_lsp_no_install).

local H = require('helpers.timing')
local S = H.suite('comps011')

local child = MiniTest.new_child_neovim()
local eq = MiniTest.expect.equality

local config = vim.fn.stdpath('config')
local samples = config .. '/tests/comps011/samples/'

---Boot the real config in the child (tests/helpers/real-config.lua).
local function boot()
	dofile(config .. '/tests/helpers/real-config.lua').boot_child(child)
end

---Copy samples/<name>/ into a fresh temp dir; returns that dir.
---@param name string
---@return string
local function copy_sample(name)
	local dest = vim.fs.normalize(vim.fn.tempname()) .. '/' .. name
	local src = samples .. name
	for path, kind in vim.fs.dir(src, { depth = 5 }) do
		if kind == 'directory' then
			vim.fn.mkdir(dest .. '/' .. path, 'p')
		else
			vim.fn.mkdir(vim.fs.dirname(dest .. '/' .. path), 'p')
			vim.fn.writefile(vim.fn.readfile(src .. '/' .. path, 'b'), dest .. '/' .. path, 'b')
		end
	end
	return dest
end

---Open `file` in the child and wait for `check` (Lua returning a value) up to the case's timeout.
---@param file string
---@param check string
---@param timeout integer
---@return any
local function open_and_wait(file, check, timeout)
	child.cmd('edit ' .. vim.fn.fnameescape(file))
	return H.wait(function() return child.lua('return ' .. check) end, timeout)
end

local T = MiniTest.new_set({
	hooks = {
		post_case = function()
			-- servers are child processes of the child: stop them before it goes
			pcall(child.lua, [[for _, c in ipairs(vim.lsp.get_clients()) do c:stop(true) end]])
		end,
		post_once = function()
			child.stop()
			H.save()
		end,
	},
})

-- {{{ mason: Python venvs still find the Python they were built from

-- A moved or uninstalled Python breaks every mason Python tool at once (autotools_ls exits 103).
-- Same check as :checkhealth genja.lsp; runs here, no child needed.
T['mason: python-venv'] = S:case({ name = 'mason python-venv', groups = { 'mason', 'python-venv' } }, function()
	local venv = dofile(config .. '/plug-wip/genja-completion011.nvim/lua/genja/lsp/venv.lua')
	local broken = {}
	for _, v in ipairs(venv.list()) do
		if not v.ok then
			table.insert(broken, ('%s: no %s, fix: %s'):format(v.name, v.python or ('home in ' .. v.cfg), venv.fix(v)))
		end
	end
	if #broken > 0 then
		error('mason venvs whose Python is gone:\n  ' .. table.concat(broken, '\n  '))
	end
end)

-- A launcher in mason/bin whose package files are gone still counts as executable.
T['mason: shims'] = S:case({ name = 'mason shims', groups = { 'mason', 'shims' } }, function()
	local shim = dofile(config .. '/plug-wip/genja-completion011.nvim/lua/genja/lsp/shim.lua')
	local broken = {}
	for _, s in ipairs(shim.list()) do
		if not s.ok then
			table.insert(broken, ('%s: no %s, fix: %s'):format(s.name, s.target or 'target found in it', shim.fix(s)))
		elseif s.absolute then
			-- works today; only a moved mason folder breaks it
			MiniTest.add_note(('%s: full path from an older mason, fix: %s'):format(s.name, shim.fix(s)))
		end
	end
	if #broken > 0 then
		error('mason launchers whose target is gone:\n  ' .. table.concat(broken, '\n  '))
	end
end)

-- mason-lspconfig enables a server only once it is installed: a missing one would only show up
-- as `lsp: <server>` skipping with "not enabled". Needs the child: the list comes from the config.
T['mason: servers installed'] = S:case({ name = 'mason servers installed', groups = { 'mason', 'servers' } }, function()
	boot()
	-- nvim-lspconfig's lsp/<server>.lua (the cmds) is on the rtp only once lazy has loaded it
	local list = child.lua([[
		pcall(require, 'lspconfig')
		return require('genja.lsp.installed').list()
	]])
	local fix = child.lua([[return require('genja.lsp.installed').fix({ server = '<server>' })]])
	local missing = {}
	for _, item in ipairs(list) do
		if not item.ok then
			table.insert(missing, ('%s: %s'):format(item.server, item.note or (item.cmd .. ' is not executable')))
		end
	end
	if #missing > 0 then
		error('servers of enabled languages that cannot start:\n  ' .. table.concat(missing, '\n  ')
			.. '\nfix: ' .. fix)
	end
end)
-- }}}

-- {{{ warmup: tools whose first run is slow, timed apart from the cases that use them

-- gopls sends no diagnostic before `go list` has loaded the module; the first `go list` in a
-- new folder took 3-24 s here (cold build cache), a repeat 0.5 s. Runs before `lsp: gopls`.
T['warmup: go-list'] = S:case({ name = 'warmup go-list', groups = { 'warmup', 'go-list' }, requires = { cmd = 'go' }, timeout = 30000, slow = 12000 }, function(ctx)
	if vim.fn.executable('go') == 0 then
		MiniTest.skip('go not installed')
	end
	local dir = copy_sample('lsp-go')
	local r = vim.system({ 'go', 'list', './...' }, { cwd = dir, text = true }):wait(ctx.timeout)
	if r.code ~= 0 then
		error(('go list in %s: exit %s: %s'):format(dir, tostring(r.code), vim.trim(r.stderr or '')))
	end
	eq(vim.trim(r.stdout), 'sample')
end)
-- }}}

-- {{{ LSP: attaches and reports a diagnostic

---@class genja.tests.LspCase
---@field name string
---@field server string lspconfig name
---@field sample string samples/<dir>
---@field file string file in it to open
---@field cmd string executable the server needs
---@field attach_only? boolean the sample can't make it report; attaching is enough
---@field timeout? integer
---@field slow? integer

---@type genja.tests.LspCase[]
local LSP = {
	{ name = 'bashls', server = 'bashls', sample = 'lsp-bash', file = 'bad.sh', cmd = 'bash-language-server' },
	-- on_attach hides lua_ls diagnostics until its workspace is loaded (or 10 s)
	{ name = 'lua_ls', server = 'lua_ls', sample = 'lsp-lua', file = 'bad.lua', cmd = 'lua-language-server', timeout = 20000, slow = 10000 },
	-- npm-based: slow to start
	{ name = 'jsonls', server = 'jsonls', sample = 'lsp-json', file = 'bad.json', cmd = 'vscode-json-language-server', slow = 8000 },
	{ name = 'vimls', server = 'vimls', sample = 'lsp-vim', file = 'bad.vim', cmd = 'vim-language-server', slow = 6000 },
	{ name = 'gopls', server = 'gopls', sample = 'lsp-go', file = 'main.go', cmd = 'gopls', timeout = 30000, slow = 12000 },
	-- phpactor runs inside WSL
	-- phpactor reports no syntax errors (its diagnostics come from phpstan/php-cs-fixer, see lang/php.lua)
	{ name = 'phpactor', server = 'phpactor', sample = 'lsp-php', file = 'bad.php', cmd = 'wsl.exe', attach_only = true, timeout = 30000, slow = 15000 },
	{ name = 'autotools_ls', server = 'autotools_ls', sample = 'lsp-make', file = 'Makefile', cmd = 'autotools-language-server', attach_only = true },
	{ name = 'pyrefly', server = 'pyrefly', sample = 'lsp-python', file = 'bad.py', cmd = 'pyrefly' },
	{ name = 'clangd', server = 'clangd', sample = 'lsp-c', file = 'bad.c', cmd = 'clangd', slow = 5000 },
	{ name = 'tsc', server = 'tsc', sample = 'lsp-ts', file = 'bad.ts', cmd = 'tsc', slow = 8000 },
	{ name = 'powershell_es', server = 'powershell_es', sample = 'lsp-ps1', file = 'bad.ps1', cmd = 'pwsh', timeout = 30000, slow = 15000 },
}

for _, c in ipairs(LSP) do
	T['lsp: ' .. c.name] = S:case({ name = 'lsp ' .. c.name, groups = { 'lsp', c.name }, requires = { server = c.server, cmd = c.cmd }, timeout = c.timeout, slow = c.slow }, function(ctx)
		boot()
		if not child.lua('return vim.lsp.is_enabled(...)', { c.server }) then
			MiniTest.skip(c.server .. ' is not enabled (lua/genja/lsp/local.lua)')
		end
		if child.lua('return vim.fn.executable(...)', { c.cmd }) == 0 then
			MiniTest.skip(c.cmd .. ' not installed')
		end
		local file = copy_sample(c.sample) .. '/' .. c.file
		local check = string.format([[#vim.lsp.get_clients({ bufnr = 0, name = %q }) > 0]], c.server)
		if not c.attach_only then
			check = check .. ' and #vim.diagnostic.get(0) > 0'
		end
		local ok = open_and_wait(file, check, ctx.timeout)
		if not ok then
			local state = child.lua([[
				return { clients = vim.tbl_map(function(x) return x.name end, vim.lsp.get_clients({ bufnr = 0 })), all = vim.tbl_map(function(x) return x.name end, vim.lsp.get_clients()), log = (function() local l = vim.fn.readfile(vim.lsp.log.get_filename()); return l[#l] end)(),
					diagnostics = #vim.diagnostic.get(0), ft = vim.bo.filetype }
			]])
			error(('%s: no %s within %d ms: %s'):format(c.name, c.attach_only and 'attach' or 'attach + diagnostic',
				ctx.timeout, vim.inspect(state, { newline = ' ', indent = '' })))
		end
	end)
end
-- }}}

-- {{{ ready: time from opening a file to the server's first useful completion

-- Same check by hand, with times: pwsh -File tests/manual/measure-lua-ls.ps1
---@type { name: string, server: string, sample: string, file: string, cmd: string, want: string, timeout?: integer, slow?: integer }[]
local READY = {
	-- lua_ls answers empty lists while loading: ready 5-7 s after opening the file
	{ name = 'lua_ls', server = 'lua_ls', sample = 'ready-lua', file = 'main.lua', cmd = 'lua-language-server', want = 'hello', timeout = 10000, slow = 8000 },
}

for _, c in ipairs(READY) do
	T['ready: ' .. c.name] = S:case({ name = 'ready ' .. c.name, groups = { 'ready', c.name }, requires = { server = c.server, cmd = c.cmd }, timeout = c.timeout, slow = c.slow }, function(ctx)
		boot()
		if not child.lua('return vim.lsp.is_enabled(...)', { c.server }) then
			MiniTest.skip(c.server .. ' is not enabled (lua/genja/lsp/local.lua)')
		end
		if child.lua('return vim.fn.executable(...)', { c.cmd }) == 0 then
			MiniTest.skip(c.cmd .. ' not installed')
		end
		local file = copy_sample(c.sample) .. '/' .. c.file
		local helper = config .. '/tests/helpers/lsp-hello.lua'
		local r = child.lua('local h, f, w, t = ...; return dofile(h).measure(f, w, t)', { helper, file, c.want, ctx.timeout })
		if r.error then
			error(('%s: %s: %s'):format(c.name, r.error, vim.inspect(r, { newline = ' ', indent = '' })))
		end
		MiniTest.add_note(('%s: attach %d ms, ready %d ms, %d tries'):format(c.name, r.attach_ms, r.ready_ms, r.tries))
	end)
end
-- }}}

-- {{{ cmp: offers items from the server

---@type { name: string, server: string, sample: string, file: string, cmd: string, line: integer, type: string, want: string, timeout?: integer, slow?: integer }[]
local CMP = {
	-- after `t.`: the table's fields
	{ name = 'lua_ls', server = 'lua_ls', sample = 'cmp-lua', file = 'main.lua', cmd = 'lua-language-server', line = 3, type = 't.al', want = 'alpha', timeout = 10000, slow = 8000 },
	{ name = 'vimls', server = 'vimls', sample = 'cmp-vim', file = 'main.vim', cmd = 'vim-language-server', line = 2, type = 'call str', want = 'strlen', slow = 6000 },
}

for _, c in ipairs(CMP) do
	T['cmp: ' .. c.name] = S:case({ name = 'cmp ' .. c.name, groups = { 'cmp', c.name }, requires = { server = c.server, cmd = c.cmd }, timeout = c.timeout, slow = c.slow }, function(ctx)
		boot()
		if not child.lua('return vim.lsp.is_enabled(...)', { c.server }) then
			MiniTest.skip(c.server .. ' is not enabled')
		end
		if child.lua('return vim.fn.executable(...)', { c.cmd }) == 0 then
			MiniTest.skip(c.cmd .. ' not installed')
		end
		local file = copy_sample(c.sample) .. '/' .. c.file
		local attached = open_and_wait(file, string.format([[#vim.lsp.get_clients({ bufnr = 0, name = %q }) > 0]], c.server), ctx.timeout)
		eq(attached, true)
		child.lua('vim.api.nvim_buf_set_lines(0, ..., ..., false, { "" })', { c.line - 1, c.line - 1 })
		child.lua('vim.api.nvim_win_set_cursor(0, { ..., 0 })', { c.line })
		child.type_keys('A', c.type)
		-- ask again while the server warms up
		local found = H.wait(function()
			return child.lua(string.format([[
				local blink = require('blink.cmp')
				for _, item in ipairs(blink.get_items() or {}) do
					if item.source_id == 'lsp' and vim.startswith(item.label, %q) then return true end
				end
				-- not there yet: ask the server again (show() answers on a later poll)
				blink.hide()
				blink.show({ providers = { 'lsp' } })
				return false
			]], c.want))
		end, ctx.timeout, 300)
		-- what blink offered instead, read before <Esc> closes the menu
		local state = nil
		if not found then
			state = child.lua([[
				local blink = require('blink.cmp')
				local items = {}
				for i, item in ipairs(blink.get_items() or {}) do
					if i > 20 then break end
					table.insert(items, item.source_id .. ':' .. item.label)
				end
				-- ask the server directly: empty answer, or blink not using it?
				local client = vim.lsp.get_clients({ bufnr = 0 })[1]
				local direct = 'no client'
				if client then
					local params = vim.lsp.util.make_position_params(0, client.offset_encoding)
					-- lua_ls answers an empty list while it is still loading its workspace
					local res, err = vim.lsp.buf_request_sync(0, 'textDocument/completion', params, 3000)
					direct = {}
					if not res then
						table.insert(direct, 'no answer: ' .. tostring(err))
					end
					for _, r in pairs(res or {}) do
						local list = r.result or {}
						for _, it in ipairs(list.items or list) do
							table.insert(direct, it.label)
						end
						if r.err then table.insert(direct, 'err: ' .. vim.inspect(r.err)) end
					end
				end
				return { visible = blink.is_menu_visible(), line = vim.api.nvim_get_current_line(), items = items,
					clients = vim.tbl_map(function(x) return x.name end, vim.lsp.get_clients({ bufnr = 0 })),
					sources = require('blink.cmp.config').sources.default, direct = direct }
			]])
		end
		child.type_keys('<Esc>')
		if not found then
			error(('%s: no lsp item %q within %d ms: %s'):format(c.name, c.want, ctx.timeout,
				vim.inspect(state, { newline = ' ', indent = '' })))
		end
	end)
end
-- }}}

-- {{{ lint: each linter of lua/genja/ext/lint.lua reports on its sample

---@type { name: string, sample: string, file: string, cmd: string, source: string, write?: fun(dir: string), timeout?: integer, slow?: integer, needs?: string, needs_fix?: string }[]
local LINT = {
	{ name = 'markdownlint-cli2', sample = 'lint-markdownlint', file = 'x.md', cmd = 'markdownlint-cli2', source = 'markdownlint' },
	{ name = 'typos', sample = 'lint-typos', file = 'x.md', cmd = 'typos', source = 'typos' },
	{ name = 'yamllint', sample = 'lint-yamllint', file = 'x.yaml', cmd = 'yamllint', source = 'yamllint' },
	{ name = 'actionlint', sample = 'lint-actionlint', file = '.github/workflows/ci.yml', cmd = 'actionlint', source = 'actionlint' },
	{ name = 'selene', sample = 'lint-selene', file = 'x.lua', cmd = 'selene', source = 'selene' },
	{ name = 'checkmake', sample = 'lint-checkmake', file = 'Makefile', cmd = 'checkmake', source = 'checkmake' },
	{ name = 'phpcs', sample = 'lint-phpcs', file = 'x.php', cmd = 'phpcs', source = 'phpcs', slow = 5000 },
	{ name = 'hadolint', sample = 'lint-hadolint', file = 'Dockerfile', cmd = 'hadolint', source = 'hadolint' },
	{ name = 'ruff', sample = 'lint-ruff', file = 'x.py', cmd = 'ruff', source = 'ruff' },
	{ name = 'editorconfig-checker', sample = 'lint-editorconfig', file = 'x.lua', cmd = 'editorconfig-checker', source = 'editorconfig' },
	{
		name = 'gitleaks', sample = 'lint-typos', file = 'secret.txt', cmd = 'gitleaks', source = 'gitleaks',
		-- built here: a token-shaped string committed to the repo would trip secret scanners
		write = function(dir)
			local token = 'gh' .. 'p_' .. '8Zx2Lq9Wv4Tn6Yb1' .. 'Kc3Md5Rf7Hs0Jp2Ga4Ue'
			vim.fn.writefile({ 'github_token = "' .. token .. '"' }, dir .. '/secret.txt')
		end,
	},
	{
		name = 'vale', sample = 'lint-vale', file = 'x.md', cmd = 'vale', source = 'vale',
		needs = vim.fs.joinpath(vim.fn.stdpath('data'), 'vale', 'styles', 'Microsoft'),
		needs_fix = 'run :ValeSync',
	},
}

for _, c in ipairs(LINT) do
	T['lint: ' .. c.name] = S:case({ name = 'lint ' .. c.name, groups = { 'lint', c.name }, requires = { cmd = c.cmd, path = c.needs, path_fix = c.needs_fix }, timeout = c.timeout, slow = c.slow }, function(ctx)
		if c.needs and not vim.uv.fs_stat(c.needs) then
			MiniTest.skip(c.name .. ': ' .. (c.needs_fix or ('missing ' .. c.needs)))
		end
		boot()
		if child.lua('return vim.fn.executable(...)', { c.cmd }) == 0 then
			MiniTest.skip(c.cmd .. ' not installed')
		end
		local dir = copy_sample(c.sample)
		if c.write then
			c.write(dir)
		end
		local check = string.format([[
			(function()
				for _, d in ipairs(vim.diagnostic.get(0)) do
					if tostring(d.source or ''):lower():find(%q, 1, true) then return true end
				end
				return false
			end)()
		]], c.source:lower())
		local ok = open_and_wait(dir .. '/' .. c.file, check, ctx.timeout)
		if not ok then
			local seen = child.lua([[return vim.tbl_map(function(d) return tostring(d.source) .. ': ' .. d.message end, vim.diagnostic.get(0))]])
			error(('%s: no diagnostic from %s within %d ms; got %s'):format(c.name, c.source, ctx.timeout, vim.inspect(seen)))
		end
	end)
end
-- }}}

return T
