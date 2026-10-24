-- GuiFuncs: one line per nvim-qt shim function; <CR> changes the value and keeps the picker open.
local pickers = require('telescope.pickers')
local conf = require('telescope.config').values
local actions = require('telescope.actions')
local action_state = require('telescope.actions.state')

local SRC = 'gui-funcs/init.lua: '

local GuiFuncState = require('genja.ui.gui-func-state')

-- 'GuiWindowFullScreen' -> 'Window Full Screen'
---@param name string
---@return string
local function label(name)
	local text = name:gsub('^Gui', '')
	text = text:gsub('(.)(%u)', '%1 %2')
	return text
end

local function make_finder()
	local finders = require('telescope.finders')
	return finders.new_table({
		results = GuiFuncState.all(),
		entry_maker = function(func)
			local text = label(func.name)
			return {
				value = func,
				ordinal = text,
				-- A function, so a refresh shows the new value.
				display = function(entry)
					return string.format('%-22s %s', text, entry.value:text())
				end,
			}
		end,
	})
end

-- Row to restore after a refresh, per picker; false once restored.
---@type table<table, integer|false>
local pending_row = setmetatable({}, { __mode = 'k' })

-- Refresh resets the cursor; put it back on the row that was changed.
---@param bufnr integer
---@param change fun(func: genja.GuiFunc)
local function change_selected(bufnr, change)
	local picker = action_state.get_current_picker(bufnr)
	local entry = action_state.get_selected_entry()
	if not entry then
		return
	end
	local func = entry.value
	if not func:available() then
		vim.notify(SRC .. func.name .. ' not defined (not nvim-qt?)', vim.log.levels.WARN)
		return
	end
	change(func)
	if pending_row[picker] == nil then
		picker:register_completion_callback(function(p)
			local row = pending_row[p]
			if row then
				pending_row[p] = false
				p:set_selection(row)
			end
		end)
	end
	pending_row[picker] = picker:get_selection_row()
	picker:refresh(nil, { reset_prompt = false })
end

---@param n number value for range items
---@return fun(bufnr: integer)
local function set_range(n)
	return function(bufnr)
		change_selected(bufnr, function(func)
			if func.kind ~= 'range' then
				vim.notify(SRC .. func.name .. ' takes no number', vim.log.levels.INFO)
				return
			end
			func:set(n)
		end)
	end
end

---@param opts? table telescope opts (attach_mappings comes from the decorator)
local function picker(opts)
	opts = opts or {}
	local drop = require('telescope.themes').get_dropdown()
	-- As tall as the items, up to the editor height; center layout takes prompt (1) + borders (3) from it.
	local wanted = #GuiFuncState.all() + 4
	drop.layout_config.height = function(_, _, max_lines)
		return math.min(wanted, max_lines)
	end
	pickers.new(opts, {
		prompt_title = 'Gui Functions',
		finder = make_finder(),
		sorter = conf.generic_sorter({}),
		layout_strategy = drop.layout_strategy,
		layout_config = drop.layout_config,
		attach_mappings = function(_, map)
			actions.select_default:replace(function(bufnr)
				change_selected(bufnr, function(func)
					func:advance()
				end)
			end)
			map({ 'i', 'n' }, '<M-0>', set_range(0), { desc = 'GuiFuncs: set number to 0' })
			map({ 'i', 'n' }, '<M-1>', set_range(1), { desc = 'GuiFuncs: set number to 1' })
			return true
		end,
	}):find()
end

local function show_picker()
	require('genja-finder').enhance(picker)({})
end

return {
	show_picker = show_picker,
}
