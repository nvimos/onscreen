-- :Unsaved {cmd}: handle the modified buffers that block :qa (E37/E162), then run {cmd}.
-- A telescope picker lists them; each action closes it and it reopens with what's left,
-- so {cmd} runs once the list is empty. <Esc> cancels {cmd}. Command: plugin/unsaved.lua;
-- the `qa`, `q`, `x`, `jj` and `s:` abbreviations call it (lua/genja/abbreviations.vim).
-- :q and :x only quit nvim from the last window; elsewhere they run at once.
--   file buffer      <M-w> write          <M-x> reset to the file on disk (:edit!)
--   no-file buffer   <M-w> :w ~/tmp/bufw-<week>-<first-3-words>.txt on the cmdline, to edit
--                    <M-x> wipe the buffer
local SRC = 'lua/genja/ext/unsaved.lua: '

local M = {}

---Modified buffers that :qa refuses to drop.
---@return integer[]
local function blocking()
	local bufs = {}
	for _, buf in ipairs(vim.api.nvim_list_bufs()) do
		local bt = vim.bo[buf].buftype
		if vim.api.nvim_buf_is_loaded(buf) and vim.bo[buf].modified and (bt == '' or bt == 'acwrite') then
			table.insert(bufs, buf)
		end
	end
	return bufs
end

---First three word-like blobs of the buffer, ASCII only, joined by '-'.
---@param buf integer
---@return string
function M.first_words(buf)
	local text = table.concat(vim.api.nvim_buf_get_lines(buf, 0, 50, false), ' ')
	text = text:gsub('[\128-\255]', '')
	local words = {}
	for w in text:gmatch('[%w_]+') do
		table.insert(words, w)
		if #words == 3 then
			break
		end
	end
	if #words == 0 then
		return 'buffer'
	end
	local name = table.concat(words, '-'):gsub('%-+', '-')
	return name
end

---~/tmp/bufw-<ISO week>-<first-3-words>.txt
---@param buf integer
---@return string
function M.save_path(buf)
	return '~/tmp/bufw-' .. os.date('%V') .. '-' .. M.first_words(buf) .. '.txt'
end

---@param cmd string
local function finish(cmd)
	if cmd ~= '' then
		vim.cmd(cmd)
	end
end

---@param buf integer
---@return boolean
local function has_file(buf)
	return vim.api.nvim_buf_get_name(buf) ~= ''
end

---@param buf integer
---@return string
local function label(buf)
	if has_file(buf) then
		return vim.fn.fnamemodify(vim.api.nvim_buf_get_name(buf), ':~:.')
	end
	return '[No Name ' .. buf .. '] ' .. M.first_words(buf)
end

---<M-w> on a no-file buffer: show it, put :w <path> on the cmdline; reopen after the write.
---@param buf integer
---@param cmd string
local function write_nofile(buf, cmd)
	vim.fn.mkdir(vim.fn.expand('~/tmp'), 'p')
	vim.api.nvim_set_current_buf(buf)
	vim.api.nvim_create_autocmd('BufWritePost', {
		buffer = buf,
		once = true,
		callback = function() vim.schedule(function() M.run(cmd) end) end,
	})
	vim.api.nvim_feedkeys(':w ' .. M.save_path(buf), 'n', false)
end

---The Vim error of a failed vim.cmd, without the Lua traceback.
---@param err any
---@return string
local function short_error(err)
	local text = tostring(err)
	return text:match('(E%d+:[^\n]*)') or text
end

---@param buf integer
---@param bang boolean
---@return boolean ok
---@return any err
local function write_buf(buf, bang)
	return pcall(vim.api.nvim_buf_call, buf, function() vim.cmd.write({ bang = bang }) end)
end

---Write; on E13 (a file is on disk the buffer never read) ask before overwriting it.
---@param buf integer
local function write_file(buf)
	local ok, err = write_buf(buf, false)
	if not ok and short_error(err):match('^E13:') then
		local name = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(buf), ':~:.')
		if vim.fn.confirm(name .. ' exists on disk and was not read into this buffer. Overwrite it?', '&Yes\n&No', 2) ~= 1 then
			return
		end
		ok, err = write_buf(buf, true)
	end
	if not ok then
		vim.notify(SRC .. 'write failed: ' .. short_error(err), vim.log.levels.ERROR)
	end
end

---@param buf integer
local function discard(buf)
	if has_file(buf) then
		local ok, err = pcall(vim.api.nvim_buf_call, buf, function() vim.cmd('edit!') end)
		if not ok then
			vim.notify(SRC .. 'reset failed: ' .. short_error(err), vim.log.levels.ERROR)
		end
	else
		vim.api.nvim_buf_delete(buf, { force = true })
	end
end

-- :q and :x close a window; they quit nvim (and hit E37/E162) only from the last one
local QUIT_WINDOW = { q = true, quit = true }
-- :x writes the current buffer itself, so it isn't asked about
local WRITE_QUIT = { x = true, xit = true, exit = true }

---Only one non-floating window and one tab: closing it quits nvim.
---@return boolean
local function last_window()
	if vim.fn.tabpagenr('$') > 1 then
		return false
	end
	local count = 0
	for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
		if vim.api.nvim_win_get_config(win).relative == '' then
			count = count + 1
		end
	end
	return count <= 1
end

---`bufs` without the current buffer when it has a file name (:x writes that one).
---@param bufs integer[]
---@return integer[]
local function without_current_file(bufs)
	local cur = vim.api.nvim_get_current_buf()
	if not has_file(cur) then
		return bufs
	end
	return vim.tbl_filter(function(buf) return buf ~= cur end, bufs)
end

---Rows the key help (lua/genja/ext/telescope-virthelp.lua) needs: the config's insert maps
---that aren't telescope defaults, plus <M-w> and <M-x>. A rough count; a little too many is fine.
---@return integer
local function help_rows()
	local mine = require('telescope.config').values.mappings.i or {}
	local defaults = require('telescope.mappings').default_mappings.i or {}
	local n = 2
	for lhs in pairs(mine) do
		if not defaults[lhs] then
			n = n + 1
		end
	end
	return n
end

---Run `cmd` now, or after the picker has dealt with every blocking buffer.
---A command ending in '!' (qa!) runs at once: it means "drop them".
---@param cmd? string
function M.run(cmd)
	cmd = vim.trim(cmd or '')
	local word = cmd:match('^%a+') or ''
	local closes_window = (QUIT_WINDOW[word] or WRITE_QUIT[word]) and true or false
	if cmd:match('^%a+!') or (closes_window and not last_window()) then
		finish(cmd)
		return
	end
	local bufs = blocking()
	if WRITE_QUIT[word] then
		bufs = without_current_file(bufs)
	end
	if #bufs == 0 then
		finish(cmd)
		return
	end

	local actions = require('telescope.actions')
	local action_state = require('telescope.actions.state')

	---Close the picker, apply `fn` to the selected buffer, reopen with the rest.
	---@param bufnr integer picker prompt buffer
	---@param fn fun(buf: integer)
	local function act(bufnr, fn)
		local entry = action_state.get_selected_entry()
		actions.close(bufnr)
		if entry then
			fn(entry.value)
		end
		vim.schedule(function() M.run(cmd) end)
	end

	-- own layout: the global default is full screen, vertical, preview hidden below 40 lines;
	-- tall enough for the key help (header, rows, prompt, borders)
	local height = help_rows() + 14
	require('telescope.pickers').new({}, {
		layout_strategy = 'horizontal',
		layout_config = {
			width = 0.7,
			height = function(_, _, max_lines) return math.min(max_lines, height) end,
			preview_width = 0.55,
			preview_cutoff = 1,
			prompt_position = 'top',
			mirror = false,
		},
		sorting_strategy = 'ascending',
		prompt_title = 'Unsaved: <M-w> write <M-x> discard',
		finder = require('telescope.finders').new_table({
			results = bufs,
			entry_maker = function(buf)
				local display = label(buf)
				return { value = buf, display = display, ordinal = display }
			end,
		}),
		sorter = require('telescope.config').values.generic_sorter({}),
		previewer = require('telescope.previewers').new_buffer_previewer({
			title = 'Unsaved buffer',
			define_preview = function(self, entry)
				local lines = vim.api.nvim_buf_get_lines(entry.value, 0, 200, false)
				vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, lines)
				vim.bo[self.state.bufnr].filetype = vim.bo[entry.value].filetype
			end,
		}),
		attach_mappings = function(bufnr, map)
			vim.b[bufnr].telescope_hint = '…' -- keys are in the title and the key help
			actions.select_default:replace(function()
				local entry = action_state.get_selected_entry()
				actions.close(bufnr)
				if entry then
					vim.api.nvim_set_current_buf(entry.value)
				end
			end)
			map({ 'i', 'n' }, '<M-w>', function()
				local entry = action_state.get_selected_entry()
				if entry and not has_file(entry.value) then
					actions.close(bufnr)
					vim.schedule(function() write_nofile(entry.value, cmd) end)
					return
				end
				act(bufnr, write_file)
			end, { desc = 'Unsaved: write' })
			map({ 'i', 'n' }, '<M-x>', function() act(bufnr, discard) end, { desc = 'Unsaved: discard (reset or wipe)' })
			return true
		end,
	}):find()
end

return M
