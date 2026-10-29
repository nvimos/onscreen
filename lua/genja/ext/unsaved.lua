-- :Unsaved {cmd}: handle the modified buffers that block :qa (E37/E162), then run {cmd}.
-- A telescope picker lists them; each action closes it and it reopens with what's left,
-- so {cmd} runs once the list is empty. <Esc> cancels {cmd}. Command: plugin/unsaved.lua;
-- the `qa` and `s:` abbreviations call it (lua/genja/abbreviations.vim).
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

---@param buf integer
local function write_file(buf)
	local ok, err = pcall(vim.api.nvim_buf_call, buf, function() vim.cmd('write') end)
	if not ok then
		vim.notify(SRC .. 'write failed: ' .. tostring(err), vim.log.levels.ERROR)
	end
end

---@param buf integer
local function discard(buf)
	if has_file(buf) then
		local ok, err = pcall(vim.api.nvim_buf_call, buf, function() vim.cmd('edit!') end)
		if not ok then
			vim.notify(SRC .. 'reset failed: ' .. tostring(err), vim.log.levels.ERROR)
		end
	else
		vim.api.nvim_buf_delete(buf, { force = true })
	end
end

---Run `cmd` now, or after the picker has dealt with every blocking buffer.
---A command ending in '!' (qa!) runs at once: it means "drop them".
---@param cmd? string
function M.run(cmd)
	cmd = vim.trim(cmd or '')
	local bufs = blocking()
	if #bufs == 0 or cmd:match('^%a+!') then
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

	local then_cmd = (cmd ~= '' and cmd or 'nothing')
	require('telescope.pickers').new({}, {
		prompt_title = 'Unsaved: <M-w> write, <M-x> discard; then: ' .. then_cmd:sub(1, 30),
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
