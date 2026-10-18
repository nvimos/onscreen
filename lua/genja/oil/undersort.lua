-- move oil entries into _category dirs (telescope undersort picker)

local entry = require('genja.oil.entry')

local M = {}

-- telescope undersort picker over the oil entries; afterFn runs after the move
M.MoveCat = function(afterFn, opts)
	local op = {
		afterFn = afterFn,
		movees = entry.get_oil_entries(),
		pats = { -- {{{ patterns
			-- [[-*]],
			-- [[-*/_*]],
			-- [[-*/*/_*]],
			[[%d+%-*]],
			[[%d+%-*/_*]],
			[[%d+%-*/*/_*]],
			[[_*]],
			[[_*/_*]],
		}, -- }}}
		input = '',
		dirs = { -- {{{ dirs
			-- [[Q:\audio-balmora\musikkkk]],
			-- [[Q:\audio-balmora\muzica]],
			[[V:\]] -- cinema
		}  -- }}}
	}
	op = vim.tbl_extend('force', op, opts or {})
	require('telescope').extensions.undersort.undersort(op)
end

M.move_to_cat_delete = function()
	local pos = vim.api.nvim_win_get_cursor(0)
	M.MoveCat(function()
		-- move cursor back to where it was after reloading
		-- maybe there is oil-reload?
		vim.cmd([[edit ]] .. vim.fn.expand('%'))
		local timer = vim.loop.new_timer()
		timer:start(500, 0, vim.schedule_wrap(function()
			vim.api.nvim_win_set_cursor(0, pos)
		end))
	end, { default_text = "_del" })
end

M.move_to_cat = function()
	local pos = vim.api.nvim_win_get_cursor(0)
	M.MoveCat(function()
		-- move cursor back to where it was after reloading
		-- maybe there is oil-reload?
		vim.cmd([[edit ]] .. vim.fn.expand('%'))
		local timer = vim.loop.new_timer()
		timer:start(1000, 0, vim.schedule_wrap(function()
			vim.api.nvim_win_set_cursor(0, pos)
		end))
	end)
end

return M
