-- Keys for lua/lazyp/git/gitsigns.lua. Buffer-local: set in on_attach, so they
-- exist only in buffers gitsigns tracks; elsewhere ]c [c stay nvim's.

---@param Maps genja.MapPlugin
return function(Maps)
	local spec_name = Maps.current_file()

	-- runs before setup(opts): hands gitsigns the on_attach that sets the keys
	Maps:add_mappings(spec_name, function(opts)
		opts.on_attach = function(bufnr)
			local gs = require('gitsigns')
			local function o(desc)
				return { buffer = bufnr, desc = 'Git: ' .. desc }
			end

			-- in diff mode keep nvim's ]c [c (next/previous change)
			vim.keymap.set('n', ']c', function()
				if vim.wo.diff then
					vim.cmd.normal({ ']c', bang = true })
				else
					gs.nav_hunk('next')
				end
			end, o 'hunk next')
			vim.keymap.set('n', '[c', function()
				if vim.wo.diff then
					vim.cmd.normal({ '[c', bang = true })
				else
					gs.nav_hunk('prev')
				end
			end, o 'hunk previous')

			-- stage_hunk on a staged hunk unstages it
			vim.keymap.set('n', '<leader>hs', gs.stage_hunk, o 'hunk stage/unstage')
			vim.keymap.set('n', '<leader>hr', gs.reset_hunk, o 'hunk reset')
			vim.keymap.set('v', '<leader>hs', function()
				gs.stage_hunk({ vim.fn.line('.'), vim.fn.line('v') })
			end, o 'lines stage/unstage')
			vim.keymap.set('v', '<leader>hr', function()
				gs.reset_hunk({ vim.fn.line('.'), vim.fn.line('v') })
			end, o 'lines reset')
			vim.keymap.set('n', '<leader>hS', gs.stage_buffer, o 'buffer stage')
			vim.keymap.set('n', '<leader>hR', gs.reset_buffer, o 'buffer reset')

			vim.keymap.set('n', '<leader>hp', gs.preview_hunk, o 'hunk preview float')
			vim.keymap.set('n', '<leader>hi', gs.preview_hunk_inline, o 'hunk preview inline')
			vim.keymap.set('n', '<leader>hb', function()
				gs.blame_line({ full = true })
			end, o 'blame line')
			vim.keymap.set('n', '<leader>hB', gs.toggle_current_line_blame, o 'blame line toggle')
			vim.keymap.set('n', '<leader>hw', gs.toggle_word_diff, o 'diff word toggle')

			vim.keymap.set('n', '<leader>hd', gs.diffthis, o 'diff vs index')
			vim.keymap.set('n', '<leader>hD', function()
				gs.diffthis('~')
			end, o 'diff vs last commit')

			vim.keymap.set('n', '<leader>hq', gs.setqflist, o 'quickfix buffer hunks')
			vim.keymap.set('n', '<leader>hQ', function()
				gs.setqflist('all')
			end, o 'quickfix repo hunks')

			vim.keymap.set({ 'o', 'x' }, 'ih', gs.select_hunk, o 'hunk text object')
		end
	end)
end
