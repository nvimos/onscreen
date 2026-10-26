-- lua/genja/telescope-keymaps.lua with genja-finder's refine keys, driven by real keys
-- (doc-wip/readme.2026-10-23.telescope-keymaps.md). Needs telescope and plenary in lazy's
-- data dir; cases skip without them. Fresh child nvim per case.

local child = MiniTest.new_child_neovim()
local eq = MiniTest.expect.equality

local lazy = vim.fn.stdpath('data') .. '/lazy/'
local have_telescope = vim.uv.fs_stat(lazy .. 'telescope.nvim') ~= nil and vim.uv.fs_stat(lazy .. 'plenary.nvim') ~= nil

-- telescope sorts and redraws on scheduled callbacks; give the child time
local function settle()
	vim.uv.sleep(150)
	child.lua([[vim.wait(50)]])
end

---Type keys into the picker prompt, then wait for the list.
---@param ... string
local function keys(...)
	for _, k in ipairs({ ... }) do
		child.type_keys(k)
		settle()
	end
end

-- descs of the listed entries, sorted
local function shown()
	return child.lua([[return shown()]])
end

local function title()
	return child.lua([[return title()]])
end

local GIT_HUNK = {
	'Git: hunk reset1', 'Git: hunk reset3', 'Git: hunk reset5',
	'Git: hunk stage2', 'Git: hunk stage4', 'Git: hunk stage6',
}
local GIT = vim.list_extend(vim.deepcopy(GIT_HUNK), { 'Git: oil add' })
local LSP = { 'LSP: hunk thing 1', 'LSP: hunk thing 2', 'LSP: hunk thing 3' }

local T = MiniTest.new_set({
	hooks = {
		pre_case = function()
			if not have_telescope then
				return
			end
			child.restart({ '-u', 'tests/minimal_init.lua' })
			child.o.lines = 50
			child.o.columns = 200
			child.lua([[
				local lazy = vim.fn.stdpath('data') .. '/lazy/'
				local config = vim.fn.stdpath('config')
				vim.opt.rtp:prepend(lazy .. 'plenary.nvim')
				vim.opt.rtp:prepend(lazy .. 'telescope.nvim')
				vim.opt.rtp:prepend(config .. '/plug-wip/genja-finder.nvim')
				vim.opt.rtp:prepend(config .. '/plug-wip/genja-util.nvim')
				require('telescope').setup({})

				-- nvim's default maps differ between versions; only ours, two desc groups: Git (7, biggest), LSP (3)
				vim.cmd('nmapclear')
				for i = 1, 6 do
					local kind = 'reset'
					if i % 2 == 0 then
						kind = 'stage'
					end
					vim.keymap.set('n', '<leader>g' .. i, '<nop>', { desc = 'Git: hunk ' .. kind .. i })
				end
				for i = 1, 3 do
					vim.keymap.set('n', '<leader>l' .. i, '<nop>', { desc = 'LSP: hunk thing ' .. i })
				end
				vim.keymap.set('n', '<leader>o1', '<nop>', { desc = 'Git: oil add' })

				local function picker()
					return require('telescope.actions.state').get_current_picker(vim.api.nvim_get_current_buf())
				end
				-- descs with a group prefix only: nvim's default maps vary between versions
				_G.shown = function()
					local list = {}
					for entry in picker().manager:iter() do
						local desc = entry.value.desc
						if type(desc) == 'string' and desc:match('^%a+: ') then
							table.insert(list, desc)
						end
					end
					table.sort(list)
					return list
				end
				_G.title = function()
					local t = picker().layout.prompt.border._border_win_options.title
					if type(t) == 'table' then
						t = t[1].text
					end
					return t
				end
				require('genja.telescope-keymaps').open({ modes = { 'n' } })
			]])
			settle()
		end,
		post_once = child.stop,
	},
})

-- MiniTest.skip() only ends the function it is called in, so check per case
local function case(fn)
	return function()
		if not have_telescope then
			MiniTest.skip('telescope or plenary not in ' .. lazy)
		end
		fn()
	end
end

T['opens with every group'] = case(function()
	eq(shown(), vim.list_extend(vim.deepcopy(GIT), LSP))
	eq(title(), 'Key Maps')
end)

T['<M-r> shows the biggest group, title names it'] = case(function()
	keys('<M-r>')
	eq(shown(), GIT)
	eq(title(), 'Key Maps [Git: 1/2]')
end)

T['<M-r> next, <M-R> back, past the last: all'] = case(function()
	keys('<M-r>', '<M-r>')
	eq(shown(), LSP)
	eq(title(), 'Key Maps [LSP: 2/2]')
	keys('<M-R>')
	eq(shown(), GIT)
	keys('<M-r>', '<M-r>')
	eq(shown(), vim.list_extend(vim.deepcopy(GIT), LSP))
	eq(title(), 'Key Maps')
end)

-- guide step 5
T['group, type, <M-f>: filtered within the group, group stays in the title'] = case(function()
	keys('<M-r>', 'hunk', '<M-f>')
	eq(shown(), GIT_HUNK)
	eq(title(), 'Key Maps [Git: 1/2] [filter]')
	keys('stage6')
	eq(shown(), { 'Git: hunk stage6' })
end)

-- guide step 6
T['<BS> on the empty prompt undoes <M-f>'] = case(function()
	keys('<M-r>', 'hunk', '<M-f>', '<BS>')
	eq(child.lua([[return require('genja-finder.refine').text(vim.api.nvim_get_current_buf())]]), 'hunk')
	eq(shown(), GIT_HUNK)
	eq(title(), 'Key Maps [Git: 1/2]')
end)

-- guide step 7
T['group, type, <M-x>: excluded within the group'] = case(function()
	keys('<M-r>', 'oil', '<M-x>')
	eq(shown(), GIT_HUNK)
	eq(title(), 'Key Maps [Git: 1/2] [filter]')
end)

-- <M-r> after a refine step cycles the groups of the refined list, not of the full one
T['<M-f>, then <M-r>: groups within the filtered list'] = case(function()
	keys('hunk', '<M-f>', '<M-r>')
	eq(shown(), GIT_HUNK)
	eq(title(), 'Key Maps [Git: 1/2] [filter]')
	keys('<M-r>')
	eq(shown(), LSP)
	keys('<M-r>')
	eq(shown(), vim.list_extend(vim.deepcopy(GIT_HUNK), LSP))
	eq(title(), 'Key Maps [filter]')
end)

T['<M-x>, then <M-r>: excluded entries stay out'] = case(function()
	keys('oil', '<M-x>', '<M-r>')
	eq(shown(), GIT_HUNK)
end)

-- reported 2026-10-24: the second <M-r> went back to the full list
T['<M-r>, <M-f>, <M-r>: the filter stays'] = case(function()
	keys('<M-r>', 'hunk', '<M-f>', '<M-r>')
	eq(shown(), GIT_HUNK)
	eq(title(), 'Key Maps [Git: 1/1] [filter]')
end)

T['<BS> back to a group view, then <M-r>: next group of the full list'] = case(function()
	keys('<M-r>', 'hunk', '<M-f>', '<BS>', '<M-r>')
	-- prompt still has `hunk`
	eq(shown(), LSP)
	eq(title(), 'Key Maps [LSP: 2/2]')
end)

return T
