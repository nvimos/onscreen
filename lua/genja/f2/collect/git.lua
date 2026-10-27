-- <F2> source, group `git`, oil buffers only. For the repo around oil's dir:
--   staged (N files)  sub-picker over the staged files, `git diff --cached` preview,
--                  <CR> unstages (git restore --staged), <Tab> marks
--   add (N files)  sub-picker over the changed files (git status codes,
--                  repo-relative paths), diff preview (hidden at start), <Tab> marks,
--                  <CR> git add, <M-a> git add current (picker stays, row shows the new status),
--                  <C-p> toggles the preview, <M-t> tabedit (picker stays), <M-e> edit

local M = {}

local SRC = 'lua/genja/f2/collect/git.lua: '

---@class genja.f2.GitFile
---@field xy string porcelain status, e.g. ' M', '??'
---@field path string relative to the repo root

-- `git status --porcelain=v1 -z`: "XY path\0", renames/copies add "\0orig".
---@param stdout string
---@return genja.f2.GitFile[] every entry, unsorted
local function status_entries(stdout)
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
			table.insert(files, { xy = xy, path = part:sub(4) })
		end
		i = i + 1
	end
	return files
end

---@param files genja.f2.GitFile[]
---@return genja.f2.GitFile[]
local function by_path(files)
	table.sort(files, function(a, b) return a.path < b.path end)
	return files
end

-- Keeps files with a worktree change (Y set) or untracked; staged-only ones
-- have nothing left to add.
---@return genja.f2.GitFile[]
local function parse_status(stdout)
	return by_path(vim.tbl_filter(function(file)
		return file.xy == '??' or file.xy:sub(2, 2) ~= ' '
	end, status_entries(stdout)))
end

-- Files with a staged change (X set, not untracked): what `git restore --staged` can take back.
---@return genja.f2.GitFile[]
local function parse_staged(stdout)
	return by_path(vim.tbl_filter(function(file)
		local x = file.xy:sub(1, 1)
		return x ~= ' ' and x ~= '?'
	end, status_entries(stdout)))
end

---Run `git <args> -- <paths>` in root; `on_ok(stderr)` after success, then refresh oil-git
---(it refreshed on picker close, before git finished).
---@param root string
---@param args string[]
---@param paths string[]
---@param on_ok fun(stderr: string)
local function git_paths(root, args, paths, on_ok)
	local cmd = vim.list_extend(vim.list_extend({ 'git' }, args), { '--' })
	vim.system(vim.list_extend(cmd, paths), { cwd = root, text = true }, vim.schedule_wrap(function(res)
		if res.code ~= 0 then
			vim.notify(SRC .. 'git ' .. table.concat(args, ' ') .. ' failed:\n' .. (res.stderr or ''), vim.log.levels.ERROR)
		else
			on_ok(res.stderr or '')
		end
		if vim.bo.filetype == 'oil' then
			require('genja.oil.git').refresh_oil_git()
		end
	end))
end

---@param root string
---@param paths string[]
local function git_unstage(root, paths)
	git_paths(root, { 'restore', '--staged' }, paths, function()
		vim.notify(SRC .. 'unstaged ' .. #paths .. ' file(s)')
	end)
end

---@param root string
---@param paths string[]
---@param on_added? fun() called after a successful add
local function git_add(root, paths, on_added)
	git_paths(root, { 'add' }, paths, function(stderr)
		if stderr ~= '' then
			vim.notify(SRC .. stderr, vim.log.levels.WARN) -- e.g. CRLF warnings
		end
		if on_added then
			on_added()
		end
	end)
end

-- status after `git add`: the worktree change moves to the staged column
---@param xy string
---@return string
local function staged_xy(xy)
	if xy == '??' then
		return 'A '
	end
	local x = xy:sub(1, 1)
	if x == ' ' then
		x = xy:sub(2, 2)
	end
	return x .. ' '
end

-- diff for tracked files, the file itself (first 500 lines) for untracked;
-- staged: what's in the index (`git diff --cached`), hunk by hunk
---@param root string
---@param file genja.f2.GitFile
---@param staged? boolean
---@return string[] lines, string filetype
local function preview_lines(root, file, staged)
	if file.xy == '??' and not staged then
		local ok, lines = pcall(vim.fn.readfile, root .. '/' .. file.path, '', 500)
		if not ok then
			return { 'unreadable: ' .. file.path }, ''
		end
		return lines, vim.filetype.match({ filename = file.path }) or ''
	end
	local cmd = { 'git', 'diff', '--', file.path }
	if staged then
		table.insert(cmd, 3, '--cached')
	end
	local res = vim.system(cmd, { cwd = root, text = true }):wait()
	return vim.split(res.stdout or '', '\n'), 'diff'
end

-- `XY path` as in `git status --short`, coloured like it: staged column
-- green, unstaged column and untracked red
---@param file genja.f2.GitFile
local function display(file)
	local first = (file.xy == '??' and 'Removed' or 'Added')
	return file.xy .. ' ' .. file.path, { { { 0, 1 }, first }, { { 1, 2 }, 'Removed' } }
end

---@param root string
---@param staged? boolean
---@return string
local function title_for(root, staged)
	local dir = vim.fn.fnamemodify(root, ':~')
	if staged then
		return 'git staged: ' .. dir .. '  (<Tab> marks, <CR> unstages)'
	end
	return 'git add: ' .. dir .. '  (<Tab> marks)'
end

---@param root string
---@param files genja.f2.GitFile[]
---@param staged? boolean the staged picker: cached diff preview, <CR> unstages
local function pick_files(root, files, staged)
	local actions = require('telescope.actions')
	local action_state = require('telescope.actions.state')
	local previewers = require('telescope.previewers')
	-- ascending: the global config has the prompt on top but sorts descending,
	-- so <Tab> (mark + next worse) moved up
	-- preview_cutoff 1: the vertical layout's default (40 lines) hid the diff in
	-- short windows, and <C-p> can't override it. Strategy key wins over top level.
	local picker_opts = {
		sorting_strategy = 'ascending',
		layout_config = { vertical = { preview_cutoff = 1 } },
		preview = { hide_on_startup = true }, -- <C-p> shows it
	}
	require('telescope.pickers').new(picker_opts, {
		prompt_title = title_for(root, staged),
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
				local lines, ft = preview_lines(root, entry.value, staged)
				vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, lines)
				require('telescope.previewers.utils').highlighter(self.state.bufnr, ft)
			end,
		}),
		attach_mappings = function(bufnr, map)
			-- marked paths, else the one under the cursor
			local function selected_paths()
				local picker = action_state.get_current_picker(bufnr)
				local selected = picker:get_multi_selection()
				if #selected == 0 then
					selected = { action_state.get_selected_entry() }
				end
				return vim.tbl_map(function(entry) return entry.value.path end, selected)
			end
			-- same, and closes the picker
			local function take_paths()
				local paths = selected_paths()
				actions.close(bufnr)
				return paths
			end
			local function edit_selected()
				for _, path in ipairs(take_paths()) do
					vim.cmd.edit(vim.fn.fnameescape(root .. '/' .. path))
				end
			end
			-- Opens tabs behind the picker and returns to the prompt. Telescope
			-- closes the picker on the prompt buffer's BufLeave, so ignore that.
			local function tabedit_selected()
				local tab = vim.api.nvim_get_current_tabpage()
				local win = vim.api.nvim_get_current_win()
				local saved_eventignore = vim.o.eventignore
				vim.opt.eventignore:append('BufLeave')
				local ok, err = pcall(function()
					for _, path in ipairs(selected_paths()) do
						vim.cmd.tabedit(vim.fn.fnameescape(root .. '/' .. path))
					end
				end)
				vim.api.nvim_set_current_tabpage(tab)
				vim.api.nvim_set_current_win(win)
				vim.o.eventignore = saved_eventignore
				if not ok then
					vim.notify(SRC .. 'tabedit failed: ' .. tostring(err), vim.log.levels.ERROR)
				end
			end
			-- Adds the entry under the cursor and redraws its row with the new
			-- status; the list keeps the file, the picker stays open.
			local function add_current()
				local picker = action_state.get_current_picker(bufnr)
				local entry = action_state.get_selected_entry()
				if not entry then
					return
				end
				local file = entry.value
				git_add(root, { file.path }, function()
					file.xy = staged_xy(file.xy)
					vim.notify(SRC .. 'added ' .. vim.fs.basename(file.path))
					local index = picker.manager:find_entry(entry)
					if not index or not vim.api.nvim_buf_is_valid(picker.results_bufnr) then
						return
					end
					local row = picker:get_row(index)
					picker:entry_adder(index, entry, nil, false)
					-- entry_adder drops the caret and highlights; this redraws them
					if entry == picker._selection_entry then
						picker:set_selection(row)
					end
				end)
			end
			require('genja-finder').attach_shared_keys(map) -- Telemap keys and <M-f> filter
			if not staged then
				map({ 'i', 'n' }, '<M-a>', add_current, { desc = 'f2 git: add current file, keep the picker' })
			end
			-- same key as oil's preview toggle
			map({ 'i', 'n' }, '<C-p>', require('telescope.actions.layout').toggle_preview, { desc = 'f2 git: toggle preview' })
			map({ 'i', 'n' }, '<M-t>', tabedit_selected, { desc = 'f2 git: open selected in tabs, keep the picker' })
			map({ 'i', 'n' }, '<M-e>', edit_selected, { desc = 'f2 git: edit selected' })
			actions.select_default:replace(function()
				local paths = take_paths()
				if #paths == 0 then
					return
				end
				if staged then
					git_unstage(root, paths)
				else
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
		local staged = parse_staged(res.stdout or '')
		local tasks = {}
		if #files > 0 then
			table.insert(tasks, {
				group = 'git',
				label = ('add (%d files)'):format(#files),
				action = function() pick_files(root, files) end,
			})
		end
		if #staged > 0 then
			table.insert(tasks, {
				group = 'git',
				label = ('staged (%d files)'):format(#staged),
				action = function() pick_files(root, staged, true) end,
			})
		end
		done(tasks)
	end))
end

-- exposed for tests/f2
M._parse_status = parse_status
M._parse_staged = parse_staged

return M
