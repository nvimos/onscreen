-- <F2>: context picker (idea #18). Contexts so far:
--   make  a Makefile above the buffer's dir (oil: oil's dir): telescope list of
--         its targets (includes too), the chosen one runs as an overseer task.

local M = {}

local src = 'nvim/lua/genja/f2.lua: '

-- where to look for context: oil's dir, the file's dir, else :pwd.
-- Normalized (forward slashes, no trailing slash): vim.fs.find takes the path as is,
-- and oil gives 'C:\...\nvim\'.
local function start_dir()
	local dir = vim.fn.getcwd()
	local name = vim.api.nvim_buf_get_name(0)
	if vim.bo.filetype == 'oil' then
		dir = require('oil').get_current_dir() or dir
	elseif name ~= '' and vim.bo.buftype == '' then
		dir = vim.fs.dirname(name)
	end
	return vim.fs.normalize(dir)
end

-- {{{ make

local function find_makefile(dir)
	local names = { 'GNUmakefile', 'makefile', 'Makefile' }
	return vim.fs.find(names, { upward = true, type = 'file', path = dir })[1]
end

-- targets from `make -rRpq` (database dump, runs no recipe), like overseer's make
-- provider: the "# Files" section, minus dot/special entries, pattern rules,
-- "# Not a target" entries and the makefiles themselves.
-- Also returns MAKEFILE_LIST: the main makefile and its includes, in read order.
local function parse_targets(stdout)
	local seen = {}
	local targets = {}
	local makefiles = {}
	local in_files = false
	local prev = ''
	for line in vim.gsplit(stdout, '\n', { plain = true }) do
		line = line:gsub('\r$', '')
		local list = line:match('^MAKEFILE_LIST :?= (.*)$')
		if list then
			makefiles = vim.split(vim.trim(list), '%s+', { trimempty = true })
		elseif vim.startswith(line, '# Files') then
			in_files = true
		elseif vim.startswith(line, '# Finished Make') then
			break
		elseif in_files and line:match('^[^%.#%s]') and not vim.startswith(prev, '# Not a target') then
			local target = line:match('^([^:=]+):')
			local is_makefile = target and (target:match('[Mm]akefile') or target:match('%.mk$'))
			if target and not target:find('%', 1, true) and not is_makefile and not seen[target] then
				seen[target] = true
				table.insert(targets, target)
			end
		end
		prev = line
	end
	return targets, makefiles
end

-- picker prefix for a makefile: Makefile.lazy.mk -> 'lazy', tools.mk -> 'tools',
-- the main Makefile -> '' (no prefix)
local function makefile_prefix(path)
	local name = vim.fs.basename(path):gsub('%.mk$', '')
	name = name:gsub('^[Mm]akefile[%.%-_]?', ''):gsub('^GNUmakefile[%.%-_]?', '')
	return name
end

-- target -> prefix of the makefile that defines it, by scanning the makefiles
-- for `target:` lines (first file wins). make -p names the file only for
-- targets with a recipe, so `all: sync` would have none.
local function target_prefixes(dir, makefiles)
	local prefixes = {}
	for _, file in ipairs(makefiles) do
		local path = vim.fs.joinpath(dir, file)
		if vim.fn.filereadable(path) == 1 then
			local prefix = makefile_prefix(file)
			for _, line in ipairs(vim.fn.readfile(path)) do
				local names = line:match('^([^%s:=#%.][^:=]*):')
				if names then
					for _, name in ipairs(vim.split(vim.trim(names), '%s+', { trimempty = true })) do
						if prefixes[name] == nil then
							prefixes[name] = prefix
						end
					end
				end
			end
		end
	end
	return prefixes
end

local function run_target(target, dir)
	local overseer = require('overseer')
	local task = overseer.new_task({ name = 'make ' .. target, cmd = { 'make', target }, cwd = dir })
	task:start()
	overseer.open({ enter = false })
end

-- main Makefile's targets first, then by prefix, then by name
local function sorted_items(targets, prefixes)
	local items = {}
	for _, target in ipairs(targets) do
		local prefix = prefixes[target] or ''
		local display = target
		if prefix ~= '' then
			display = prefix .. ': ' .. target
		end
		table.insert(items, { target = target, prefix = prefix, display = display })
	end
	table.sort(items, function(a, b)
		if a.prefix ~= b.prefix then
			return a.prefix < b.prefix -- '' sorts first
		end
		return a.target < b.target
	end)
	return items
end

local function pick_target(items, dir)
	local actions = require('telescope.actions')
	local action_state = require('telescope.actions.state')
	local title = 'make targets: ' .. vim.fn.fnamemodify(dir, ':~')
	require('telescope.pickers').new(require('telescope.themes').get_dropdown(), {
		prompt_title = title,
		finder = require('telescope.finders').new_table({
			results = items,
			entry_maker = function(item)
				return { value = item, display = item.display, ordinal = item.display }
			end,
		}),
		sorter = require('telescope.config').values.generic_sorter({}),
		attach_mappings = function(bufnr)
			actions.select_default:replace(function()
				local entry = action_state.get_selected_entry()
				actions.close(bufnr)
				if entry then
					run_target(entry.value.target, dir)
				end
			end)
			return true
		end,
	}):find()
end

local function make_context(makefile)
	local dir = vim.fs.dirname(makefile)
	local cmd = { 'make', '-rRpq' }
	vim.system(cmd, { cwd = dir, text = true, env = { LANG = 'C' } }, vim.schedule_wrap(function(res)
		-- -q: exit 1 just means "something is out of date"
		if res.code ~= 0 and res.code ~= 1 then
			vim.notify(src .. 'make -rRpq failed: ' .. vim.trim(res.stderr or ''), vim.log.levels.ERROR)
			return
		end
		local targets, makefiles = parse_targets(res.stdout or '')
		if #targets == 0 then
			vim.notify(src .. 'no targets in ' .. makefile, vim.log.levels.WARN)
			return
		end
		pick_target(sorted_items(targets, target_prefixes(dir, makefiles)), dir)
	end))
end
-- }}}

function M.open()
	local dir = start_dir()
	local makefile = find_makefile(dir)
	if not makefile then
		vim.notify(src .. 'no context here: no Makefile in or above ' .. dir, vim.log.levels.WARN)
		return
	end
	if vim.fn.executable('make') == 0 then
		vim.notify(src .. 'found ' .. makefile .. ', but no make in nvim\'s PATH', vim.log.levels.WARN)
		return
	end
	make_context(makefile)
end

return M
