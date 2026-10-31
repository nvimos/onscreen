-- gq on markdown list items (after/ftplugin/markdown.vim: formatlistpat, 'comments' without
-- the fb:- leaders): wrapped lines line up under the item's text. One kind of item per case.
-- Fresh child nvim per case, the real ftplugin, textwidth 40.

local child = MiniTest.new_child_neovim()
local eq = MiniTest.expect.equality

local WORDS = string.rep('word ', 20)

local T = MiniTest.new_set({
	hooks = {
		pre_case = function()
			child.restart({ '-u', 'tests/minimal_init.lua' })
			child.lua([[
				vim.opt.rtp:append(vim.fn.stdpath('config') .. '/after')
				vim.cmd('filetype plugin on')
				_G.tmp = vim.fs.normalize(vim.fn.tempname())
				vim.fn.mkdir(tmp, 'p')
				-- gq on line 1 of a markdown file holding `line`; returns the buffer lines
				_G.wrap = function(line)
					local f = tmp .. '/w.md'
					vim.fn.writefile({ line }, f)
					vim.cmd('edit ' .. f)
					vim.bo.textwidth = 40
					vim.cmd('normal! gqq')
					return vim.api.nvim_buf_get_lines(0, 0, -1, false)
				end
			]])
		end,
		post_once = child.stop,
	},
})

---Leading spaces of every line after the first.
---@param lines string[]
---@return integer[]
local function rest_indents(lines)
	local out = {}
	for i = 2, #lines do
		table.insert(out, #lines[i]:match('^ *'))
	end
	return out
end

---Every wrapped line is indented `n`; at least one line wrapped.
---@param lines string[]
---@param n integer
local function all_indented(lines, n)
	local indents = rest_indents(lines)
	eq(#indents > 0, true)
	for _, got in ipairs(indents) do
		eq(got, n)
	end
end

T['wrap: - [ ] item, under the text after the checkbox'] = function()
	all_indented(child.lua('return wrap(...)', { '- [ ] ' .. WORDS }), 6)
end

T['wrap: - [x] item, under the text after the checkbox'] = function()
	all_indented(child.lua('return wrap(...)', { '- [x] ' .. WORDS }), 6)
end

T['wrap: * [ ] item, under the text after the checkbox'] = function()
	all_indented(child.lua('return wrap(...)', { '* [ ] ' .. WORDS }), 6)
end

T['wrap: nested - [ ] item, under its own text'] = function()
	all_indented(child.lua('return wrap(...)', { '  - [ ] ' .. WORDS }), 8)
end

T['wrap: 1. [x] item, under the text after the checkbox'] = function()
	all_indented(child.lua('return wrap(...)', { '1. [x] ' .. WORDS }), 7)
end

T['wrap: plain - item, under the text after the bullet'] = function()
	all_indented(child.lua('return wrap(...)', { '- ' .. WORDS }), 2)
end

T['wrap: 1. item, under the text after the number'] = function()
	all_indented(child.lua('return wrap(...)', { '1. ' .. WORDS }), 3)
end

T['wrap: > quote, every wrapped line starts with > '] = function()
	local lines = child.lua('return wrap(...)', { '> ' .. WORDS })
	eq(#lines > 1, true)
	for _, line in ipairs(lines) do
		eq(line:sub(1, 2), '> ')
	end
end

return T
