-- Telescope dropdown over f2 entries: the main <F2> list and task sub-pickers
-- (make targets). <Tab> marks; <CR> runs the marked entries in mark order,
-- else the one under the cursor.

local run = require('genja.f2.run')

local M = {}

---@class genja.f2.PickOpts
---@field title string
---@field show_group? boolean display `group: label` (main list) or just the label

---@param entries genja.f2.Entry[] already sorted
---@param ctx genja.f2.Ctx
---@param opts genja.f2.PickOpts
function M.entries(entries, ctx, opts)
	local actions = require('telescope.actions')
	local action_state = require('telescope.actions.state')
	require('telescope.pickers').new(require('telescope.themes').get_dropdown(), {
		prompt_title = opts.title,
		finder = require('telescope.finders').new_table({
			results = entries,
			entry_maker = function(entry)
				local display = entry.task.label
				if opts.show_group then
					display = entry.task.group .. ': ' .. entry.task.label
				end
				return { value = entry, display = display, ordinal = display }
			end,
		}),
		sorter = require('telescope.config').values.generic_sorter({}),
		attach_mappings = function(bufnr, map)
			require('genja.fn.telemap').Telemap(map)
			actions.select_default:replace(function()
				local marked = action_state.get_current_picker(bufnr):get_multi_selection()
				if #marked == 0 then
					marked = { action_state.get_selected_entry() }
				end
				actions.close(bufnr)
				local picked = {}
				for _, selected in ipairs(marked) do
					table.insert(picked, selected.value)
				end
				run.entries(picked, ctx)
			end)
			return true
		end,
	}):find()
end

return M
