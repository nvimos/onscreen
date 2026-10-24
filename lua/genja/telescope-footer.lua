-- Prototype: an always-on key footer for telescope pickers. One line on the results window's
-- bottom border: the prompt's own insert-mode keys whose desc reads `Area: what` (the config's
-- convention: genja-finder's refine and Telemap keys, picker-specific ones like <M-r>), so
-- telescope's built-in maps (desc = action name) stay out. <C-/> still shows them all.
--   vim.g.telescope_footer = false   off (default on); :TelescopeFooter toggles
-- Hook: FileType TelescopePrompt (plugin/telescope-footer.lua), so every picker gets it,
-- also the ones the config doesn't wrap. Spec and open questions:
-- doc-wip/readme.2026-10-24.telescope-explore.md

local M = {}

---Short text of a desc: `refine: filter the listed results (fresh prompt)` -> `filter the listed results`.
---@param desc string
---@return string|nil nil when the desc isn't `Area: what`
function M.short(desc)
	-- telescope stores a map()'s desc as `telescope|<desc>`
	local plain = desc:gsub('^telescope|', '')
	local what = plain:match('^[%w%-_ ]+:%s+(.+)$')
	if not what then
		return nil
	end
	what = what:gsub('%s*%b()%s*', ' ')
	return vim.trim(what)
end

---Footer text for the prompt buffer `bufnr`, at most `width` cells.
---@param bufnr integer
---@param width integer
---@return string
function M.text(bufnr, width)
	local items = {}
	local seen = {}
	for _, km in ipairs(vim.api.nvim_buf_get_keymap(bufnr, 'i')) do
		local what = km.desc and M.short(km.desc)
		-- <BS> and <Esc> everyone knows; their desc is long
		if what and not seen[km.lhs] and km.lhs ~= '<BS>' and km.lhs ~= '<Esc>' then
			seen[km.lhs] = true
			table.insert(items, { lhs = km.lhs, what = what })
		end
	end
	table.sort(items, function(a, b) return a.lhs < b.lhs end)
	local parts = {}
	for _, item in ipairs(items) do
		table.insert(parts, item.lhs .. ' ' .. item.what)
	end
	local text = ' ' .. table.concat(parts, ' · ') .. ' '
	if vim.fn.strdisplaywidth(text) > width then
		text = vim.fn.strcharpart(text, 0, width - 1) .. '…'
	end
	return text
end

---Show the footer for the picker of prompt buffer `bufnr`; closes with the prompt.
---@param bufnr integer
function M.attach(bufnr)
	if vim.g.telescope_footer == false or not vim.api.nvim_buf_is_valid(bufnr) then
		return
	end
	local ok, picker = pcall(require('telescope.actions.state').get_current_picker, bufnr)
	if not ok or not picker or not picker.layout then
		return
	end
	-- the results border is a separate window (plenary); its last line is the bottom border
	local border = picker.layout.results and picker.layout.results.border
	local border_win = border and border.win_id
	if not border_win or not vim.api.nvim_win_is_valid(border_win) then
		return
	end
	local pos = vim.api.nvim_win_get_position(border_win)
	local width = vim.api.nvim_win_get_width(border_win) - 4
	local height = vim.api.nvim_win_get_height(border_win)
	if width < 20 then
		return
	end
	local text = M.text(bufnr, width)
	if vim.trim(text) == '' then
		return
	end
	local buf = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, { text })
	local win = vim.api.nvim_open_win(buf, false, {
		relative = 'editor',
		row = pos[1] + height - 1,
		col = pos[2] + 2,
		width = math.min(width, vim.fn.strdisplaywidth(text)),
		height = 1,
		style = 'minimal',
		focusable = false,
		zindex = 200, -- above telescope's windows
		noautocmd = true,
	})
	vim.wo[win].winhighlight = 'Normal:TelescopeResultsTitle'
	vim.api.nvim_create_autocmd({ 'BufWipeout', 'BufHidden' }, {
		buffer = bufnr,
		once = true,
		callback = function()
			pcall(vim.api.nvim_win_close, win, true)
		end,
	})
end

---:TelescopeFooter: on/off for the next pickers.
function M.toggle()
	vim.g.telescope_footer = vim.g.telescope_footer == false
	local state = 'off'
	if vim.g.telescope_footer then
		state = 'on'
	end
	vim.notify('lua/genja/telescope-footer.lua: footer ' .. state .. ' for the next pickers')
end

return M
