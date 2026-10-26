-- `make status` in tests/: which languages are on, and whether their servers, mason tools and
-- the linters of lua/genja/lint.lua are installed. Runs no tests; nvim with the real config.
dofile('tests/helpers/real-config.lua').prepare()

local installed = require('genja.lsp.installed')
local out = {}

---@param ok boolean
---@return string
local function mark(ok)
	if ok then
		return 'ok'
	end
	return 'MISSING'
end

-- row order in every section: on and ok, then on but missing, then off
local OK, BROKEN, OFF = 1, 2, 3

---Sort rows by rank, then by `key` when given, else keep their (alphabetical) order; add them
---to `out`.
---@param rows { rank: integer, line: string, key?: string, i?: integer }[]
local function add_ranked(rows)
	for i, row in ipairs(rows) do
		row.i = i
	end
	table.sort(rows, function(a, b)
		if a.rank ~= b.rank then
			return a.rank < b.rank
		end
		if a.key and b.key and a.key ~= b.key then
			return a.key < b.key
		end
		return a.i < b.i
	end)
	for _, row in ipairs(rows) do
		table.insert(out, row.line)
	end
end

---@param ok boolean
---@return integer
local function rank(ok)
	if ok then
		return OK
	end
	return BROKEN
end

-- {{{ languages and their servers
table.insert(out, 'languages (lua/genja/lsp/local.lua), servers')
table.insert(out, '  installed: ok or MISSING, enabled = vim.lsp.enable() ran for it; - = language off')
-- column names, same widths as the rows below
table.insert(out, ('  %-12s %-4s %-12s %-16s %s'):format('language', 'on', 'installed', 'server', 'command or note'))
local tools = {}
local rows = {}
for _, lang in ipairs(require('genja.lsp').languages()) do
	local state = 'off'
	if lang.on then
		state = 'on'
		for _, tool in ipairs(lang.tools) do
			tools[tool] = true
		end
	end
	if #lang.servers == 0 then
		local row_rank = OFF
		if lang.on then
			row_rank = OK
		end
		-- '~' sorts after letters: rows without a server come last in their rank
		table.insert(rows, { rank = row_rank, key = '~', line = ('  %-12s %-4s %-12s %-16s %s'):format(lang.name, state, '-', '(no server)', lang.note or '') })
	end
	for _, server in ipairs(lang.servers) do
		local item = installed.check(server)
		local cmd = item.cmd or item.note or '?'
		local result = '-'
		local row_rank = OFF
		if lang.on then
			result = mark(item.ok)
			row_rank = rank(item.ok)
			if vim.lsp.is_enabled(server) then
				result = result .. ', enabled'
			end
		end
		-- name first, then the fixed-width columns, the long command last
		table.insert(rows, { rank = row_rank, key = server, line = ('  %-12s %-4s %-12s %-16s %s'):format(lang.name, state, result, server, cmd) })
	end
end
add_ranked(rows)
-- }}}

-- {{{ mason tools of the enabled languages
table.insert(out, '')
table.insert(out, 'tools of the enabled languages (mason)')
table.insert(out, ('  %-24s %s'):format('mason package', 'installed'))
local names = vim.tbl_keys(tools)
table.sort(names)
local ok_registry, registry = pcall(require, 'mason-registry')
if #names == 0 then
	table.insert(out, '  (none)')
end
rows = {}
for _, name in ipairs(names) do
	local result = '?'
	local row_rank = BROKEN
	if ok_registry then
		local ok = registry.is_installed(name)
		result = mark(ok)
		row_rank = rank(ok)
	end
	table.insert(rows, { rank = row_rank, line = ('  %-24s %s'):format(name, result) })
end
add_ranked(rows)
-- }}}

-- {{{ linters of lua/genja/lint.lua
table.insert(out, '')
table.insert(out, 'linters (lua/genja/lint.lua; one runs only when its command is found)')
table.insert(out, '  found: command on PATH; filetypes: * = every filetype')
table.insert(out, ('  %-22s %-7s %-19s %s'):format('linter', 'found', 'filetypes', 'command'))
local genja_lint = require('genja.lint')
local ok_lint, lint = pcall(require, 'lint')

---A linter's command: nvim-lint's definition, else its name.
---@param name string
---@return string
local function linter_cmd(name)
	if not ok_lint then
		return name
	end
	local ok, def = pcall(function() return lint.linters[name] end)
	if not ok or def == nil then
		return name
	end
	if type(def) == 'function' then
		ok, def = pcall(def)
		if not ok or type(def) ~= 'table' then
			return name
		end
	end
	local cmd = def.cmd
	if type(cmd) == 'function' then
		ok, cmd = pcall(cmd)
		if not ok then
			return name
		end
	end
	if type(cmd) == 'string' then
		return cmd
	end
	return name
end

local linters = {} ---@type table<string, string[]> linter -> filetypes
for ft, list in pairs(genja_lint.by_ft) do
	for _, name in ipairs(list) do
		linters[name] = linters[name] or {}
		table.insert(linters[name], ft)
	end
end
for _, name in ipairs(genja_lint.any) do
	linters[name] = linters[name] or {}
	table.insert(linters[name], '*')
end
names = vim.tbl_keys(linters)
table.sort(names)
-- linters have no on/off: lint.lua lists the ones in use
rows = {}
for _, name in ipairs(names) do
	table.sort(linters[name])
	local cmd = linter_cmd(name)
	local ok = vim.fn.executable(cmd) == 1
	table.insert(rows, { rank = rank(ok), line = ('  %-22s %-7s %-19s %s'):format(name, mark(ok),
		table.concat(linters[name], ','), cmd) })
end
add_ranked(rows)
-- }}}

io.stdout:write(table.concat(out, '\n') .. '\n')
