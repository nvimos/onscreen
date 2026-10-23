-- vim.ui.select in a telescope dropdown (idea #12): code actions and every other
-- vim.ui.select caller. Telescope is required only when a selection is shown.

---Show `items` in a telescope dropdown and pass the pick to `on_choice`.
---@generic T
---@param items T[] items to choose from
---@param opts? vim.ui.select.Opts prompt and format_item are used
---@param on_choice fun(item: T|nil, idx: integer|nil) called once, with nil on cancel
local function select(items, opts, on_choice)
	opts = opts or {}
	local format = opts.format_item or tostring
	local actions = require('telescope.actions')
	local action_state = require('telescope.actions.state')

	local chosen = false

	---Hand the choice to the caller after the picker is gone, so it acts on the original window.
	---@param item any|nil picked item, nil on cancel
	---@param idx integer|nil its index in `items`, nil on cancel
	local function finish(item, idx)
		chosen = true
		vim.schedule(function() on_choice(item, idx) end)
	end

	---Turn an item into a telescope entry, shown and matched by its formatted text.
	---@param item any
	---@return { value: any, display: string, ordinal: string }
	local function make_entry(item)
		local text = format(item)
		return { value = item, display = text, ordinal = text }
	end

	---<CR>: close the picker and report the selected entry.
	---@param bufnr integer prompt buffer
	local function pick_selected(bufnr)
		local entry = action_state.get_selected_entry()
		actions.close(bufnr)
		if entry then
			finish(entry.value, entry.index)
		else
			finish(nil, nil)
		end
	end

	---After any close (<Esc>, <C-c>): report nil unless something was picked; callers expect on_choice(nil).
	local function cancel_if_unchosen()
		if not chosen then
			finish(nil, nil)
		end
	end

	---Wire <CR> and close to the handlers above.
	---@param bufnr integer prompt buffer
	---@param map genja-finder.TelescopeMap
	---@return boolean keep_defaults true: keep telescope's other default mappings
	local function attach_mappings(bufnr, map)
		require('genja-finder').attach_shared_keys(map) -- Telemap keys and <M-f> filter
		actions.select_default:replace(function() pick_selected(bufnr) end)
		actions.close:enhance({ post = cancel_if_unchosen })
		return true
	end

	local theme = require('telescope.themes').get_dropdown()
	local finder = require('telescope.finders').new_table({ results = items, entry_maker = make_entry })
	local sorter = require('telescope.config').values.generic_sorter({})

	require('telescope.pickers').new(theme, {
		prompt_title = opts.prompt or 'Select',
		finder = finder,
		sorter = sorter,
		attach_mappings = attach_mappings,
	}):find()
end

---@diagnostic disable-next-line: duplicate-set-field
vim.ui.select = select
