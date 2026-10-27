-- blink.cmp in the real config: the sources of genja-completion011 (dictionary, gitignore,
-- sshconfig, gitcommit), the cmdline, <CR> and the ask popup. `make test D=completion` in tests/.
local child = MiniTest.new_child_neovim()
local config = vim.fn.stdpath('config')
local T = MiniTest.new_set({
	hooks = {
		pre_once = function()
			child.restart({
				'--cmd', 'set rtp^=' .. config .. ' rtp+=' .. config .. '/after',
				'--cmd', 'let g:genja_lsp_no_install = v:true',
				'-u', config .. '/init.vim',
			})
			child.lua([[vim.api.nvim_exec_autocmds('UIEnter', {})]])
			vim.wait(5000, function() return child.lua('return vim.g.did_very_lazy == true') end, 50)
			child.lua([[require('blink.cmp')]])
		end,
		post_once = function() child.stop() end,
	},
})

---Show `provider` and wait for items; returns labels (and the first item's textEdit text).
local function labels(provider)
	child.lua(([[require('blink.cmp').hide(); require('blink.cmp').show({ providers = { %q } })]]):format(provider))
	local got = {}
	vim.wait(4000, function()
		got = child.lua([[
			local out = {}
			for _, item in ipairs(require('blink.cmp').get_items() or {}) do
				table.insert(out, item.source_id .. ':' .. item.label)
			end
			return out
		]])
		return #got > 0
	end, 100)
	return got
end

local function has(list, want)
	return vim.tbl_contains(list, want), vim.inspect(vim.list_slice(list, 1, 12))
end

local function scratch(ft, line)
	local dir = vim.fs.normalize(vim.fn.tempname())
	vim.fn.mkdir(dir .. '/abcdir', 'p')
	child.cmd('enew!')
	child.cmd('noautocmd file ' .. vim.fn.fnameescape(dir .. '/x.' .. ft))
	child.lua('vim.bo.filetype = ...', { ft })
	child.lua('vim.api.nvim_buf_set_lines(0, 0, -1, false, { ... })', { '' })
	child.type_keys('i', line)
end

T['dictionary in markdown'] = function()
	scratch('markdown', 'the Hou')
	local ok, shown = has(labels('dictionary'), 'dictionary:Hour')
	child.type_keys('<Esc>')
	MiniTest.expect.equality(ok, true, shown)
end

T['<CR> accepts the preselected item'] = function()
	scratch('markdown', 'the Hou')
	labels('dictionary')
	child.type_keys('<CR>')
	local line = child.lua('return vim.api.nvim_get_current_line()')
	child.type_keys('<Esc>')
	MiniTest.expect.equality(line:match('^the Hou%a+$') ~= nil, true, line)
end

T['gitignore dir names'] = function()
	scratch('gitignore', 'ab')
	local ok, shown = has(labels('gitignore'), 'gitignore:abcdir/')
	child.type_keys('<Esc>')
	MiniTest.expect.equality(ok, true, shown)
end

T['sshconfig values replace the whole value'] = function()
	scratch('sshconfig', 'StrictHostKeyChecking acc')
	local ok, shown = has(labels('sshconfig'), 'sshconfig:accept-new')
	child.type_keys('<CR>')
	local line = child.lua('return vim.api.nvim_get_current_line()')
	child.type_keys('<Esc>')
	MiniTest.expect.equality(ok, true, shown)
	MiniTest.expect.equality(line, 'StrictHostKeyChecking accept-new')
end

T['sshconfig keywords'] = function()
	scratch('sshconfig', 'Strict')
	local ok, shown = has(labels('sshconfig'), 'sshconfig:StrictHostKeyChecking')
	child.type_keys('<Esc>')
	MiniTest.expect.equality(ok, true, shown)
end

T['gitcommit types with conventional mode'] = function()
	scratch('gitcommit', '')
	child.lua('vim.b.genja_commit_conventional = true')
	child.type_keys('fe')
	local ok, shown = has(labels('gitcommit'), 'gitcommit:feat')
	child.type_keys('<Esc>')
	MiniTest.expect.equality(ok, true, shown)
end

T['gitcommit off without conventional mode'] = function()
	scratch('gitcommit', 'fe')
	child.lua('vim.b.genja_commit_conventional = false')
	local got = labels('gitcommit')
	child.type_keys('<Esc>')
	MiniTest.expect.equality(#got, 0, vim.inspect(got))
end

T['cmdline : commands'] = function()
	child.type_keys(':', 'echoh')
	local got = {}
	vim.wait(4000, function()
		got = child.lua([[
			local out = {}
			for _, item in ipairs(require('blink.cmp').get_items() or {}) do table.insert(out, item.label) end
			return out
		]])
		return #got > 0
	end, 100)
	child.type_keys('<Esc>')
	MiniTest.expect.equality(vim.tbl_contains(got, 'echohl'), true, vim.inspect(vim.list_slice(got, 1, 10)))
end

T['ask popup has completion off'] = function()
	child.lua([[require('genja-ask').open()]])
	local off = child.lua('return vim.b.completion')
	child.type_keys('<Esc>', 'q')
	MiniTest.expect.equality(off, false)
end

return T
