-- The setup most test files share, so a test file shows its cases, not the plumbing.
--
--   local C = require('helpers.child')
--   local child, T = C.fresh([[
--       _G.F = require('genja.ext.md-fix')
--   ]] .. C.TMP .. C.NOTES)
--
--   T['missing tools are left out'] = function()
--       eq(C.eval(child, 'F.commands(tmp .. "/a.md")'), {})
--   end
--
-- fresh()      a test set whose every case starts a new child nvim on tests/minimal_init.lua,
--              then runs `setup` (Lua) in it; the child stops after the last case
-- eval()       child.lua with the `return` written for you
-- needs()      wrap a case so it is skipped when a program is not on PATH
-- installed()  are these lazy.nvim plugins on disk (telescope tests skip without them)
-- settle()     sleep, then let the child run its scheduled callbacks
-- typer()      a keys(...) function: type each key, then let the child settle (telescope redraws late)
-- wait_for()   poll a Lua expression in the child until it is truthy
-- TMP          setup snippet: `tmp`, a fresh temp dir in the child
-- NOTES        setup snippet: vim.notify messages collected in `notes`

local M = {}

M.TMP = [[
_G.tmp = vim.fs.normalize(vim.fn.tempname())
vim.fn.mkdir(tmp, 'p')
]]

M.NOTES = [[
_G.notes = {}
vim.notify = function(msg) table.insert(_G.notes, msg) end
]]

---@class genja.test.FreshOpts
---@field lines? integer screen size of the child
---@field columns? integer
---@field only_if? boolean false: no child is started (the cases skip themselves)
---@field after? fun() runs after the setup, e.g. to let telescope settle

---@param setup? string Lua run in the child after each restart
---@param hooks? table more MiniTest hooks (pre_once, post_case, ...)
---@param opts? genja.test.FreshOpts
---@return table child, table T
function M.fresh(setup, hooks, opts)
	opts = opts or {}
	local child = MiniTest.new_child_neovim()
	hooks = hooks or {}
	local all = vim.tbl_extend('force', hooks, {
		pre_case = function()
			if opts.only_if == false then
				return
			end
			child.restart({ '-u', 'tests/minimal_init.lua' })
			if opts.lines then
				child.o.lines = opts.lines
			end
			if opts.columns then
				child.o.columns = opts.columns
			end
			if setup then
				child.lua(setup)
			end
			if opts.after then
				opts.after()
			end
		end,
		-- the file's own post_once (cleanup) runs after the child stopped
		post_once = function()
			child.stop()
			if hooks.post_once then
				hooks.post_once()
			end
		end,
	})
	return child, MiniTest.new_set({ hooks = all })
end

---The value of a Lua expression in the child.
---@param child table
---@param expr string
---@param args? any[]
---@return any
function M.eval(child, expr, args)
	return child.lua('return ' .. expr, args)
end

---`case`, skipped when `exe` is not on PATH. MiniTest.skip() only ends the function it is
---called in, so the check sits in each case.
---@param exe string
---@param case fun()
---@return fun()
function M.needs(exe, case)
	return function()
		if vim.fn.executable(exe) == 0 then
			MiniTest.skip(exe .. ' not on PATH')
		end
		case()
	end
end

---Are these lazy.nvim plugins installed (in stdpath('data')/lazy)?
---@param ... string plugin folder names
---@return boolean
function M.installed(...)
	local lazy = vim.fn.stdpath('data') .. '/lazy/'
	for _, name in ipairs({ ... }) do
		if not vim.uv.fs_stat(lazy .. name) then
			return false
		end
	end
	return true
end

---A keys(...) function for `child`: each key is typed, then the child gets `ms` (default 150)
---plus a vim.wait to run its scheduled callbacks.
---@param child table
---@param ms? integer
---@return fun(...: string)
function M.typer(child, ms)
	return function(...)
		for _, k in ipairs({ ... }) do
			child.type_keys(k)
			M.settle(child, ms)
		end
	end
end

---Sleep `ms` (default 150), then a vim.wait in the child so its scheduled callbacks run.
---@param child table
---@param ms? integer
function M.settle(child, ms)
	vim.uv.sleep(ms or 150)
	child.lua([[vim.wait(50)]])
end

---Poll `expr` in the child every 100 ms until it is truthy or `ms` (default 5000) pass.
---@param child table
---@param expr string
---@param ms? integer
---@return any last value
function M.wait_for(child, expr, ms)
	local stop = vim.uv.hrtime() + (ms or 5000) * 1e6
	local got = nil
	while vim.uv.hrtime() < stop do
		got = child.lua('return ' .. expr)
		-- nil from the child arrives as vim.NIL, which is truthy
		if got == vim.NIL then
			got = nil
		end
		if got then
			return got
		end
		vim.uv.sleep(100)
	end
	return got
end

return M
