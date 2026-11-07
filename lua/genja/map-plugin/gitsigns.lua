-- Keys for lua/lazyp/git/gitsigns.lua. Buffer-local: set in on_attach, so they
-- exist only in buffers gitsigns tracks; elsewhere ]c [c stay nvim's.
-- Filetypes in vim.g.gitsigns_skip_ft (default markdown) aren't attached; <leader>mGs toggles per buffer.

---Filetypes gitsigns doesn't attach to: vim.g.gitsigns_skip_ft, default { 'markdown' }.
---@return string[]
local function skip_ft()
	local list = vim.g.gitsigns_skip_ft
	if type(list) ~= 'table' then
		list = { 'markdown' }
	end
	return list
end

---Attach gitsigns to the current buffer, or detach it; b:gitsigns_force keeps the choice
---for later attach attempts (true: attach despite skip_ft, false: stay off).
local function toggle_attach()
	local gs = require('gitsigns')
	local bufnr = vim.api.nvim_get_current_buf()
	-- not b:gitsigns_status_dict: gitsigns sets it before on_attach, so skipped buffers have it too
	local attached = require('gitsigns.cache').cache[bufnr] ~= nil
	if attached then
		vim.b[bufnr].gitsigns_force = false
		gs.detach(bufnr)
	else
		vim.b[bufnr].gitsigns_force = true
		gs.attach({ bufnr = bufnr, force = true })
	end
end

---@param Maps genja.MapPlugin
return function(Maps)
	local spec_name = Maps.current_file()

	-- runs before setup(opts): hands gitsigns the on_attach that sets the keys
	Maps:add_mappings(spec_name, function(opts)
		-- global: also attaches buffers that gitsigns skipped
		vim.keymap.set('n', '<leader>mGs', toggle_attach, { desc = 'UI: git toggle gitsigns' })
		vim.keymap.set('n', '<leader>tS',  toggle_attach, { desc = 'UI: git toggle gitsigns' })

		opts.on_attach = function(bufnr)
			-- skipped filetypes stay detached until <leader>mGs; returning false stops the attach
			local forced = vim.b[bufnr].gitsigns_force
			if forced == false then
				return false
			end
			if forced == nil and vim.tbl_contains(skip_ft(), vim.bo[bufnr].filetype) then
				return false
			end
			local gs = require('gitsigns')
			local function o(desc)
				return { buffer = bufnr, desc = 'Git: ' .. desc }
			end

			-- in diff mode keep nvim's ]c [c (next/previous change)
			local function hunk_next()
				if vim.wo.diff then
					vim.cmd.normal({ ']c', bang = true })
				else
					gs.nav_hunk('next')
				end
			end
			local function hunk_prev()
				if vim.wo.diff then
					vim.cmd.normal({ '[c', bang = true })
				else
					gs.nav_hunk('prev')
				end
			end
			local function stage_lines()
				gs.stage_hunk({ vim.fn.line('.'), vim.fn.line('v') })
			end
			local function reset_lines()
				gs.reset_hunk({ vim.fn.line('.'), vim.fn.line('v') })
			end
			local function blame_line_full()
				gs.blame_line({ full = true })
			end
			local function diff_last_commit()
				gs.diffthis('~')
			end
			local function qf_repo_hunks()
				gs.setqflist('all')
			end

			vim.keymap.set('n', ']c',         hunk_next,                    o  'hunk: next')
			vim.keymap.set('n', '[c',         hunk_prev,                    o  'hunk: previous')

			vim.keymap.set('n', '<leader>hs', gs.stage_hunk,                o  'hunk: stage/un')
			vim.keymap.set('v', '<leader>hs', stage_lines,                  o  'hunk: stage/un')
			vim.keymap.set('n', '<leader>hr', gs.reset_hunk,                o  'hunk: reset'   )
			vim.keymap.set('v', '<leader>hr', reset_lines,                  o  'hunk: reset'   )

            vim.keymap.set('n', '<leader>hS', gs.stage_buffer,              o 'buffer stage')
            vim.keymap.set('n', '<leader>hR', gs.reset_buffer,              o 'buffer reset')

			vim.keymap.set('n', '<leader>hp', gs.preview_hunk,              o  'hunk: preview float')
			vim.keymap.set('n', '<leader>hi', gs.preview_hunk_inline,       o  'hunk: preview inline')


			vim.keymap.set('n', '<leader>hb', blame_line_full,              o  'blame: line')
			vim.keymap.set('n', '<leader>hB', gs.toggle_current_line_blame, o  'blame: line toggle')
			vim.keymap.set('n', '<leader>hw', gs.toggle_word_diff,          o  'diff: word toggle')

			vim.keymap.set('n', '<leader>hd', gs.diffthis,                  o  'diff: vs index')
			vim.keymap.set('n', '<leader>hD', diff_last_commit,             o  'diff: vs last commit')

			vim.keymap.set('n', '<leader>hq', gs.setqflist,                 o  'quickfix: buffer hunks')
			vim.keymap.set('n', '<leader>hQ', qf_repo_hunks,                o  'quickfix: repo hunks')

			vim.keymap.set({ 'o', 'x' }, 'ih', gs.select_hunk,              o 'select: hunk')
		end
	end)
end
