
local actions = require 'telescope.actions'
local finders = require 'telescope.finders'
local pickers = require 'telescope.pickers'
local sorters = require 'telescope.sorters'
local state = require 'telescope.actions.state'

local myres = finders.new_table {
	results = { 'khaki',
	'red', 'blue', 'green', 'magenta', 'cyan', 'firebrick' },
}

local handleSelection = function (selection)
	vim.notify("selected {index=".. selection.index.."}: " .. selection[1])
end

local replaceDefault = function(prompt_bufnr, _)
	actions.select_default:replace(function()
		actions.close(prompt_bufnr)
		handleSelection(state.get_selected_entry())
	end)
	return true
end

local function picker(o, mycolors_opts)
	vim.notify("A-".. vim.inspect(o))
	vim.notify("B-".. vim.inspect(mycolors_opts))
	local P = pickers.new(o, {
		prompt_title = 'Some colors',
		finder = myres ,
		sorter = sorters.get_generic_fuzzy_sorter(),
		attach_mappings = replaceDefault ,
	})

	P:find()

end

return picker
