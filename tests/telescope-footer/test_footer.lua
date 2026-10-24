-- lua/genja/telescope-footer.lua (prototype): the key footer on the results border.
-- Needs telescope and plenary in lazy's data dir; the picker cases skip without them.

local child = MiniTest.new_child_neovim()
local eq = MiniTest.expect.equality

local lazy = vim.fn.stdpath('data') .. '/lazy/'
local have_telescope = vim.uv.fs_stat(lazy .. 'telescope.nvim') ~= nil and vim.uv.fs_stat(lazy .. 'plenary.nvim') ~= nil

local T = MiniTest.new_set({
	hooks = {
		pre_case = function()
			child.restart({ '-u', 'tests/minimal_init.lua' })
			child.o.lines = 40
			child.o.columns = 200
			child.lua([[
				local lazy = vim.fn.stdpath('data') .. '/lazy/'
				vim.opt.rtp:prepend(lazy .. 'plenary.nvim')
				vim.opt.rtp:prepend(lazy .. 'telescope.nvim')
				vim.opt.rtp:prepend(vim.fn.stdpath('config') .. '/plug-wip/genja-finder.nvim')
				vim.cmd('runtime plugin/telescope-footer.lua')
				_G.F = require('genja.telescope-footer')
				-- text of the footer float, '' when none
				_G.footer = function()
					for _, win in ipairs(vim.api.nvim_list_wins()) do
						local cfg = vim.api.nvim_win_get_config(win)
						if cfg.relative ~= '' and cfg.zindex == 200 then
							return vim.api.nvim_buf_get_lines(vim.api.nvim_win_get_buf(win), 0, 1, false)[1]
						end
					end
					return ''
				end
			]])
		end,
		post_once = child.stop,
	},
})

T['short: `Area: what (note)` -> what; other descs -> nil'] = function()
	eq(child.lua([[return F.short('refine: filter the listed results (fresh prompt)')]]), 'filter the listed results')
	eq(child.lua([[return F.short('Telescope: close')]]), 'close')
	eq(child.lua([[return F.short('move_selection_next')]]), vim.NIL)
end

T['picker with the refine keys: footer lists them, not telescope built-ins'] = function()
	if not have_telescope then
		MiniTest.skip('telescope or plenary not in ' .. lazy)
	end
	child.lua([[
		require('telescope').setup({})
		require('genja.telescope-keymaps').open({ modes = { 'n' } })
	]])
	vim.uv.sleep(400)
	local text = child.lua([[return footer()]])
	eq(text:find('<M-f> filter the listed results', 1, true) ~= nil, true)
	eq(text:find('<M-r> next desc group', 1, true) ~= nil, true)
	eq(text:find('move_selection', 1, true), nil)
	-- closes with the picker
	child.type_keys('<C-c>')
	vim.uv.sleep(200)
	eq(child.lua([[return footer()]]), '')
end

T['vim.g.telescope_footer = false: no footer'] = function()
	if not have_telescope then
		MiniTest.skip('telescope or plenary not in ' .. lazy)
	end
	child.lua([[
		vim.g.telescope_footer = false
		require('telescope').setup({})
		require('genja.telescope-keymaps').open({ modes = { 'n' } })
	]])
	vim.uv.sleep(400)
	eq(child.lua([[return footer()]]), '')
end

return T
