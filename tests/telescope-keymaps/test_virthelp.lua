-- Key help in telescope's results (lua/genja/ext/telescope-virthelp.lua, hooked in
-- plugin/telescope-virthelp.lua): a picker over an empty table, with two maps of its own,
-- shows `key | m | description` rows as virtual lines, in aligned columns.
-- `make test D=telescope-keymaps G=virthelp` in tests/. Needs telescope and plenary in
-- lazy's data dir; skips without them.
local H = require('helpers.timing')
local S = H.suite('telescope-keymaps')

local child = MiniTest.new_child_neovim()
local eq = MiniTest.expect.equality

local lazy = vim.fn.stdpath('data') .. '/lazy/'
local have_telescope = vim.uv.fs_stat(lazy .. 'telescope.nvim') ~= nil and vim.uv.fs_stat(lazy .. 'plenary.nvim') ~= nil

local T = MiniTest.new_set({
	hooks = {
		post_once = function()
			child.stop()
			H.save()
		end,
	},
})

-- Open the picker in a fresh child; the empty table finder answers at once.
local function open_picker()
	child.restart({ '-u', 'tests/minimal_init.lua' })
	child.o.lines = 40
	child.o.columns = 160
	child.lua([[
		local lazy = vim.fn.stdpath('data') .. '/lazy/'
		vim.opt.rtp:prepend(lazy .. 'plenary.nvim')
		vim.opt.rtp:prepend(lazy .. 'telescope.nvim')
		require('telescope').setup({})
		vim.cmd.runtime('plugin/telescope-virthelp.lua')

		local pickers = require('telescope.pickers')
		local finders = require('telescope.finders')
		local conf = require('telescope.config').values
		pickers.new({}, {
			prompt_title = 'virthelp test',
			finder = finders.new_table({ results = {} }),
			sorter = conf.generic_sorter({}),
			attach_mappings = function(_, map)
				-- insert-mode maps only: the first draw can run before insert mode starts and find
				-- nothing for normal mode; ModeChanged must still draw the insert-mode help
				map('i', '<C-y>', function() end, { desc = 'Test: yank thing' })
				map('i', '<M-q>', function() end, { desc = 'Test: another' })
				return true
			end,
		}):find()

		-- the key help's lines (virt_lines of its one extmark), nil while not drawn
		_G.help_lines = function()
			local ns = vim.api.nvim_get_namespaces()['genja_telescope_keyhelp']
			local prompt = vim.api.nvim_get_current_buf()
			local ok, picker = pcall(require('telescope.actions.state').get_current_picker, prompt)
			if not ns or not ok or not picker or not picker.results_bufnr then
				return false
			end
			local marks = vim.api.nvim_buf_get_extmarks(picker.results_bufnr, ns, 0, -1, { details = true })
			if #marks == 0 or not marks[1][4].virt_lines then
				return false
			end
			local lines = {}
			for _, chunks in ipairs(marks[1][4].virt_lines) do
				table.insert(lines, chunks[1][1])
			end
			-- visible: the results window is open and the mark is on a row it shows; virt_lines
			-- below the line just above w0 count as filler above w0 (topfill), so w0 - 1 counts too
			local win = picker.results_win
			local row = marks[1][2] + 1
			local shown = vim.api.nvim_win_is_valid(win)
				and row >= vim.fn.line('w0', win) - 1 and row <= vim.fn.line('w$', win)
			return { lines = lines, shown = shown }
		end
	]])
end

---Wait for the help with the picker's insert-mode maps in it (the first draw may be normal mode).
---@param timeout integer
---@return { lines: string[], shown: boolean }|nil
local function wait_help(timeout)
	local help = H.wait(function()
		local got = child.lua('return help_lines()')
		if type(got) ~= 'table' then
			return false
		end
		for _, line in ipairs(got.lines) do
			if line:find('Test: yank thing', 1, true) then
				return got
			end
		end
		return false
	end, timeout)
	if not help then
		return nil
	end
	return help
end

T['key help: visible, in columns'] = S:case({ name = 'virthelp columns', groups = { 'telescope', 'virthelp' }, timeout = 5000, slow = 2000 }, function(ctx)
	if not have_telescope then
		MiniTest.skip('telescope or plenary not in ' .. lazy)
	end
	open_picker()
	local help = wait_help(ctx.timeout)
	if not help then
		error('no key help with the picker maps within ' .. ctx.timeout .. ' ms: ' .. vim.inspect(child.lua('return help_lines()')))
	end
	eq(help.shown, true)

	-- header first, then rows; key column padded, so the m and description columns line up
	local lines = help.lines
	local header_key = lines[1]:match('^   (key%s+)m  description$')
	if not header_key then
		error('header is not `key  m  description`: ' .. vim.inspect(lines[1]))
	end
	local descs = {}
	for i = 2, #lines do
		local key, m, desc = lines[i]:match('^   (%S+%s+)(%S  )(.+)$')
		if not key then
			error('row ' .. i .. ' is not `key  m  description`: ' .. vim.inspect(lines[i]))
		end
		eq(vim.fn.strdisplaywidth(key), vim.fn.strdisplaywidth(header_key))
		eq(m, 'i  ')
		descs[desc] = true
	end
	eq(descs['Test: yank thing'], true)
	eq(descs['Test: another'], true)
end)

return T
