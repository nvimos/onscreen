local ok, telescope = pcall(require, 'telescope')
if not ok then
	error 'Install nvim-telescope/telescope.nvim'
end

local actions = require "telescope.actions"
local ts_state = require "telescope.actions.state"
local pickers = require "telescope.pickers"
local finders = require "telescope.finders"
local conf = require("telescope.config").values

--------------------------------

local function discover_cats(o)
	local cat_dirs = {}
	local dd = o.undersort.dirs
	local pp = o.undersort.pats
	for _, d in pairs(dd) do
		for _, p in pairs(pp) do
			vim.list_extend(cat_dirs, vim.fn.globpath(d, p, false, true))
		end
	end
	return cat_dirs
end

local os_move = function(opts)
	-- vim.notify(vim.inspect( opts ))
	local movees = opts.undersort.movees
	local callback = opts.undersort.afterFn
	local telescoped = ts_state.get_selected_entry()
	local dest_dir = telescoped[1]
	for _, movee in pairs(movees) do
		local from, to = movee.path, JoinPaths(dest_dir, movee.name)
		local succ, errmsg = os.rename(from, to)
		if succ then
			vim.notify('mv ' .. from .. ' ' .. to)
		else
			vim.api.nvim_err_writeln(errmsg)
		end
		callback(succ)
	end
end

local function mv_title(movees)
	local out = {}
	if #movees > 1 then
		for _, e in pairs(movees) do
			table.insert(out, e.name:sub(1, 15) )
		end
	else
		table.insert(out, movees[1].name )
	end
	return Join(out, ', ')
end

local ask_where_to_move = function(opts)
	opts = opts or {}
	local pi = pickers.new(opts, {
		prompt_title = 'mv: ' .. mv_title(opts.undersort.movees),
		finder = finders.new_table({ results = discover_cats(opts) }),
		sorter = conf.generic_sorter(opts),
		attach_mappings = function(prompt_bufnr, map)
			actions.select_default:replace(function()
				actions.close(prompt_bufnr)
				os_move(opts)
			end)
			return true
		end,
	})
	pi:find()
end
local undersort = function(opts, foo)
	local drop = require('telescope.themes').get_dropdown()
	drop.undersort = opts
	ask_where_to_move(drop)
end


--------------------------------

local opts = {}
local default_opts = {
	hex = true,
	rgb = false,
	alpha = 220,
}

-- local picker = require 'telescope._extensions.undersort'

return telescope.register_extension {
	setup = function(http_opts, _)
		opts = vim.tbl_extend('force', default_opts, http_opts)
	end,
	exports = {
		undersort = function(o) undersort(o, opts) end,
	},
}


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
