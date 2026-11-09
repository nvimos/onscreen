-- Tests: run the nearest test, a file or the suite, with results inline; same keys for PHP and Go.
-- PHP adapters on top of genja's LSP setup (plug-wip/genja-completion011.nvim/lua/genja/lang/php.lua).
-- Go: neotest-golang (runs go test); go.nvim's :GoTest* commands stay as they are (lua/lazyp/langs/go.lua).
-- JS/TS (a React front end next to PHP): neotest-vitest or neotest-jest, picked by the project's config file;
-- a vitest config wins, so a project with both runs each test once.

local VITEST_CONFIGS = {
	'vitest.config.ts', 'vitest.config.js', 'vitest.config.mts', 'vitest.config.mjs',
	'vitest.workspace.ts', 'vitest.workspace.js',
	'vite.config.ts', 'vite.config.js', 'vite.config.mts', 'vite.config.mjs', -- vitest reads vite's config
}
local JEST_CONFIGS = {
	'jest.config.ts', 'jest.config.js', 'jest.config.mjs', 'jest.config.cjs', 'jest.config.json',
}

---@param file string
---@return boolean
local function vitest_project(file)
	return vim.fs.root(file, VITEST_CONFIGS) ~= nil
end

---A jest config file, or a "jest" key in the nearest package.json; never in a vitest project.
---@param file string
---@return boolean
local function jest_project(file)
	if vitest_project(file) then
		return false
	end
	if vim.fs.root(file, JEST_CONFIGS) then
		return true
	end
	local root = vim.fs.root(file, 'package.json')
	if not root then
		return false
	end
	local ok, lines = pcall(vim.fn.readfile, root .. '/package.json')
	-- unreadable package.json: not a jest project as far as we can tell
	return ok and table.concat(lines, '\n'):find('"jest"%s*:') ~= nil
end

---Wrap an adapter so it only takes test files of projects that `in_project` accepts.
---@param adapter table neotest.Adapter
---@param in_project fun(file: string): boolean
---@return table
local function only_in(adapter, in_project)
	local is_test_file = adapter.is_test_file
	adapter.is_test_file = function(file)
		return in_project(file) and is_test_file(file)
	end
	return adapter
end

local Maps = require('genja.map-plugin')

---@type LazySpec
return {
	'nvim-neotest/neotest',
	ft = { 'php', 'go', 'javascript', 'typescript', 'javascriptreact', 'typescriptreact' },
	dependencies = {
		'nvim-neotest/nvim-nio',
		'nvim-lua/plenary.nvim',
		'nvim-treesitter/nvim-treesitter',
		'olimorris/neotest-phpunit',
		'V13Axel/neotest-pest',
		{ 'fredrikaverpil/neotest-golang', version = '*' },
		'marilari88/neotest-vitest',
		'nvim-neotest/neotest-jest',
	},
	keys = Maps:keys(),
	config = function()
		require('neotest').setup({
			adapters = {
				require('neotest-pest'),
				-- Pest projects also have phpunit; leave those to neotest-pest.
				require('neotest-phpunit')({ root_ignore_files = { 'tests/Pest.php' } }),
				require('neotest-golang')({}),
				only_in(require('neotest-vitest')({}), vitest_project),
				only_in(require('neotest-jest')({}), jest_project),
			},
		})
	end,
}
