


-- vim.api.nvim_create_autocmd('BufEnter', {
-- 	desc = 'Map special oil keys',
-- 	group = vim.api.nvim_create_augroup('OilKeys', { clear = true }),
-- 	pattern = 'oil:*',
-- 	--pattern = '*',
-- 	callback = function(ev)
--
-- 		local km = vim.keymap.set
-- 		local ono = function(desc) return {buffer = ev.buf, desc = desc, noremap = true} end
-- 		local o = function(desc) return {buffer = ev.buf, desc = desc } end
-- 		km('n', '<localleader>,',  ':lua MoveCat()<cr>',         o("move to category"))
-- 		km('n', '<localleader>c',  ':lua MoveCat()<cr>',         o("move to category"))
-- 		km('n', '<leader>c',       ':lua MoveCat()<cr>',         o("move to category"))
--
-- 	end
-- })


local actions = require "telescope.actions"
local action_state = require "telescope.actions.state"
local pickers = require "telescope.pickers"
local finders = require "telescope.finders"
local conf = require("telescope.config").values
local ask_where_to_move = function(opts)
	opts = opts or {}
	local gg = {}
	for _, d in pairs(opts.undersort.dirs) do
		for _, p in pairs(opts.undersort.pats) do
			vim.list_extend(gg, vim.fn.globpath( d, p, false, true))
		end
	end
	local basename = vim.fn.fnamemodify(opts.undersort.movee.path, ':t')
	local pi = pickers.new(opts, {
		prompt_title = 'mv: '..basename,
		finder = finders.new_table({ results = gg }),
		sorter = conf.generic_sorter(opts),
		attach_mappings = function(prompt_bufnr, map)
			actions.select_default:replace(function()
				actions.close(prompt_bufnr)
				local selection = action_state.get_selected_entry()
				if opts.undersort.action == "mv" then
					local from = opts.undersort.movee.path
					local to = JoinPaths(selection[1], basename)
					local success, errorMessage = os.rename(from, to)
					if not success then
						vim.api.nvim_err_writeln(errorMessage)
					else
						vim.cmd[[:norm m`]]
						vim.notify( 'mv '.. from .. ' ' .. to)
						vim.cmd[[:edit %:p]]
						vim.cmd[[:norm '`]]
					end
				end
			end)
			return true
		end,
	})
	pi:find()
end

local undersort = function(opts)
	local drop = require('telescope.themes').get_dropdown()
	drop.undersort = opts
	ask_where_to_move(drop)
end


function MoveCat(action)
	action = action or 'mv' -- vote
	local oil = require('oil')
	local d = oil.get_current_dir()
	local n = oil.get_cursor_entry().name
	local m = { path = d .. '\\' .. n, dir = d, name = n }
	vim.notify("movee", m.name)

	undersort({
		action = action,
		movee = m,
		pats = {
			[[??-*]],
			[[??-*/_*]],
			[[??-*/*/_*]],
			[[_*]]
		},
		dirs = {
			-- [[Q:\audio-balmora\musikkkk]],
			-- [[Q:\audio-balmora\muzica]],
			[[V:\]] -- cinema
		}
	})
end


