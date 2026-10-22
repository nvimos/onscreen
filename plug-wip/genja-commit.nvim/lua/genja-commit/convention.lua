-- Conventional Commits mode for a repo. First one set wins:
--   1. git config --local genja-commit.conventional (.git/config, not committed)
--   2. project files: commitlint, commitizen, a .gitlint with the CT1 contrib rule
--   3. git config --global genja-commit.conventional (~/.gitconfig)
--   4. opts.conventional

local config = require('genja-commit.config')
local git = require('genja-commit.git')

local M = {}

-- commitlint and commitizen config files; any one of them means "on"
local CONFIG_FILES = {
	'commitlint.config.js', 'commitlint.config.cjs', 'commitlint.config.mjs', 'commitlint.config.ts',
	'.commitlintrc', '.commitlintrc.json', '.commitlintrc.yaml', '.commitlintrc.yml',
	'.commitlintrc.js', '.commitlintrc.cjs',
	'.czrc', '.cz.toml', '.cz.json', '.cz.yaml', 'cz.json', 'cz.yaml', 'cz.toml',
}

---@param dir string
---@param scope '--local'|'--global'
---@return boolean? nil when unset
local function git_setting(dir, scope)
	local out = git.run(dir, { 'config', scope, '--type=bool', '--get', 'genja-commit.conventional' })
	if not out then
		return nil -- unset: git exits 1
	end
	out = vim.trim(out)
	if out == 'true' then
		return true
	end
	if out == 'false' then
		return false
	end
	return nil
end

---@param path string
---@return string?
local function read(path)
	local stat = vim.uv.fs_stat(path)
	if not stat or stat.type ~= 'file' then
		return nil
	end
	return table.concat(vim.fn.readfile(path), '\n')
end

---@param root string
---@return boolean
local function project_uses_it(root)
	for _, name in ipairs(CONFIG_FILES) do
		if vim.uv.fs_stat(root .. '/' .. name) then
			return true
		end
	end
	local package_json = read(root .. '/package.json')
	if package_json then
		local ok, data = pcall(vim.json.decode, package_json)
		if ok and type(data) == 'table' then
			if data.commitlint then
				return true
			end
			if type(data.config) == 'table' and data.config.commitizen then
				return true
			end
		end
	end
	local pyproject = read(root .. '/pyproject.toml')
	if pyproject and pyproject:find('%[tool%.commitizen%]') then
		return true
	end
	local gitlint = read(root .. '/.gitlint')
	if gitlint and (gitlint:find('contrib%-title%-conventional%-commits') or gitlint:find('CT1', 1, true)) then
		return true
	end
	return false
end

---Is Conventional Commits mode on for the repo at dir?
---@param dir string
---@return boolean
function M.enabled(dir)
	local repo = git_setting(dir, '--local')
	if repo ~= nil then
		return repo
	end
	local root = git.run(dir, { 'rev-parse', '--show-toplevel' })
	if root and project_uses_it(vim.fs.normalize(vim.trim(root))) then
		return true
	end
	local global = git_setting(dir, '--global')
	if global ~= nil then
		return global
	end
	return config.get().conventional
end

---Why the title isn't `type(scope)!: description`, nil when it is.
---@param title string
---@return string?
function M.title_error(title)
	local types = config.get().conventional_types
	local expected = 'title must be type(scope): description'
	local kind, rest = title:match('^([%w-]+)(.*)$')
	if not kind then
		return expected
	end
	if rest:sub(1, 1) == '(' then
		local close = rest:find(')', 1, true)
		if not close then
			return 'scope needs a closing )'
		end
		rest = rest:sub(close + 1)
	end
	if rest:sub(1, 1) == '!' then
		rest = rest:sub(2)
	end
	if not rest:match('^: %S') then
		return expected
	end
	if not vim.list_contains(types, kind) then
		return ('unknown type %q, use one of: %s'):format(kind, table.concat(types, ', '))
	end
	return nil
end

return M
