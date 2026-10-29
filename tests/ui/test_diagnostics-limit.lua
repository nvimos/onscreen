-- lua/genja/ext/diag-limit.lua: the first N diagnostics per severity and buffer are drawn.
-- Counts the extmarks nvim's own handlers draw (virtual text, signs). Fresh child per case.

local child = MiniTest.new_child_neovim()
local eq = MiniTest.expect.equality

local T = MiniTest.new_set({
	hooks = {
		pre_case = function()
			child.restart({ '-u', 'tests/minimal_init.lua' })
			child.lua([=[
				_G.L = require('genja.ext.diag-limit')
				L.setup()
				vim.diagnostic.config({ virtual_text = true, signs = true, underline = true })
				_G.buf = vim.api.nvim_get_current_buf()
				vim.api.nvim_buf_set_lines(buf, 0, -1, false, vim.split(string.rep('x\n', 30), '\n'))
				_G.ns_a = vim.api.nvim_create_namespace('test_a')
				_G.ns_b = vim.api.nvim_create_namespace('test_b')
				local E, W = vim.diagnostic.severity.ERROR, vim.diagnostic.severity.WARN
				-- ns_a: errors on lines 1-5, warnings on 10-13; ns_b: errors on 20-21
				_G.put = function()
					local a = {}
					for i = 0, 4 do table.insert(a, { lnum = i, col = 0, severity = E, message = 'a err ' .. i }) end
					for i = 9, 12 do table.insert(a, { lnum = i, col = 0, severity = W, message = 'a warn ' .. i }) end
					vim.diagnostic.set(ns_a, buf, a)
					vim.diagnostic.set(ns_b, buf, {
						{ lnum = 19, col = 0, severity = E, message = 'b err 19' },
						{ lnum = 20, col = 0, severity = E, message = 'b err 20' },
					})
				end
				-- drawn lines (0-based) with virtual text / with a sign
				_G.drawn = function(kind)
					local lines = {}
					for _, m in ipairs(vim.api.nvim_buf_get_extmarks(buf, -1, 0, -1, { details = true })) do
						local d = m[4]
						if (kind == 'virt' and d.virt_text) or (kind == 'sign' and d.sign_text) then
							lines[m[2]] = true
						end
					end
					local out = vim.tbl_keys(lines)
					table.sort(out)
					return out
				end
			]=])
		end,
		post_once = child.stop,
	},
})

T['default 3 per severity over all namespaces: virtual text'] = function()
	child.lua([[put()]])
	-- errors 0,1,2 (ns_b's 19, 20 are errors 6 and 7), warnings 9,10,11
	eq(child.lua([[return drawn('virt')]]), { 0, 1, 2, 9, 10, 11 })
	eq(child.lua([[return L.hidden(buf)]]), 5)
end

T['signs are cut the same way'] = function()
	child.lua([[put()]])
	eq(child.lua([[return drawn('sign')]]), { 0, 1, 2, 9, 10, 11 })
end

T['the data is not cut: vim.diagnostic.get keeps all'] = function()
	child.lua([[put()]])
	eq(child.lua([[return #vim.diagnostic.get(buf)]]), 11)
end

T['limit 2 (zen z1)'] = function()
	child.lua([[put(); L.set(2)]])
	eq(child.lua([[return drawn('virt')]]), { 0, 1, 9, 10 })
end

T['limit 0: all drawn'] = function()
	child.lua([[put(); L.set(0)]])
	eq(#child.lua([[return drawn('virt')]]), 11)
	eq(child.lua([[return L.hidden(buf)]]), 0)
end

T['show_all: this buffer only'] = function()
	child.lua([[
		put()
		_G.other = vim.api.nvim_create_buf(true, false)
		vim.api.nvim_buf_set_lines(other, 0, -1, false, vim.split(string.rep('y\n', 10), '\n'))
		local E = vim.diagnostic.severity.ERROR
		local d = {}
		for i = 0, 5 do table.insert(d, { lnum = i, col = 0, severity = E, message = 'o ' .. i }) end
		vim.diagnostic.set(ns_a, other, d)
		L.show_all(buf)
	]])
	eq(#child.lua([[return drawn('virt')]]), 11)
	eq(child.lua([[return L.hidden(other)]]), 3)
end

T['toggle: off, then on again'] = function()
	child.lua([[put(); L.toggle()]])
	eq(#child.lua([[return drawn('virt')]]), 11)
	child.lua([[L.toggle()]])
	eq(child.lua([[return drawn('virt')]]), { 0, 1, 2, 9, 10, 11 })
end

T['F2 source: show all while some are hidden, then hide excess'] = function()
	child.lua([[put()]])
	local labels = child.lua([[
		local out
		require('genja.f2.collect.diag').collect({ bufnr = buf, dir = '.', filetype = '' }, function(t) out = t end)
		return vim.tbl_map(function(t) return t.group .. ': ' .. t.label end, out)
	]])
	eq(labels, { 'diag: show all (5 hidden)' })
	child.lua([[L.show_all(buf)]])
	eq(child.lua([[
		local out
		require('genja.f2.collect.diag').collect({ bufnr = buf, dir = '.', filetype = '' }, function(t) out = t end)
		return vim.tbl_map(function(t) return t.label end, out)
	]]), { 'hide excess (5 over 3 per severity)' })
end

T['F2 hide excess: the global limit applies again, the item goes away'] = function()
	child.lua([[put()]])
	child.lua([[L.show_all(buf)]])
	eq(#child.lua([[return drawn('virt')]]), 11)
	child.lua([[
		local out
		require('genja.f2.collect.diag').collect({ bufnr = buf, dir = '.', filetype = '' }, function(t) out = t end)
		out[1].action()
	]])
	eq(child.lua([[return drawn('virt')]]), { 0, 1, 2, 9, 10, 11 })
	eq(child.lua([[return vim.b[buf].diag_limit]]), vim.NIL)
	eq(child.lua([[
		local out
		require('genja.f2.collect.diag').collect({ bufnr = buf, dir = '.', filetype = '' }, function(t) out = t end)
		return vim.tbl_map(function(t) return t.label end, out)
	]]), { 'show all (5 hidden)' })
end

return T
