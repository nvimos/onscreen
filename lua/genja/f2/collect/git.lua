-- <F2> source, group `git`, oil buffers only. For the repo around oil's dir:
--   staged (N files)  sub-picker over the staged files, `git diff --cached` preview,
--                  <CR> unstages (git restore --staged), <Tab> marks
--   add (N files)  sub-picker over the changed files (git status codes,
--                  repo-relative paths), diff preview (hidden at start), <Tab> marks,
--                  <CR> git add, <M-a> git add current (picker stays, row shows the new status),
--                  <C-p> toggles the preview, <M-t> tabedit (picker stays), <M-e> edit
--   diffview open  two branch pickers (FROM, then TO), then `DiffviewOpen FROM...TO -C=<root>`
--   codediff changes | branches | history | pr  only when :CodeDiff exists (lua/lazyp/new/codediff.lua):
--                  local changes, FROM...TO as in a PR, history FROM..TO (both branch pickers as above), pr by number
--   unified changes | branch | commit  only when :Unified exists (lua/lazyp/new/unified.lua): in a new tab at the repo root,
--                  working tree vs HEAD, vs a picked branch, vs a commit from unified's own list
--   deltaview changes | branches  only when :DeltaMenu exists (lua/lazyp/new/deltaview.lua): file picker over
--                  what changed vs HEAD, or FROM...TO (branch pickers as above), in a new tab at the repo root
--   diffview toggle mode  only inside a diffview tab: side by side <-> one window (inline)
--   diffview toggle auto preview  same: file panel j/k open the diff of the file under the cursor (on by default)

local groups = require('genja.f2.groups')

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

-- Local and remote branches, newest commit first, without the `origin/HEAD` alias.
---@param root string
---@return string[]? branches, string? err
local function list_branches(root)
	local cmd = { 'git', 'branch', '--all', '--sort=-committerdate', '--format=%(refname:short)' }
	local res = vim.system(cmd, { cwd = root, text = true }):wait()
	if res.code ~= 0 then
		return nil, res.stderr or ''
	end
	local branches = {}
	for _, name in ipairs(vim.split(res.stdout or '', '\n', { trimempty = true })) do
		if not name:match('/HEAD$') and name ~= 'origin' then
			table.insert(branches, name)
		end
	end
	return branches
end

-- One telescope list of branches; `on_pick(name)` runs after <CR>.
---@param title string
---@param branches string[]
---@param on_pick fun(name: string)
local function pick_branch(title, branches, on_pick)
	local actions = require('telescope.actions')
	local action_state = require('telescope.actions.state')
	-- ascending: same reason as in pick_files
	require('telescope.pickers').new({ sorting_strategy = 'ascending' }, {
		prompt_title = title,
		finder = require('telescope.finders').new_table({ results = branches }),
		sorter = require('telescope.config').values.generic_sorter({}),
		attach_mappings = function(bufnr, map)
			require('genja-finder').attach_shared_keys(map)
			actions.select_default:replace(function()
				local entry = action_state.get_selected_entry()
				if not entry then
					return
				end
				actions.close(bufnr)
				-- next picker after this one is gone, or it closes with the first
				vim.schedule(function() on_pick(entry.value) end)
			end)
			return true
		end,
	}):find()
end

-- FROM branch, then TO branch (two pickers, titled with `name`), then `run(from, to)`.
---@param root string
---@param name string picker title prefix, e.g. 'diffview'
---@param run fun(from: string, to: string)
local function pick_range(root, name, run)
	local branches, err = list_branches(root)
	if not branches then
		vim.notify(SRC .. 'git branch failed:\n' .. err, vim.log.levels.ERROR)
		return
	end
	pick_branch(name .. ' 1/2: FROM branch (base)  <CR> selects', branches, function(from)
		local others = vim.tbl_filter(function(branch) return branch ~= from end, branches)
		pick_branch(name .. ' 2/2: TO branch (compare)  FROM = ' .. from, others, function(to)
			run(from, to)
		end)
	end)
end

-- `DiffviewOpen FROM...TO`: what TO added since it left FROM (the PR view),
-- without checking either out.
---@param root string
local function diffview_open(root)
	pick_range(root, 'diffview', function(from, to)
		local range = vim.fn.fnameescape(from .. '...' .. to)
		vim.cmd('DiffviewOpen ' .. range .. ' -C=' .. vim.fn.fnameescape(root))
	end)
end

-- codediff.nvim (lua/lazyp/new/codediff.lua) is lazy: its :CodeDiff stub exists
-- once the spec is installed; no stub, no items.
---@param root string
---@return genja.f2.Task[]
local function codediff_tasks(root)
	if vim.fn.exists(':CodeDiff') ~= 2 then
		return {}
	end
	local repo = vim.fn.fnameescape(root)
	local function task(label, action)
		return { group = groups.git, label = label, action = action }
	end
	return {
		task('codediff changes', function()
			vim.cmd('CodeDiff --repo ' .. repo)
		end),
		task('codediff branches', function()
			pick_range(root, 'codediff', function(from, to)
				vim.cmd('CodeDiff --repo ' .. repo .. ' ' .. vim.fn.fnameescape(from .. '...' .. to))
			end)
		end),
		task('codediff history', function()
			pick_range(root, 'codediff history', function(from, to)
				vim.cmd('CodeDiff -C ' .. repo .. ' history ' .. vim.fn.fnameescape(from .. '..' .. to))
			end)
		end),
		task('codediff pr', function()
			vim.ui.input({ prompt = 'codediff pr number: ' }, function(input)
				if not input or input == '' then
					return
				end
				if not input:match('^%d+$') then
					vim.notify(SRC .. 'not a pr number: ' .. input, vim.log.levels.WARN)
					return
				end
				vim.cmd('CodeDiff --repo ' .. repo .. ' pr ' .. input)
			end)
		end),
	}
end

-- Only while a diffview tab is current; diffview is not loaded before the first
-- :Diffview command, so don't require it blindly.
---@return boolean
local function diffview_is_open()
	local lib = package.loaded['diffview.lib']
	return lib ~= nil and lib.get_current_view() ~= nil
end

-- `view.cycle_layouts.default` in lua/lazyp/git/diffview.lua holds two layouts
-- (side by side, inline), so cycling is a toggle.
---@return genja.f2.Task
local function diffview_toggle_task()
	return {
		group = groups.git,
		label = 'diffview toggle mode',
		action = function() require('diffview.actions').cycle_layout() end,
	}
end

-- New tab whose directory is the repo root (tab-local), so a viewer that runs git in the
-- cwd sees the repo, whatever oil's directory or the nvim cwd is.
---@param root string
local function repo_tab(root)
	vim.cmd.tabnew()
	vim.cmd.tcd(vim.fn.fnameescape(root))
end

-- unified.nvim (lua/lazyp/new/unified.lua): inline diff against a ref, with a changed-files tree.
---@param root string
---@return genja.f2.Task[]
local function unified_tasks(root)
	if vim.fn.exists(':Unified') ~= 2 then
		return {}
	end
	local function task(label, action)
		return { group = groups.git, label = label, action = action }
	end
	return {
		task('unified changes', function()
			repo_tab(root)
			vim.cmd('Unified HEAD')
		end),
		task('unified branch', function()
			local branches, err = list_branches(root)
			if not branches then
				vim.notify(SRC .. 'git branch failed:\n' .. err, vim.log.levels.ERROR)
				return
			end
			pick_branch('unified: BASE branch to compare the working tree with  <CR> selects', branches, function(base)
				repo_tab(root)
				vim.cmd('Unified ' .. vim.fn.fnameescape(base))
			end)
		end),
		task('unified commit', function()
			repo_tab(root)
			vim.cmd('Unified') -- no ref: unified.nvim lists commits to pick from
		end),
	}
end

-- deltaview.nvim (lua/lazyp/new/deltaview.lua): file picker over what changed, each file as an inline diff.
---@param root string
---@return genja.f2.Task[]
local function deltaview_tasks(root)
	if vim.fn.exists(':DeltaMenu') ~= 2 then
		return {}
	end
	local function task(label, action)
		return { group = groups.git, label = label, action = action }
	end
	return {
		task('deltaview changes', function()
			repo_tab(root)
			vim.cmd('DeltaMenu HEAD')
		end),
		task('deltaview branches', function()
			pick_range(root, 'deltaview', function(from, to)
				repo_tab(root)
				vim.cmd('DeltaMenu ' .. vim.fn.fnameescape(from .. '...' .. to))
			end)
		end),
	}
end

---@param ctx genja.f2.Ctx
---@param done fun(tasks: genja.f2.Task[])
function M.collect(ctx, done)
	local view_tasks = {}
	if diffview_is_open() then
		table.insert(view_tasks, diffview_toggle_task())
		table.insert(view_tasks, {
			group = groups.git,
			label = 'diffview toggle auto preview',
			action = function() require('genja.ext.diffview-autopreview').toggle() end,
		})
	end
	if ctx.filetype ~= 'oil' or vim.fn.executable('git') == 0 then
		done(view_tasks)
		return
	end
	local root = vim.fs.root(ctx.dir, '.git')
	if not root then
		done(view_tasks)
		return
	end
	local cmd = { 'git', 'status', '--porcelain=v1', '-z', '--untracked-files=all' }
	vim.system(cmd, { cwd = root, text = true }, vim.schedule_wrap(function(res)
		if res.code ~= 0 then
			done(view_tasks) -- not a work tree (bare repo, .git inside a .git dir)
			return
		end
		local files = parse_status(res.stdout or '')
		local staged = parse_staged(res.stdout or '')
		local tasks = view_tasks
		table.insert(tasks, {
			group = groups.git,
			label = 'diffview open',
			action = function() diffview_open(root) end,
		})
		vim.list_extend(tasks, codediff_tasks(root))
		vim.list_extend(tasks, unified_tasks(root))
		vim.list_extend(tasks, deltaview_tasks(root))
		if #files > 0 then
			table.insert(tasks, {
				group = groups.git,
				label = ('add (%d files)'):format(#files),
				action = function() pick_files(root, files) end,
			})
		end
		if #staged > 0 then
			table.insert(tasks, {
				group = groups.git,
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
