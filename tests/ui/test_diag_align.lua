-- lua/genja/ext/diag-align.lua: diagnostic virtual text in one column per paragraph, the
-- g:diag_align switch, M.toggle(), and its <F2> item (lua/genja/f2/collect/diag.lua).
-- One aspect per case; fresh child per case.

local C = require('helpers.child')
local eq = MiniTest.expect.equality

local child, T = C.fresh([=[
	_G.A = require('genja.ext.diag-align')
	A.setup()
	vim.diagnostic.config({ virtual_text = true })
	vim.notify = function() end
	_G.buf = vim.api.nvim_get_current_buf()
	-- paragraph 1: rows 0-2, widest 'a long line here' (16); paragraph 2: rows 4-5, widest 9
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, {
		'short', 'a long line here', 'mid line', '', 'para two', 'x 2345678',
	})
	_G.ns = vim.api.nvim_create_namespace('test_align')
	_G.put = function(rows)
		local list = {}
		for _, row in ipairs(rows) do
			table.insert(list, { lnum = row, col = 0, severity = vim.diagnostic.severity.WARN, message = 'w' .. row })
		end
		vim.diagnostic.set(ns, buf, list)
	end
	-- row -> { col = virt_text_win_col or false, pos = virt_text_pos } of the virtual text marks
	_G.marks = function()
		local out = {}
		for _, m in ipairs(vim.api.nvim_buf_get_extmarks(buf, -1, 0, -1, { details = true })) do
			local d = m[4]
			if d.virt_text then
				out[tostring(m[2])] = { col = d.virt_text_win_col or false, pos = d.virt_text_pos }
			end
		end
		return out
	end
]=], nil, { columns = 120 })

---Columns of the marks on `rows`.
---@param rows integer[]
---@return (integer|false)[]
local function cols(rows)
	local m = child.lua('return marks()')
	local out = {}
	for _, row in ipairs(rows) do
		table.insert(out, m[tostring(row)].col)
	end
	return out
end

T['align: marks in one paragraph share the column after its widest line'] = function()
	child.lua('put({ 0, 2 })')
	eq(cols({ 0, 2 }), { 16, 16 })
end

T['align: each paragraph gets its own column'] = function()
	child.lua('put({ 0, 4 })')
	eq(cols({ 0, 4 }), { 16, 9 })
end

T['align: g:diag_align false puts marks at the line end'] = function()
	child.lua('vim.g.diag_align = false; put({ 0, 2 })')
	local m = child.lua('return marks()')
	eq({ m['0'].col, m['0'].pos, m['2'].col, m['2'].pos }, { false, 'eol', false, 'eol' })
end

T['toggle: switches g:diag_align off, then on'] = function()
	eq(child.lua('A.toggle(); local a = vim.g.diag_align; A.toggle(); return { a, vim.g.diag_align }'), { false, true })
end

T['toggle: moves existing marks to the line end without new diagnostics'] = function()
	child.lua('put({ 0, 2 }); A.toggle()')
	eq(cols({ 0, 2 }), { false, false })
end

T['toggle: moves them back into the column when switched on again'] = function()
	child.lua('put({ 0, 2 }); A.toggle(); A.toggle()')
	eq(cols({ 0, 2 }), { 16, 16 })
end

T['key: <leader>tta moves the marks to the line end, again back into the column'] = function()
	child.lua([[
		vim.g.mapleader = ' '
		vim.cmd.runtime('plugin/diag-align.lua')
		put({ 0, 2 })
	]])
	child.type_keys(' tta')
	eq(cols({ 0, 2 }), { false, false })
	child.type_keys(' tta')
	eq(cols({ 0, 2 }), { 16, 16 })
end

T['f2: the align item moves the marks'] = function()
	child.lua([[
		put({ 0, 2 })
		require('genja.f2.collect.diag').collect({ bufnr = buf }, function(items)
			for _, item in ipairs(items) do
				if item.label:match('^align: ') then
					item.action()
				end
			end
		end)
	]])
	eq(cols({ 0, 2 }), { false, false })
end

T['f2: no align item without diagnostics'] = function()
	eq(child.lua([[
		local got
		require('genja.f2.collect.diag').collect({ bufnr = buf }, function(items) got = items end)
		return vim.tbl_map(function(i) return i.label end, got)
	]]), {})
end

T['f2: align item names the other placement, and switches it'] = function()
	eq(child.lua([[
		put({ 0 })
		local function label()
			local got
			require('genja.f2.collect.diag').collect({ bufnr = buf }, function(items) got = items end)
			for _, item in ipairs(got) do
				if item.label:match('^align: ') then
					return item
				end
			end
		end
		local first = label()
		first.action()
		return { first.label, label().label, vim.g.diag_align }
	]]), { 'align: at the end of each line', 'align: one column per paragraph', false })
end

return T
