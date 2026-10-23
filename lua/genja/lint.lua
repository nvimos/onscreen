-- Linters with no language server (todo-ideas 14e), run through nvim-lint.
-- Spec: lua/lazyp/new/nvim-lint.lua. Mason installs them: :MasonToolsInstall
-- (lua/lazyp/langs-comps/mason-tool-installer.lua reads M.mason).
--
-- A linter runs only when its command is found (mason's bin is on PATH once mason is set up),
-- so a missing tool stays quiet. File-based linters (stdin = false) skip InsertLeave.
-- genja-commit lints gitcommit with its own gitlint linter; typos runs there too.

local SRC = 'lua/genja/lint.lua: '

local M = {}

---Filetype parts -> nvim-lint linter names; a compound filetype (yaml.ansible) gets every part.
---@type table<string, string[]>
M.by_ft = {
	markdown = { 'markdownlint-cli2', 'typos' },
	gitcommit = { 'typos' },
	yaml = { 'yamllint', 'actionlint' },
	ansible = { 'ansible_lint_wsl' },
	lua = { 'selene' },
	make = { 'checkmake' },
	php = { 'phpcs' },
}

---Mason packages for the linters above; ansible-lint runs inside WSL instead.
---@type string[]
M.mason = { 'markdownlint-cli2', 'typos', 'yamllint', 'actionlint', 'selene', 'checkmake', 'phpcs' }

---Config files that switch a linter on; the linter runs in the dir that has one.
---@type table<string, string[]>
local ROOT_MARKERS = {
	selene = { 'selene.toml' },
	phpcs = { 'phpcs.xml', '.phpcs.xml', 'phpcs.xml.dist', '.phpcs.xml.dist' },
}

---Shared markdownlint rules (line length off), used when the project has none of its own.
local MARKDOWNLINT_CONFIG = vim.fs.joinpath(vim.fn.stdpath('config'), 'lint', '.markdownlint.jsonc')

---True for GitHub workflow files (.github/workflows/*.yml).
---@param buf integer
---@return boolean
local function is_workflow(buf)
	local name = vim.fs.normalize(vim.api.nvim_buf_get_name(buf))
	return name:find('/%.github/workflows/[^/]+%.ya?ml$') ~= nil
end

---Extra conditions per linter.
---@type table<string, fun(buf: integer): boolean>
local COND = {
	actionlint = is_workflow,
	-- workflows are .yml too, and .yml is yaml.ansible here (lua/genja/ft/yaml.lua)
	ansible_lint_wsl = function(buf) return not is_workflow(buf) end,
}

-- {{{ ansible-lint in WSL

---Windows path as seen from WSL: C:/x -> /mnt/c/x.
---@param path string
---@return string
local function to_wsl(path)
	path = vim.fs.normalize(path)
	local drive, rest = path:match('^(%a):/(.*)$')
	if drive then
		return '/mnt/' .. drive:lower() .. '/' .. rest
	end
	return path
end

---WSL distro from lua/genja/lsp/local.lua (`phpactor_wsl.distro`), nil: the default one.
---@return string|nil
local function wsl_distro()
	local ok, lsp = pcall(require, 'genja.lsp')
	if not ok then
		return nil
	end
	local wsl = lsp.get().phpactor_wsl
	if wsl then
		return wsl.distro
	end
	return nil
end

---ansible-lint run by wsl.exe on the saved file; output lines `path:line[:col]: rule: message`.
---@return table nvim-lint linter
local function ansible_lint_wsl()
	local args = {}
	local distro = wsl_distro()
	if distro then
		vim.list_extend(args, { '-d', distro })
	end
	vim.list_extend(args, {
		'--', 'ansible-lint', '-p', '--nocolor',
		function() return to_wsl(vim.api.nvim_buf_get_name(0)) end,
	})
	return {
		cmd = 'wsl.exe',
		args = args,
		stdin = false,
		append_fname = false,
		ignore_exitcode = true,
		env = { WSL_UTF8 = '1' },
		-- own parser: the paths are WSL paths, errorformat would put them in other buffers
		parser = function(output)
			local diagnostics = {}
			for line in output:gmatch('[^\r\n]+') do
				local lnum, col, message = line:match('^[^:]+:(%d+):(%d+):%s*(.*)$')
				if not lnum then
					lnum, message = line:match('^[^:]+:(%d+):%s*(.*)$')
					col = '1'
				end
				if lnum then
					table.insert(diagnostics, {
						lnum = tonumber(lnum) - 1,
						col = tonumber(col) - 1,
						message = message,
						source = 'ansible-lint',
						severity = vim.diagnostic.severity.INFO,
					})
				end
			end
			return diagnostics
		end,
	}
end
-- }}}

---Linter names for `buf`'s filetype, from M.by_ft, each name once.
---@param buf integer
---@return string[]
local function names_for(buf)
	local names = {}
	local seen = {}
	for _, part in ipairs(vim.split(vim.bo[buf].filetype, '.', { plain = true })) do
		for _, name in ipairs(M.by_ft[part] or {}) do
			if not seen[name] then
				seen[name] = true
				table.insert(names, name)
			end
		end
	end
	return names
end

---Is the linter's command on PATH?
---@param linter table
---@return boolean
local function available(linter)
	local cmd = linter.cmd
	if type(cmd) == 'function' then
		cmd = cmd()
	end
	return type(cmd) == 'string' and vim.fn.executable(cmd) == 1
end

---Lint `buf` with its linters that are installed and apply here.
---@param buf integer
---@param event string autocmd event; InsertLeave runs only stdin linters (the file isn't saved)
function M.lint(buf, event)
	if vim.bo[buf].buftype ~= '' or vim.api.nvim_buf_get_name(buf) == '' then
		return
	end
	local lint = require('lint')
	for _, name in ipairs(names_for(buf)) do
		local linter = lint.linters[name]
		if type(linter) == 'function' then
			linter = linter()
		end
		local ok = linter ~= nil and available(linter)
		if ok and event == 'InsertLeave' and not linter.stdin then
			ok = false
		end
		if ok and COND[name] then
			ok = COND[name](buf)
		end
		local cwd = nil
		if ok and ROOT_MARKERS[name] then
			cwd = vim.fs.root(buf, ROOT_MARKERS[name])
			ok = cwd ~= nil
		end
		if ok then
			vim.api.nvim_buf_call(buf, function()
				lint.try_lint(name, { cwd = cwd })
			end)
		end
	end
end

---Register the WSL linter, the markdownlint config and the autocmds.
function M.setup()
	local lint = require('lint')
	lint.linters.ansible_lint_wsl = ansible_lint_wsl()

	-- markdownlint: shared rules unless the project brings its own (cwd is :pwd)
	local mdl = lint.linters['markdownlint-cli2']
	if type(mdl) == 'table' and vim.uv.fs_stat(MARKDOWNLINT_CONFIG) then
		mdl.args = { '--config', MARKDOWNLINT_CONFIG, '-' }
	elseif not vim.uv.fs_stat(MARKDOWNLINT_CONFIG) then
		vim.notify(SRC .. 'no ' .. MARKDOWNLINT_CONFIG .. '; markdownlint uses its defaults', vim.log.levels.WARN)
	end

	local group = vim.api.nvim_create_augroup('genja_lint', { clear = true })
	vim.api.nvim_create_autocmd({ 'BufReadPost', 'BufWritePost', 'InsertLeave' }, {
		group = group,
		callback = function(ev) M.lint(ev.buf, ev.event) end,
	})
	-- buffers opened before the spec loaded (VeryLazy)
	M.lint(vim.api.nvim_get_current_buf(), 'BufReadPost')
end

return M
