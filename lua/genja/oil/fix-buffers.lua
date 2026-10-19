-- forget buffers of deleted files
-- Workaround for oil issue #762 (open as of 2026-10): deleting a file that is
-- still loaded in a buffer gives E211 "no longer available". Runs on
-- User OilActionsPre (after confirming, before deleting): wipes unmodified
-- buffers of deleted files and of files under deleted dirs.

local M = {}

-- comparable path: forward slashes, no trailing slash, lowercase on Windows
local function path_key(path)
	local key = vim.fs.normalize(path)
	if vim.fn.has('win32') == 1 then
		key = key:lower()
	end
	return key
end

local function deleted_paths(actions)
	local util = require('oil.util')
	local fs = require('oil.fs')
	local paths = {}
	for _, action in ipairs(actions) do
		if action.type == 'delete' then
			local scheme, path = util.parse_url(action.url)
			if scheme == 'oil://' and path then -- local files adapter only
				table.insert(paths, path_key(fs.posix_to_os_path(path)))
			end
		end
	end
	return paths
end

local function is_under(file_key, deleted_key)
	return file_key == deleted_key or vim.startswith(file_key, deleted_key .. '/')
end

M.forget_deleted_buffers = function(ev)
	local paths = deleted_paths(ev.data.actions or {})
	if #paths == 0 then
		return
	end
	for _, buf in ipairs(vim.api.nvim_list_bufs()) do
		local name = vim.api.nvim_buf_get_name(buf)
		local is_file_buffer = name ~= '' and vim.bo[buf].buftype == ''
		if is_file_buffer and not vim.bo[buf].modified then
			local key = path_key(name)
			for _, deleted in ipairs(paths) do
				if is_under(key, deleted) then
					vim.api.nvim_buf_delete(buf, { force = false })
					break
				end
			end
		end
	end
end

return M
