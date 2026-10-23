local pickers = require "telescope.pickers"
local finders = require "telescope.finders"
local conf = require("telescope.config").values
local actions = require "telescope.actions"
local action_state = require "telescope.actions.state"

local M = { items = {} }

function M.add_item(n, fn, d)   table.insert(M.items, { name = n, callback = fn, display = d}) end
function M.just_run(cmd, d)     M.add_item(cmd, function() vim.cmd(cmd) end, d) end
function M.just_command(cmd, d) M.add_item(cmd, function() vim.api.nvim_command(cmd) end, d) end

local SRC = 'lua/telescope/_extensions/mylunsj.lua: '

-- First andy.bat found wins.
function M.run_andy()
	for _, path in ipairs({ 'a:/bin/andy.bat', 'c:/bin/andy.bat' }) do
		if vim.fn.filereadable(path) == 1 then
			vim.system({ 'cmd.exe', '/c', path })
			return
		end
	end
	vim.notify(SRC .. 'andy.bat not found in a:/bin or c:/bin', vim.log.levels.WARN)
end

M.init = function()
	M.items = {}

	-- M.add_item('edit $MYVIMRC', function() vim.cmd('e $MYVIMRC') end)
	M.just_run 'Telescope mydirs'
	M.just_run 'Lazy sync'
	M.just_run 'Mason'
	M.just_run 'Luapad'
	M.just_run 'MRU'
	M.just_run 'OverseerRun'
	M.just_run 'OverseerToggle'
	M.just_run 'checkhealth'
	M.just_run 'messages clear'
	M.just_run('split | enew | Quickmath', 'Quickmath')

	M.add_item('Lazygit', require('telescope._extensions.mylunsj.toggleterm-lazygit').run_lazygit)
	M.add_item('Neogit', function() vim.cmd('Neogit') end)
	M.add_item('andy.bat', M.run_andy)


	-- Dashboard doesnt start. no idea why… there is <space>jD
	-- M.just_run 'tabedit | enew | Dashboard'
	-- M.just_run 'CycleDirs'
end

function M.show_picker()
	M.init()
	local opts = {
		finder = finders.new_table {
			results = M.items,
			entry_maker = function(entry)
				return {
					value = entry,
					display = entry.display or entry.name,
					ordinal = entry.name,
				}
			end
		},
		sorter = conf.generic_sorter({}),
		attach_mappings = function(prompt_bufnr, map)
			require('genja-finder').attach_shared_keys(map) -- Telemap keys and <M-f> filter
			actions.select_default:replace(function()
				actions.close(prompt_bufnr)
				local selection = action_state.get_selected_entry()
				selection.value.callback()
			end)
			return true
		end,
	}
	local drop = require('telescope.themes').get_dropdown()
	opts.layout_strategy = drop.layout_strategy
	opts.layout_config = drop.layout_config
	opts.layout_config.anchor = "NW"
	pickers.new(opts, {}):find()
end

-- local default_opts = {}
-- local opts = {}

local teleM = require 'telescope'.register_extension {
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
