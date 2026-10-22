-- Keys for lua/lazyp/new/urlview.lua.

-- Telescope picker, not vim.ui.select: that returns one item only.
-- <Tab> marks entries; <CR> opens the marked ones, or the current one if none are marked.
---@param urls string[]
local function pick_urls(urls)
	local actions = require('telescope.actions')
	local action_state = require('telescope.actions.state')

	---@param bufnr integer prompt buffer
	local function open_marked(bufnr)
		local picker = action_state.get_current_picker(bufnr)
		local entries = picker:get_multi_selection()
		if #entries == 0 then
			local current = action_state.get_selected_entry()
			if current then
				entries = { current }
			end
		end
		actions.close(bufnr)
		for _, entry in ipairs(entries) do
			vim.ui.open(entry.value)
		end
	end

	---@param bufnr integer prompt buffer
	---@return boolean keep_defaults
	local function attach_mappings(bufnr)
		actions.select_default:replace(function() open_marked(bufnr) end)
		return true
	end

	local theme = require('telescope.themes').get_dropdown()
	require('telescope.pickers').new(theme, {
		prompt_title = 'Open URLs (<Tab> mark, <CR> open)',
		finder = require('telescope.finders').new_table({ results = urls }),
		sorter = require('telescope.config').values.generic_sorter({}),
		attach_mappings = attach_mappings,
	}):find()
end

local function open_selection_urls()
	local line1 = vim.fn.line('v')
	local line2 = vim.fn.line('.')
	if line1 > line2 then
		line1, line2 = line2, line1
	end
	vim.api.nvim_feedkeys(vim.keycode('<Esc>'), 'nx', false)

	local found = require('urlview.search').selection({ line1 = line1, line2 = line2 })
	-- Drop duplicates, keep text order.
	local urls = {}
	local seen = {}
	for _, url in ipairs(found) do
		if not seen[url] then
			seen[url] = true
			table.insert(urls, url)
		end
	end
	if #urls == 0 then
		vim.notify('lua/genja/map-plugin/urlview.lua: no URLs in selection', vim.log.levels.INFO)
		return
	end
	pick_urls(urls)
end

---@param Maps genja.MapPlugin
return function(Maps)
	local spec_name = Maps.current_file()

	Maps:add_keys(spec_name, {
		{ 'gx', open_selection_urls, mode = 'x', desc = 'Open URLs in selection (<Tab> marks several)' },
		{ '<leader>gx', '<cmd>UrlView buffer<cr>', desc = 'Pick URL in buffer' },
	})
end
