-- minuet-ai.nvim through blink.cmp, with whatever provider lua/lazyp/langs-comps/minuet.lua has on
-- (needs that provider to answer: a key in lua/genja/local/secrets.lua, or `ollama serve`).
-- `make test D=llm` in tests/. The sample is copied to a temp dir and the buffer is never written,
-- so samples/foo.sh stays as it is.
local H = require('helpers.timing')
local Helpers = require('helpers.completion')
local S = H.suite('llm')

local child = MiniTest.new_child_neovim()
local C = Helpers.new(child)

local SAMPLE = vim.fn.stdpath('config') .. '/tests/llm/samples/foo.sh'

local T = MiniTest.new_set({
	hooks = {
		pre_once = C.boot,
		post_case = C.esc,
		post_once = function()
			child.stop()
			H.save()
		end,
	},
})

---Copy the sample into a fresh temp dir; returns the copy's path.
---@return string
local function copy_sample()
	local dir = vim.fs.normalize(vim.fn.tempname())
	vim.fn.mkdir(dir, 'p')
	local copy = dir .. '/foo.sh'
	vim.fn.writefile(vim.fn.readfile(SAMPLE, 'b'), copy, 'b')
	return copy
end

-- Line 1 is `#!`: <M-y> asks minuet alone, the first minuet item is accepted, and line 1 must
-- become a real shebang. `/usr/bin/env sh|bash` passes; `/bin/sh|bash` passes with a note
-- (works, but env finds the shell on PATH); anything else fails.
T['minuet: <M-y> completes the shebang'] = S:case({ name = 'minuet shebang', groups = { 'minuet' }, timeout = 6000, slow = 2000 }, function(ctx)
	local before = vim.fn.readfile(SAMPLE, 'b')
	local copy = copy_sample()
	child.cmd('edit ' .. vim.fn.fnameescape(copy))
	child.lua('vim.api.nvim_win_set_cursor(0, { 1, 0 })')
	child.type_keys('A')
	-- let blink's own trigger on entering insert mode finish first: it starts a normal request
	-- (minuet left out), which would replace the <M-y> one if it came later
	vim.uv.sleep(300)
	child.type_keys('<M-y>')

	-- find the minuet item and accept it in one call: the list can change between two calls
	local item = H.wait(function()
		return child.lua([[
			local cmp = require('blink.cmp')
			for i, it in ipairs(cmp.get_items() or {}) do
				if it.source_id == 'minuet' then
					local info = { label = it.label, insertText = it.insertText, textEdit = it.textEdit }
					cmp.accept({ index = i })
					return info
				end
			end
			return false -- not nil: nil comes back over RPC as vim.NIL, which is truthy
		]])
	end, ctx.timeout)
	if not item then
		local provider = child.lua('return require("minuet").config.provider')
		error(('no minuet item within %d ms (provider %s; :CheckHealthSimpleMinuet)'):format(ctx.timeout, provider))
	end
	local line = H.wait(function()
		local l = child.lua('return vim.api.nvim_buf_get_lines(0, 0, 1, false)[1]')
		return l ~= '#!' and l or nil
	end, 1000)
	C.esc()

	-- the copy is never written; the sample must be untouched
	MiniTest.expect.equality(vim.fn.readfile(SAMPLE, 'b'), before)
	child.cmd('bwipeout!')

	if line == nil then
		error('accepting the minuet item left line 1 as `#!`; item: ' .. vim.inspect(item))
	end
	if line:match('^#!%s*/usr/bin/env%s+bash%s*$') or line:match('^#!%s*/usr/bin/env%s+sh%s*$') then
		return
	end
	if line:match('^#!%s*/bin/bash%s*$') or line:match('^#!%s*/bin/sh%s*$') then
		MiniTest.add_note(('shebang %q: works, but /usr/bin/env sh or bash is preferred'):format(line))
		return
	end
	error(('line 1 is not an sh or bash shebang: %q'):format(line))
end)

return T
