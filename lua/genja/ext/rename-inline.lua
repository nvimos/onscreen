-- LSP rename typed in place: a one-line float over the word under the cursor, in insert mode.
-- Completion stays on in the float; confirming always renames.
local SRC = 'lua/genja/ext/rename-inline.lua: '

local M = {}

local MIN_WIDTH = 10

---Close the float and leave insert mode; safe to call twice.
---@param win integer
local function close(win)
	vim.cmd.stopinsert()
	if vim.api.nvim_win_is_valid(win) then
		vim.api.nvim_win_close(win, true)
	end
end

---Rename the symbol under the cursor, typing the new name over the old one.
function M.rename()
	local old = vim.fn.expand('<cword>')
	if old == '' then
		vim.notify(SRC .. 'no word under the cursor', vim.log.levels.WARN)
		return
	end

	-- Start column of the word: the float covers it exactly.
	local cursor_col = vim.fn.col('.')
	local start_col = vim.fn.searchpos('\\<', 'bcn', vim.fn.line('.'))[2]
	if start_col == 0 or start_col > cursor_col then
		start_col = cursor_col
	end

	local buf = vim.api.nvim_create_buf(false, true)
	vim.bo[buf].bufhidden = 'wipe'
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, { old })

	local win = vim.api.nvim_open_win(buf, true, {
		relative = 'cursor',
		row = 0,
		col = start_col - cursor_col,
		width = math.max(vim.fn.strdisplaywidth(old) + 1, MIN_WIDTH),
		height = 1,
		style = 'minimal',
		border = 'none',
	})
	vim.wo[win].winhighlight = 'Normal:Visual'
	vim.cmd.startinsert({ bang = true })

	local function accept()
		local new = vim.trim(vim.api.nvim_buf_get_lines(buf, 0, 1, false)[1] or '')
		close(win)
		if new ~= '' and new ~= old then
			-- Back in the source window, cursor unchanged: rename acts on the original word.
			vim.lsp.buf.rename(new)
		end
	end

	local function cancel() close(win) end

	---<C-j>: take the completion item, if the blink menu is open.
	local function accept_completion()
		local ok, blink = pcall(require, 'blink.cmp')
		if ok and blink.is_menu_visible() then
			blink.accept()
		end
	end

	---<CR> renames even with the menu open.
	local function accept_rename()
		local ok, blink = pcall(require, 'blink.cmp')
		if ok and blink.is_menu_visible() then
			blink.hide()
		end
		accept()
	end

	local o = { buffer = buf, nowait = true }

	-- blink maps <CR> on this buffer at InsertEnter (once); set ours after it so they win.
	local function insert_keys()
		if not vim.api.nvim_buf_is_valid(buf) then
			return
		end
		vim.keymap.set('i', '<CR>', accept_rename, o)
		vim.keymap.set('i', '<C-j>', accept_completion, o)
	end
	insert_keys()
	vim.api.nvim_create_autocmd('InsertEnter', {
		buffer = buf,
		callback = function() vim.schedule(insert_keys) end,
	})

	vim.keymap.set('n', '<CR>', accept, o)
	vim.keymap.set('n', '<Esc>', cancel, o)
	vim.keymap.set('n', 'q', cancel, o)
	vim.keymap.set('i', '<C-c>', cancel, o)

	-- Grow with the text; close when focus moves elsewhere.
	vim.api.nvim_create_autocmd({ 'TextChanged', 'TextChangedI' }, {
		buffer = buf,
		callback = function()
			local text = vim.api.nvim_buf_get_lines(buf, 0, 1, false)[1] or ''
			vim.api.nvim_win_set_config(win, { width = math.max(vim.fn.strdisplaywidth(text) + 1, MIN_WIDTH) })
		end,
	})
	vim.api.nvim_create_autocmd('WinLeave', {
		buffer = buf,
		once = true,
		callback = function() vim.schedule(function() close(win) end) end,
	})
end

return M
