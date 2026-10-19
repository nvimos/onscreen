-- vim: set foldmethod=marker foldlevel=0 foldnestmax=2 foldcolumn=2:

-- oil entries under the cursor or on the visual lines

local G = require('genja.oil.globals')
local utils = require('genja.oil.utils')

local M = {}

M.VisualLine = 'V'

---@class genja.OilEntry
---@field dir string
---@field name string
---@field path string
---@field stat uv.fs_stat.result
---@field size integer
---@field type string

-- entry table for a path on disk; nil when the path does not exist
---@param path string
---@return genja.OilEntry|nil
M.entry_from_path = function(path)
	local dirname = vim.fn.fnamemodify(path:gsub('/$', ''), ':h')
	local basename = vim.fn.fnamemodify(path:gsub('/$', ''), ':t')
	local stat = vim.uv.fs_stat(path)
	if not stat then
		return nil
	end
	return {
		dir = dirname,
		name = basename,
		path = G.JoinPaths(dirname, basename),
		stat = stat,
		size = stat.size,
		type = stat.type,
	}
end

-- entry table for an oil entry `e` listed in dir `d`
---@param d string
---@param e oil.Entry
---@return genja.OilEntry
M.entry_from_oil = function(d, e)
	return {
		dir = d,
		name = e.name,
		path = G.JoinPaths(d, e.name),
		stat = e.meta.stat,
		size = e.meta.stat.size,
		type = e.meta.stat.type,
	}
end

-- entries under the cursor / visual lines, plus their *.finished / *.torrent side files
---@return genja.OilEntry[]
M.get_oil_entries = function()
	local oil = require('oil')
	local d = oil.get_current_dir()
	local oil_entries = {}
	if M.VisualLine == vim.fn.mode() then
		local buf = vim.api.nvim_get_current_buf()
		local a, b = utils.visual_line_range()
		for i = a, b do
			local m = M.entry_from_oil(d, oil.get_entry_on_line(buf, i))
			table.insert(oil_entries, m)
		end
		-- elseif VisualBlock == ...
	else
		local m = M.entry_from_oil(d, oil.get_cursor_entry())
		table.insert(oil_entries, m)
	end
	-- local meta_files = {}
	for _, e in pairs(oil_entries) do
		local stat = vim.uv.fs_stat(e.path)
		if stat ~= nil then
			local pat = e.path .. '*.{finished,torrent}'
			for _, mf in pairs(vim.fn.glob(pat, false, true)) do
				local side_file = M.entry_from_path(mf)
				if side_file then -- gone between glob and stat
					-- table.insert(meta_files, side_file)
					table.insert(oil_entries, side_file)
				end
			end
		end
	end
	return oil_entries
end

return M
