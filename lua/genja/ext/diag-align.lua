-- Diagnostic virtual text starts in one column per paragraph (lines between blank lines):
-- right after the paragraph's longest line, instead of after each line's own end.
-- Wraps the built-in virtual_text handler, then moves its extmarks to virt_text_win_col.
--   vim.g.diag_align   false: plain end-of-line placement
--   M.toggle()         switch it and move the marks of every buffer (<leader>tta, <F2> diag)
-- Setup: plugin/diag-align.lua. Works under the diag limit wrapper (lua/genja/ext/diag-limit.lua).
--
-- A paragraph whose longest line is wider than the window keeps end-of-line placement:
-- a fixed column past the window edge would hide the text.
-- Edits move the marks with the text but not the column; the next diagnostics refresh fixes it.

local SRC = 'lua/genja/ext/diag-align.lua: '

local M = {}

---Whether `row` of `lines` is blank (only whitespace).
---@param lines string[]
---@param row integer 0-based
---@return boolean
local function blank(lines, row)
	return lines[row + 1]:match('^%s*$') ~= nil
end

---First and last row (0-based) of the paragraph around `row`.
---@param lines string[]
---@param row integer
---@return integer first, integer last
local function paragraph(lines, row)
	local first = row
	while first > 0 and not blank(lines, first - 1) do
		first = first - 1
	end
	local last = row
	while last + 1 < #lines and not blank(lines, last + 1) do
		last = last + 1
	end
	return first, last
end

---Display width of the widest line in rows first..last, with the buffer's tabstop.
---@param bufnr integer
---@param lines string[]
---@param first integer
---@param last integer
---@return integer
local function widest(bufnr, lines, first, last)
	local width = 0
	vim.api.nvim_buf_call(bufnr, function()
		for row = first, last do
			width = math.max(width, vim.fn.strdisplaywidth(lines[row + 1]))
		end
	end)
	return width
end

---Text columns of a window that shows `bufnr` (the current one if none does).
---@param bufnr integer
---@return integer
local function text_width(bufnr)
	local winid = vim.fn.bufwinid(bufnr)
	if winid == -1 then
		winid = vim.api.nvim_get_current_win()
	end
	local info = vim.fn.getwininfo(winid)[1]
	return info.width - info.textoff
end

---Display width of virt_text chunks.
---@param chunks table[] { text, hl } pairs
---@return integer
local function chunks_width(chunks)
	local width = 0
	for _, chunk in ipairs(chunks) do
		width = width + vim.fn.strdisplaywidth(chunk[1])
	end
	return width
end

---Virtual text namespaces of all diagnostic namespaces, in namespace id order.
---@return integer[]
local function virt_text_namespaces()
	local namespaces = vim.diagnostic.get_namespaces()
	local ids = {}
	for id, ns in pairs(namespaces) do
		if ns.user_data and ns.user_data.virt_text_ns then
			table.insert(ids, id)
		end
	end
	table.sort(ids)
	local out = {}
	for _, id in ipairs(ids) do
		table.insert(out, namespaces[id].user_data.virt_text_ns)
	end
	return out
end

---Move every diagnostic virtual text mark of `bufnr` to its paragraph's column.
---Several namespaces on one line sit side by side, in namespace order.
---@param bufnr integer
function M.align(bufnr)
	if not vim.api.nvim_buf_is_loaded(bufnr) then
		return
	end
	local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
	local max_col = text_width(bufnr)
	local col_of_para = {} -- first row -> column, or false: keep end of line
	local used_on_row = {} -- row -> cells taken by marks already placed there

	for _, vt_ns in ipairs(virt_text_namespaces()) do
		local marks = vim.api.nvim_buf_get_extmarks(bufnr, vt_ns, 0, -1, { details = true })
		for _, mark in ipairs(marks) do
			local id, row, details = mark[1], mark[2], mark[4]
			-- Only marks the handler placed at the line end (or that this function moved).
			local movable = details.virt_text and row < #lines
				and (details.virt_text_pos == 'eol' or details.virt_text_win_col ~= nil)
			if movable then
				local first, last = paragraph(lines, row)
				if col_of_para[first] == nil then
					local width = widest(bufnr, lines, first, last)
					if width < max_col then
						col_of_para[first] = width
					else
						col_of_para[first] = false
					end
				end

				local new = {
					id = id,
					virt_text = details.virt_text,
					hl_mode = details.hl_mode,
					virt_text_hide = details.virt_text_hide,
					priority = details.priority,
				}
				local base = col_of_para[first]
				if base and vim.g.diag_align ~= false then
					local used = used_on_row[row] or 0
					new.virt_text_win_col = base + used
					used_on_row[row] = used + chunks_width(details.virt_text)
				else
					new.virt_text_pos = 'eol'
				end
				vim.api.nvim_buf_set_extmark(bufnr, vt_ns, row, 0, new)
			end
		end
	end
end

---Is alignment on?
---@return boolean
function M.enabled()
	return vim.g.diag_align ~= false
end

---Switch alignment on/off and move the existing marks of every loaded buffer;
---no diagnostics refresh is needed (align() also moves aligned marks back to eol).
function M.toggle()
	vim.g.diag_align = not M.enabled()
	for _, buf in ipairs(vim.api.nvim_list_bufs()) do
		M.align(buf)
	end
	if M.enabled() then
		vim.notify(SRC .. 'one column per paragraph')
	else
		vim.notify(SRC .. 'at the end of each line')
	end
end

---Wrap the virtual_text handler once: show as usual, then align the buffer.
function M.setup()
	local orig = vim.diagnostic.handlers.virtual_text
	if not orig or orig.genja_aligned then
		return
	end
	vim.diagnostic.handlers.virtual_text = {
		genja_aligned = true,
		show = function(namespace, bufnr, diagnostics, opts)
			orig.show(namespace, bufnr, diagnostics, opts)
			if bufnr == 0 then
				bufnr = vim.api.nvim_get_current_buf()
			end
			M.align(bufnr)
		end,
		hide = orig.hide,
	}
end

return M
