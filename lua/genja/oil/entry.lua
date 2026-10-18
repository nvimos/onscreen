-- vim: set foldmethod=marker foldlevel=0 foldnestmax=2 foldcolumn=2:

-- oil entries under the cursor or on the visual lines

local G = require('genja.oil.globals')

local M = {}

M.VisualLine = 'V'

function M.visual_line_range()
	local v, c = vim.fn.line("v"), vim.fn.line(".")
	local a, b = v, c
	if c < v then
		a, b = c, v
	end
	return a, b
end

M.oil_entry_dir_path = function()
	local entry = require('oil').get_cursor_entry()
	local dir = require('oil').get_current_dir()
	local path = G.JoinPaths(dir, entry.name)
	return entry, dir, path
end

M.cd_to_entry = function()
	local _, _, path = M.oil_entry_dir_path()
	if not G.IsDir(path) then
		path = G.Dirname(path)
	end
	vim.cmd('cd ' .. path)
end

M.entry_from_path = function(path)
	local dirname = vim.fn.fnamemodify(path:gsub('/$', ''), ':h')
	local basename = vim.fn.fnamemodify(path:gsub('/$', ''), ':t')
	local stat = vim.loop.fs_stat(path)
	return {
		dir = dirname,
		name = basename,
		path = G.JoinPaths(dirname, basename),
		stat = stat,
		size = stat.size,
		type = stat.type,
	}
end

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
M.get_oil_entries = function()
	local oil = require('oil')
	local d = oil.get_current_dir()
	local oil_entries = {}
	if M.VisualLine == vim.fn.mode() then
		local buf = vim.api.nvim_get_current_buf()
		local a, b = M.visual_line_range()
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
		local stat = vim.loop.fs_stat(e.path)
		if stat ~= nil then
			local pat = e.path .. '*.{finished,torrent}'
			for _, mf in pairs(vim.fn.glob(pat, false, true)) do
				-- table.insert(meta_files, M.entry_from_path(mf))
				table.insert(oil_entries, M.entry_from_path(mf))
			end
		end
	end
	return oil_entries
end

return M
