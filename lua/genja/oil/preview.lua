-- preview: list snug to the longest name, preview gets the rest (at least 50%)

local M = {}

local name_to_preview_gap = 3

-- width of the widest listing line, without oil's concealed '/<id> ' prefix
local function widest_listing_line(buf)
	local widest = 0
	for _, line in ipairs(vim.api.nvim_buf_get_lines(buf, 0, -1, false)) do
		local visible_text = line:gsub('^/%d+ ', '')
		local width = vim.fn.strdisplaywidth(visible_text)
		widest = math.max(widest, width)
	end
	return widest
end

-- gutter (signs, numbers) + longest name + a little air before the preview
local function wanted_listing_width(oil_win)
	local oil_buf = vim.api.nvim_win_get_buf(oil_win)
	local gutter_width = vim.fn.getwininfo(oil_win)[1].textoff
	return gutter_width + widest_listing_line(oil_buf) + name_to_preview_gap
end

-- never more than half, so the preview keeps at least 50%
local function listing_width(oil_win, total_width)
	local half = math.floor(total_width / 2)
	return math.min(wanted_listing_width(oil_win), half)
end

local function fit_split(oil_win, preview_win)
	local total_width = vim.api.nvim_win_get_width(oil_win) + vim.api.nvim_win_get_width(preview_win)
	vim.api.nvim_win_set_width(oil_win, listing_width(oil_win, total_width))
end

-- oil places the floats side by side with float.padding between them
local function fit_float(oil_win, preview_win)
	local oil_cfg = vim.api.nvim_win_get_config(oil_win)
	local preview_cfg = vim.api.nvim_win_get_config(preview_win)
	local stacked = oil_cfg.row ~= preview_cfg.row
	if stacked then
		return -- above/below, width does not matter
	end

	local left_cfg = oil_cfg
	local right_cfg = preview_cfg
	if preview_cfg.col < oil_cfg.col then
		left_cfg = preview_cfg
		right_cfg = oil_cfg
	end
	local padding = right_cfg.col - (left_cfg.col + left_cfg.width)
	local total_width = oil_cfg.width + preview_cfg.width

	oil_cfg.width = listing_width(oil_win, total_width)
	preview_cfg.width = total_width - oil_cfg.width
	right_cfg.col = left_cfg.col + left_cfg.width + padding

	vim.api.nvim_win_set_config(oil_win, oil_cfg)
	vim.api.nvim_win_set_config(preview_win, preview_cfg)
end

function M.fit_preview(oil_win, preview_win)
	local is_float = vim.api.nvim_win_get_config(oil_win).relative ~= ''
	if is_float then
		fit_float(oil_win, preview_win)
	else
		fit_split(oil_win, preview_win)
	end
end

function M.is_previewing(entry)
	local preview_win = require('oil.util').get_preview_win()
	if not preview_win then
		return false
	end
	return vim.w[preview_win].oil_entry_id == entry.id
end

M.toggle_preview_fit = function()
	local oil = require('oil')
	local entry = oil.get_cursor_entry()
	if not entry or M.is_previewing(entry) then
		require('oil.actions').preview.callback() -- closes it
		return
	end

	local oil_win = vim.api.nvim_get_current_win()
	oil.open_preview({}, function(err)
		if err then
			return
		end
		local preview_win = require('oil.util').get_preview_win()
		if not preview_win or not vim.api.nvim_win_is_valid(oil_win) then
			return
		end
		M.fit_preview(oil_win, preview_win)
	end)
end

return M
