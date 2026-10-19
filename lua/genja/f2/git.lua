-- <F2> source, group `git`, oil buffers only. For the repo around oil's dir:
--   add (N files)  sub-picker over the changed files (git status codes,
--                  repo-relative paths), diff preview, <Tab> marks, <CR> git add

local run = require('genja.f2.run')

local M = {}

---@class genja.f2.GitFile
---@field xy string porcelain status, e.g. ' M', '??'
---@field path string relative to the repo root

-- `git status --porcelain=v1 -z`: "XY path\0", renames/copies add "\0orig".
-- Keeps files with a worktree change (Y set) or untracked; staged-only ones
-- have nothing left to add.
---@return genja.f2.GitFile[]
local function parse_status(stdout)
	local files = {}
	local parts = vim.split(stdout, '\0', { plain = true })
	local i = 1
	while i <= #parts do
		local part = parts[i]
		if #part > 3 then
			local xy = part:sub(1, 2)
			if xy:sub(1, 1) == 'R' or xy:sub(1, 1) == 'C' then
				i = i + 1 -- skip the original path
			end
			if xy == '??' or xy:sub(2, 2) ~= ' ' then
				table.insert(files, { xy = xy, path = part:sub(4) })
			end
		end
		i = i + 1
	end
	table.sort(files, function(a, b) return a.path < b.path end)
	return files
end

---@param root string
---@param paths string[]
local function git_add(root, paths)
	local cmd = { 'git', 'add', '--' }
	vim.list_extend(cmd, paths)
	local name = 'git add ' .. paths[1]
	if #paths > 1 then
		name = ('git add %s (+%d)'):format(paths[1], #paths - 1)
	end
	run.overseer(name, cmd, root)
end

-- diff for tracked files, the file itself (first 500 lines) for untracked
---@param root string
---@param file genja.f2.GitFile
---@return string[] lines, string filetype
local function preview_lines(root, file)
	if file.xy == '??' then
		local ok, lines = pcall(vim.fn.readfile, root .. '/' .. file.path, '', 500)
		if not ok then
			return { 'unreadable: ' .. file.path }, ''
		end
		return lines, vim.filetype.match({ filename = file.path }) or ''
	end
	local res = vim.system({ 'git', 'diff', '--', file.path }, { cwd = root, text = true }):wait()
	return vim.split(res.stdout or '', '\n'), 'diff'
end

-- `XY path` as in `git status --short`, coloured like it: staged column
-- green, unstaged column and untracked red
---@param file genja.f2.GitFile
local function display(file)
	local text = file.xy .. ' ' .. file.path
	local staged = 'Added'
	if file.xy == '??' then
		staged = 'Removed'
	end
	return text, { { { 0, 1 }, staged }, { { 1, 2 }, 'Removed' } }
end

---@param root string
---@param files genja.f2.GitFile[]
local function pick_files(root, files)
	local actions = require('telescope.actions')
	local action_state = require('telescope.actions.state')
	local previewers = require('telescope.previewers')
	-- ascending: the global config has the prompt on top but sorts descending,
	-- so <Tab> (mark + next worse) moved up
	require('telescope.pickers').new({ sorting_strategy = 'ascending' }, {
		prompt_title = 'git add: ' .. vim.fn.fnamemodify(root, ':~') .. '  (<Tab> marks)',
		finder = require('telescope.finders').new_table({
			results = files,
			entry_maker = function(file)
				return { value = file, display = function() return display(file) end, ordinal = file.path }
			end,
		}),
		sorter = require('telescope.config').values.generic_sorter({}),
		previewer = previewers.new_buffer_previewer({
			title = 'diff',
			define_preview = function(self, entry)
				local lines, ft = preview_lines(root, entry.value)
				vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, lines)
				require('telescope.previewers.utils').highlighter(self.state.bufnr, ft)
			end,
		}),
		attach_mappings = function(bufnr)
			actions.select_default:replace(function()
				local picker = action_state.get_current_picker(bufnr)
				local selected = picker:get_multi_selection()
				if #selected == 0 then
					selected = { action_state.get_selected_entry() }
				end
				actions.close(bufnr)
				local paths = {}
				for _, entry in ipairs(selected) do
					table.insert(paths, entry.value.path)
				end
				if #paths > 0 then
					git_add(root, paths)
				end
			end)
			return true
		end,
	}):find()
end

---@param ctx genja.f2.Ctx
---@param done fun(tasks: genja.f2.Task[])
function M.collect(ctx, done)
	if ctx.filetype ~= 'oil' or vim.fn.executable('git') == 0 then
		done({})
		return
	end
	local root = vim.fs.root(ctx.dir, '.git')
	if not root then
		done({})
		return
	end
	local cmd = { 'git', 'status', '--porcelain=v1', '-z', '--untracked-files=all' }
	vim.system(cmd, { cwd = root, text = true }, vim.schedule_wrap(function(res)
		if res.code ~= 0 then
			done({}) -- not a work tree (bare repo, .git inside a .git dir)
			return
		end
		local files = parse_status(res.stdout or '')
		if #files == 0 then
			done({})
			return
		end
		done({
			{
				group = 'git',
				label = ('add (%d files)'):format(#files),
				action = function() pick_files(root, files) end,
			},
		})
	end))
end

-- exposed for tests/f2
M._parse_status = parse_status

return M
