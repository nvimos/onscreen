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
	markdown = { 'markdownlint-cli2', 'typos', 'vale' },
	gitcommit = { 'typos' },
	yaml = { 'yamllint', 'actionlint' },
	ansible = { 'ansible_lint_wsl' },
	lua = { 'selene' },
	make = { 'checkmake' },
	php = { 'phpcs' },
	dockerfile = { 'hadolint' },
	python = { 'ruff' },
	-- vim = { 'vint' }, -- disabled: crashes on Windows (Vimjas/vint#378, #394); todo-ideas.md 14e
}

---Linters for every filetype (after the by_ft ones).
---@type string[]
M.any = { 'editorconfig-checker', 'gitleaks' }

---Mason packages for the linters above; ansible-lint runs inside WSL instead.
---@type string[]
M.mason = {
	'markdownlint-cli2', 'typos', 'yamllint', 'actionlint', 'selene', 'checkmake', 'phpcs',
	'hadolint', 'ruff', 'editorconfig-checker', 'gitleaks', 'vale',
	-- 'vint', -- disabled, see by_ft.vim
}

---Config files that switch a linter on; the linter runs in the dir that has one.
---@type table<string, string[]>
local ROOT_MARKERS = {
	selene = { 'selene.toml' },
	phpcs = { 'phpcs.xml', '.phpcs.xml', 'phpcs.xml.dist', '.phpcs.xml.dist' },
	['editorconfig-checker'] = { '.editorconfig' },
}

---Shared markdownlint rules (line length off), used when the project has none of its own.
local MARKDOWNLINT_CONFIG = vim.fs.joinpath(vim.fn.stdpath('config'), 'lint', '.markdownlint.jsonc')

-- {{{ vale

---Shared vale config (Microsoft, write-good), used when the project has no .vale.ini.
local VALE_CONFIG = vim.fs.joinpath(vim.fn.stdpath('config'), 'lint', '.vale.ini')
---Styles for the shared config, downloaded by :ValeSync; not in the repo.
local VALE_STYLES = vim.fs.joinpath(vim.fn.stdpath('data'), 'vale', 'styles')
local VALE_PROJECT = { '.vale.ini', '_vale.ini' }

---nvim-lint's own vale args, before the shared --config is put in front.
---@type table|nil
local vale_args = nil

---Point vale at the project's config, else at the shared one.
---@param linter table nvim-lint's vale linter (changed in place before each run)
---@param buf integer
---@return string|false|nil cwd # the project's dir; nil: shared config; false: skip the run
local function prepare_vale(linter, buf)
	if vale_args == nil then
		vale_args = vim.deepcopy(linter.args)
	end
	local project = vim.fs.root(buf, VALE_PROJECT)
	if project then
		-- vale finds the project's config from the cwd up
		linter.args = vim.deepcopy(vale_args)
		linter.env = nil
		return project
	end
	-- the shared config needs its styles; without them vale prints an error, not JSON
	if not vim.uv.fs_stat(vim.fs.joinpath(VALE_STYLES, 'Microsoft')) then
		return false
	end
	linter.args = { '--config', VALE_CONFIG }
	vim.list_extend(linter.args, vim.deepcopy(vale_args))
	-- VALE_STYLES_PATH overrides StylesPath, so the ini needs no machine-specific path
	linter.env = { VALE_STYLES_PATH = VALE_STYLES }
	return nil
end

---:ValeSync: download the shared config's styles into stdpath('data')/vale/styles.
local function vale_sync()
	if vim.fn.executable('vale') == 0 then
		vim.notify(SRC .. 'no vale in PATH; :MasonToolsInstall first', vim.log.levels.WARN)
		return
	end
	vim.fn.mkdir(VALE_STYLES, 'p')
	vim.notify(SRC .. 'vale sync into ' .. VALE_STYLES .. ' …')
	local env = { VALE_STYLES_PATH = VALE_STYLES }
	vim.system({ 'vale', '--config', VALE_CONFIG, 'sync' }, { env = env, text = true }, vim.schedule_wrap(function(res)
		if res.code == 0 then
			vim.notify(SRC .. 'vale styles synced; markdown buffers lint with them from the next save')
		else
			vim.notify(SRC .. 'vale sync failed: ' .. vim.trim((res.stderr or '') .. (res.stdout or '')), vim.log.levels.ERROR)
		end
	end))
end
-- }}}

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
	-- the ruff language server (genja-completion011, lang python) lints already
	ruff = function(buf) return #vim.lsp.get_clients({ bufnr = buf, name = 'ruff' }) == 0 end,
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

---Linter names for `buf`'s filetype, from M.by_ft and M.any, each name once.
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
	for _, name in ipairs(M.any) do
		if not seen[name] then
			seen[name] = true
			table.insert(names, name)
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
		if ok and name == 'vale' then
			local vale_cwd = prepare_vale(linter, buf)
			if vale_cwd == false then
				ok = false
			else
				cwd = vale_cwd
			end
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

	vim.api.nvim_create_user_command('ValeSync', vale_sync, { desc = 'Lint: download the shared vale styles' })

	local group = vim.api.nvim_create_augroup('genja_lint', { clear = true })
	vim.api.nvim_create_autocmd({ 'BufReadPost', 'BufWritePost', 'InsertLeave' }, {
		group = group,
		callback = function(ev) M.lint(ev.buf, ev.event) end,
	})
	-- buffers opened before the spec loaded (VeryLazy)
	M.lint(vim.api.nvim_get_current_buf(), 'BufReadPost')
end

return M
