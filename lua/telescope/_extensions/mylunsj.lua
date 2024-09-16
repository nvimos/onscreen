-- File: lua/custom_picker/init.lua

local pickers = require "telescope.pickers"
local finders = require "telescope.finders"
local conf = require("telescope.config").values
local actions = require "telescope.actions"
local action_state = require "telescope.actions.state"

local M = {}

function M.add_item(name, callback)
	table.insert(M.items, {name = name, callback = callback})
end

function M.just_run(cmd)
	M.add_item(cmd, function() vim.cmd(cmd) end)
end

function M.just_command(cmd)
	M.add_item(cmd, function() vim.api.nvim_command(cmd) end)
end

-- function M.just_vimscript(cmd)
	-- M.add_item(cmd, function() vim.api.nvim_call_function(cmd, {}) end)
-- end

-- M.add_item('edit $MYVIMRC', function() vim.cmd('e $MYVIMRC') end)


M.init = function ()
	M.items = {}
	-- Dashboard doesnt start. no idea why… there is <space>jD
	-- M.just_run 'tabedit | enew | Dashboard' 
	M.just_run 'Lazy sync'
	M.just_run 'Luapad'
	M.just_run 'Git'
	M.just_run 'Mason'
	M.just_run 'OverseerRun'
	M.just_run 'OverseerToggle'
	-- M.just_run 'CycleDirs'
	M.just_run 'Telescope mydirs'
	M.just_run 'checkhealth'
	M.just_run 'split | enew | Quickmath'

	M.just_command 'Lazygit'
end

function M.show_picker()
	M.init()
	local opts = {
		finder = finders.new_table {
			results = M.items,
			entry_maker = function(entry)
				return {
					value = entry,
					display = entry.name,
					ordinal = entry.name,
				}
			end
		},
		sorter = conf.generic_sorter({}),
		attach_mappings = function(prompt_bufnr, map)
			Telemap(map)
			actions.select_default:replace(function()
				actions.close(prompt_bufnr)
				local selection = action_state.get_selected_entry()
				selection.value.callback()
			end)
			return true
		end,
	}

	-- Use the dropdown theme
	-- opts.layout_strategy = 'center'
	-- opts.layout_config = { width = 0.5, height = 0.4, }

	-- opts.layout_config = {
	-- 	anchor = "NW",
	-- 	-- width = 1,
	-- 	-- height = 0.3,
	-- 	prompt_position = "top",
	-- 	-- preview_cutoff = 40,
	-- 	horizontal = {
	-- 		width = { padding = 1 },
	-- 		height = { padding = 1 },
	-- 	},
	-- 	vertical = {
	-- 		width = { padding = 0.3 },
	-- 		height = { padding = 0.3 },
	-- 	},
	-- }

	local drop = require('telescope.themes').get_dropdown()
	opts.layout_strategy = drop.layout_strategy
	opts.layout_config = drop.layout_config
	opts.layout_config.anchor = "NW"


	pickers.new(opts, {}):find()

end


-- local default_opts = {}
-- local opts = {}

local teleM = require'telescope'.register_extension {
	-- setup = function(http_opts, _)
		-- opts = vim.tbl_extend('force', default_opts, http_opts)
	-- end,
	exports = {
		-- mylunsj = function(o) M.show_picker(o, opts) end,
		mylunsj = M.show_picker
	},
}

teleM.show_picker = M.show_picker
teleM.add_item = M.add_item
return teleM
-- M.show_picker()

