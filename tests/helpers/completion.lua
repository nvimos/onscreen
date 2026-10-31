-- Helpers for the blink.cmp tests in tests/completion/: a child with the real config, a
-- scratch buffer in a temp dir, and reads of blink's state in the child.
--   local C = require('helpers.completion').new(child)
--   C.boot()                        -- in pre_once
--   local dir = C.scratch('markdown', 'the Hou')   -- typed in insert mode
--   C.labels('dictionary')          -- { 'dictionary:Hour', ... } after a forced show
local H = require('helpers.timing')

local M = {}

---@param child table MiniTest.new_child_neovim()
function M.new(child)
	local C = {}

	function C.boot()
		dofile(vim.fn.stdpath('config') .. '/tests/helpers/real-config.lua').boot_child(child)
		child.lua([[require('blink.cmp')]])
	end

	---New buffer `x.<ext>` with filetype `ft` in a fresh temp dir (with a subdir `abcdir/`),
	---`lines` in it, then insert mode at the end of the last line and `typed` typed.
	---@param ft string
	---@param typed? string
	---@param lines? string[]
	---@return string dir
	function C.scratch(ft, typed, lines)
		local dir = vim.fs.normalize(vim.fn.tempname())
		vim.fn.mkdir(dir .. '/abcdir/inner', 'p')
		child.cmd('enew!')
		child.cmd('noautocmd file ' .. vim.fn.fnameescape(dir .. '/x.' .. ft))
		child.lua('vim.bo.filetype = ...', { ft })
		child.lua('vim.api.nvim_buf_set_lines(0, 0, -1, false, ...)', { lines or { '' } })
		child.lua('vim.api.nvim_win_set_cursor(0, { vim.api.nvim_buf_line_count(0), 0 })')
		child.type_keys('A', typed or '')
		return dir
	end

	---Leave insert or command-line mode.
	function C.esc()
		child.type_keys('<Esc>')
	end

	---`source_id:label` of blink's items now.
	---@return string[]
	function C.items()
		return child.lua([[
			local out = {}
			for _, item in ipairs(require('blink.cmp').get_items() or {}) do
				table.insert(out, item.source_id .. ':' .. item.label)
			end
			return out
		]])
	end

	---Wait for items. With `providers`: reopen the menu with those only first; without: the
	---menu as typing opened it (a forced show() of every source can come back empty).
	---@param providers? string|string[]
	---@return string[] items as C.items()
	function C.labels(providers)
		if type(providers) == 'string' then
			providers = { providers }
		end
		if providers then
			child.lua('local p = ...; require("blink.cmp").hide(); require("blink.cmp").show({ providers = p })', { providers })
		end
		local got = {}
		H.wait(function()
			got = C.items()
			return #got > 0
		end, 4000)
		return got
	end

	---Wait until the menu is open (true) or `timeout` ms pass (false).
	---@param timeout? integer default 3000
	---@return boolean
	function C.wait_menu(timeout)
		return H.wait(function() return child.lua('return require("blink.cmp").is_menu_visible()') end, timeout or 3000) == true
	end

	---@return string
	function C.line()
		return child.lua('return vim.api.nvim_get_current_line()')
	end

	---@return integer|nil
	function C.selected()
		local idx = child.lua('return require("blink.cmp").get_selected_item_idx()')
		-- nothing selected comes back over RPC as vim.NIL
		if idx == vim.NIL then
			return nil
		end
		return idx
	end

	return C
end

---Does `list` have `want`? Second value: the first items, for the failure message.
---@param list string[]
---@param want string
---@return boolean, string
function M.has(list, want)
	return vim.tbl_contains(list, want), vim.inspect(vim.list_slice(list, 1, 15))
end

---Does `list` have an item matching Lua pattern `pattern`?
---@param list string[]
---@param pattern string
---@return boolean, string
function M.has_match(list, pattern)
	for _, item in ipairs(list) do
		if item:match(pattern) then
			return true, ''
		end
	end
	return false, vim.inspect(vim.list_slice(list, 1, 15))
end

return M
