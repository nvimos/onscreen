-- Telescope dropdown over f2 entries: the main <F2> list and task sub-pickers
-- (make targets). <Tab> marks; <CR> runs the marked entries in mark order,
-- else the one under the cursor.

local run = require('genja.f2.run')

local M = {}

---@class genja.f2.PickOpts
---@field title string
---@field show_group? boolean display `group  label` (main list) or just the label

---Groups are at most this long; shorter ones are padded on the left (readme.md).
M.GROUP_WIDTH = 6

-- dropped from what the list shows; `:` and parens stay
local NOISE = '[«»\'"!`%[%]]'

---Label as the list shows it: lower case, no quotes, guillemets, brackets or `!`, single spaces.
---The task keeps its own label (the registry matches on it).
---@param text string
---@return string
function M.clean(text)
	local shown = text:lower():gsub(NOISE, '')
	shown = shown:gsub('%s+', ' ')
	return vim.trim(shown)
end

---Main-list line: the group right-aligned to GROUP_WIDTH, two spaces, the label.
---  `  diag  show all (2 hidden)`, `claude  fix the tabline`
---@param group string
---@param label string
---@return string
function M.display(group, label)
	local shown = M.clean(group)
	local pad = M.GROUP_WIDTH - vim.fn.strdisplaywidth(shown)
	if pad > 0 then
		shown = string.rep(' ', pad) .. shown
	end
	return shown .. '  ' .. M.clean(label)
end

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
				local display = M.clean(entry.task.label)
				if opts.show_group then
					display = M.display(entry.task.group, entry.task.label)
				end
				-- the padding isn't matched against the prompt
				return { value = entry, display = display, ordinal = vim.trim(display) }
			end,
		}),
		sorter = require('telescope.config').values.generic_sorter({}),
		attach_mappings = function(bufnr, map)
			require('genja-finder').attach_shared_keys(map) -- Telemap keys and <M-f> filter
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
