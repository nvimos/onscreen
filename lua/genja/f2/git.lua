-- <F2> source, group `git`, oil buffers only. For the repo around oil's dir:
--   add (N files)  sub-picker over the changed files (git status codes,
--                  repo-relative paths), diff preview (hidden at start), <Tab> marks,
--                  <CR> git add, <C-p> toggles the preview, <M-t> tabedit (picker stays), <M-e> edit

local M = {}

local src = 'lua/genja/f2/git.lua: '

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
	vim.system(cmd, { cwd = root, text = true }, vim.schedule_wrap(function(res)
		if res.code ~= 0 then
			vim.notify(src .. 'git add failed:\n' .. (res.stderr or ''), vim.log.levels.ERROR)
		elseif res.stderr and res.stderr ~= '' then
			vim.notify(src .. res.stderr, vim.log.levels.WARN) -- e.g. CRLF warnings
		end
		-- oil-git refreshed on picker close, before git add finished
		if vim.bo.filetype == 'oil' then
			require('genja.oil.git').refresh_oil_git()
		end
	end))
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
	-- preview_cutoff 1: the vertical layout's default (40 lines) hid the diff in
	-- short windows, and <C-p> can't override it. Strategy key wins over top level.
	local picker_opts = {
		sorting_strategy = 'ascending',
		layout_config = { vertical = { preview_cutoff = 1 } },
		preview = { hide_on_startup = true }, -- <C-p> shows it
	}
	require('telescope.pickers').new(picker_opts, {
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
		attach_mappings = function(bufnr, map)
			-- marked paths, else the one under the cursor
			local function selected_paths()
				local picker = action_state.get_current_picker(bufnr)
				local selected = picker:get_multi_selection()
				if #selected == 0 then
					selected = { action_state.get_selected_entry() }
				end
				local paths = {}
				for _, entry in ipairs(selected) do
					table.insert(paths, entry.value.path)
				end
				return paths
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
					vim.notify('lua/genja/f2/git.lua: tabedit failed: ' .. tostring(err), vim.log.levels.ERROR)
				end
			end
			require('genja.fn.telemap').Telemap(map)
			-- same key as oil's preview toggle
			map({ 'i', 'n' }, '<C-p>', require('telescope.actions.layout').toggle_preview, { desc = 'f2 git: toggle preview' })
			map({ 'i', 'n' }, '<M-t>', tabedit_selected, { desc = 'f2 git: open selected in tabs, keep the picker' })
			map({ 'i', 'n' }, '<M-e>', edit_selected, { desc = 'f2 git: edit selected' })
			actions.select_default:replace(function()
				local paths = take_paths()
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
