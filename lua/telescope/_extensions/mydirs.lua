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

local function dirlist(o)
	local cat_dirs = {}
	vim.list_extend(cat_dirs, require('genja-startdirs').ranked()) -- most used first
	return cat_dirs
end

local ask_where_to_go = function(opts)
	opts = opts or {}
	local pi = pickers.new(opts, {
		prompt_title = 'cd to...',
		finder = finders.new_table({ results = dirlist(opts) }),
		sorter = conf.generic_sorter(opts),
		attach_mappings = function(prompt_bufnr, map)
			-- map({'i', 'n'}, '<esc>', actions.close)
			-- map({'i', 'n'}, '<F2>', actions.move_selection_previous)
			-- map({'i', 'n'}, '<F3>', actions.move_selection_next)
			-- Telemap(map)
			require('genja-finder').attach_shared_keys(map) -- Telemap keys and <M-f> filter

			-- would be cool to change the dir on-the-fly in the buffer "under" the prompt...
			-- like this, it gives a warning about the buffer not being written.
			-- ... idk.. maybe figure out how to swap the buffer from where the prompt was called
			-- ... or take note of it in the <F3> binding.
			-- map({'i', 'n'}, '<F3>', function(buf)
			-- 	actions.move_selection_next(buf)
			-- 	vim.cmd.chdir(ts_state.get_selected_entry()[1])
			-- 	vim.cmd.edit('.')
			-- end)

			actions.select_default:replace(function()
				actions.close(prompt_bufnr)
				require('genja-startdirs').go(ts_state.get_selected_entry()[1]) -- cd, open, count a use
				vim.cmd.pwd()
			end)
			return true
		end,
	})
	pi:find()
end

local mydirs = function(opts, foo)
	-- local drop = require('telescope.themes').get_dropdown()

	local drop = require('telescope.themes').get_dropdown()
	drop.layout_strategy = drop.layout_strategy
	drop.layout_config = drop.layout_config
	drop.layout_config.anchor = "NW"


	drop.mydirs = opts
	ask_where_to_go(drop)
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
		mydirs = function(o) mydirs(o, opts) end,
	},
}
