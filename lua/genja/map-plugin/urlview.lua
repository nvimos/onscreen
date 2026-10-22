-- Keys for lua/lazyp/new/urlview.lua.

-- Open the picked URL, then show the picker again with the rest, until none
-- remain or the picker is cancelled.
---@param urls string[]
local function pick_loop(urls)
	if #urls == 0 then
		return
	end
	vim.ui.select(urls, { prompt = 'Open URL' }, function(url, idx)
		if not url then
			return
		end
		vim.ui.open(url)
		table.remove(urls, idx)
		pick_loop(urls)
	end)
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
	pick_loop(urls)
end

---@param Maps genja.MapPlugin
return function(Maps)
	local spec_name = Maps.current_file()

	Maps:add_keys(spec_name, {
		{ 'gx', open_selection_urls, mode = 'x', desc = 'Open URLs in selection one by one' },
		{ '<leader>gx', '<cmd>UrlView buffer<cr>', desc = 'Pick URL in buffer' },
	})
end
