--[[

Prototype: an always-on key virtual text for telescope pickers.

Key help (M.help_attach): virtual text in the results buffer, before any results
arrive. A table with columns key | m | description: every non-default map of the current mode
(redrawn on mode change). Default = lhs in telescope.mappings.default_mappings[mode] and desc
equal to the one telescope builds for that action. <Esc>, <F#> and <S-F#> are left out.
Rows are sorted by description (case-insensitive, then key). A description too long for one line is
truncated. Removed as soon as the prompt has input or results arrive; shown again when the
results are empty. Every row, header included, is TelescopeResultsTitle. Rows are indented
three spaces; the header starts on the second visible line of the results window.
vim.g.telescope_keyhelp = false   key help off (default on)

The footer on the results border was abandoned (2026-10-25) and removed.

Hook: FileType TelescopePrompt (plugin/telescope-virthelp.lua), so every picker gets it,
also the ones the config doesn't wrap. Spec and open questions:
doc-wip/readme.2026-10-24.telescope-explore.md


--]]

local M = {}

-- {{{ key help in the results buffer

local help_ns = vim.api.nvim_create_namespace('genja_telescope_keyhelp')

---The desc telescope gives a map of `key_func` (mappings.lua get_desc_for_keyfunc), after
---resolving it like telescope_map does. nil: a command map (no desc) or nothing to compare.
---@param key_func any default_mappings entry
---@return string|nil
local function default_desc(key_func)
	local actions = require('telescope.actions')
	local opts = nil
	if type(key_func) == 'table' then
		opts = key_func.opts
	end
	if type(key_func) == 'string' then
		key_func = actions[key_func]
	elseif type(key_func) == 'table' then
		if key_func.type == 'command' then
			return nil
		elseif key_func.type == 'action_key' then
			key_func = actions[key_func[1]]
		elseif key_func.type == 'action' then
			key_func = key_func[1]
		end
	end
	if opts and opts.desc then
		return 'telescope|' .. opts.desc
	end
	if type(key_func) == 'table' then
		local names = vim.tbl_filter(function(action) return type(action) == 'string' end, key_func)
		return 'telescope|' .. table.concat(names, ' + ')
	elseif type(key_func) == 'function' then
		local info = debug.getinfo(key_func)
		return 'telescopej|' .. info.source .. ':' .. info.linedefined
	end
	return nil
end

---A buffer map's desc in the form default_desc compares: telescopej json -> `telescopej|source:line`.
---@param desc string|nil
---@return string|nil
local function comparable_desc(desc)
	if not desc then
		return nil
	end
	local json = desc:match('^telescopej|(.*)$')
	if not json then
		return desc
	end
	local ok, info = pcall(vim.json.decode, json)
	if not ok or type(info) ~= 'table' then
		return desc
	end
	return 'telescopej|' .. tostring(info.source) .. ':' .. tostring(info.linedefined)
end

---Text for the description column: no `telescope|` prefix, anonymous maps as `file:line`.
---@param km table nvim_buf_get_keymap item
---@return string
local function help_desc(km)
	local desc = comparable_desc(km.desc)
	if not desc then
		return km.rhs or '(no desc)'
	end
	local source, line = desc:match('^telescopej|@?(.*):(%d+)$')
	if source then
		return vim.fn.fnamemodify(source, ':t') .. ':' .. line
	end
	return (desc:gsub('^telescope|', ''))
end

---Keys left out of the help: <Esc>, <F#> and <S-F#>.
---@param lhs string
---@return boolean
local function hidden_key(lhs)
	local key = lhs:lower()
	return key == '<esc>' or key:match('^<f%d+>$') ~= nil or key:match('^<s%-f%d+>$') ~= nil
end

---Non-default maps of prompt buffer `bufnr` in `mode`, sorted by description.
---A map is default when its lhs is in telescope's default_mappings[mode] with the same desc.
---@param bufnr integer
---@param mode 'i'|'n'
---@return { lhs: string, desc: string }[]
function M.help_items(bufnr, mode)
	local defaults = {}
	local default_map = require('telescope.mappings').default_mappings[mode] or {}
	for lhs, key_func in pairs(default_map) do
		defaults[vim.api.nvim_replace_termcodes(lhs, true, true, true)] = default_desc(key_func) or true
	end
	local items = {}
	for _, km in ipairs(vim.api.nvim_buf_get_keymap(bufnr, mode)) do
		local expected = defaults[vim.api.nvim_replace_termcodes(km.lhs, true, true, true)]
		local is_default = false
		if expected == true then
			-- command maps carry no desc; same lhs is all there is to compare
			is_default = km.desc == nil
		elseif expected then
			is_default = comparable_desc(km.desc) == expected
		end
		if not is_default and not hidden_key(km.lhs) then
			table.insert(items, { lhs = km.lhs, desc = help_desc(km) })
		end
	end
	table.sort(items, function(a, b)
		local da = a.desc:lower()
		local db = b.desc:lower()
		if da ~= db then
			return da < db
		end
		return a.lhs < b.lhs
	end)
	return items
end

---Table lines `key | m | description`, each at most `width` cells; descriptions are truncated.
---@param items { lhs: string, desc: string }[]
---@param mode string
---@param width integer
---@return string[]
function M.help_lines(items, mode, width)
	local key_w = 3
	for _, item in ipairs(items) do
		key_w = math.max(key_w, vim.fn.strdisplaywidth(item.lhs))
	end
	local function row(key, m, desc)
		local text = '   ' .. key .. string.rep(' ', key_w - vim.fn.strdisplaywidth(key)) .. '  ' .. m .. '  ' .. desc
		if vim.fn.strdisplaywidth(text) > width then
			text = vim.fn.strcharpart(text, 0, width - 1) .. '…'
		end
		return text
	end
	local lines = { row('key', 'm', 'description') }
	for _, item in ipairs(items) do
		table.insert(lines, row(item.lhs, mode, item.desc))
	end
	return lines
end

---Clear the key help of `picker`.
---@param picker table
local function help_clear(picker)
	if picker.results_bufnr and vim.api.nvim_buf_is_valid(picker.results_bufnr) then
		vim.api.nvim_buf_clear_namespace(picker.results_bufnr, help_ns, 0, -1)
	end
end

---Draw the key help of the current mode at the top of the visible results.
---@param picker table
---@param bufnr integer prompt buffer
local function help_show(picker, bufnr)
	help_clear(picker)
	local win = picker.results_win
	local buf = picker.results_bufnr
	if not win or not vim.api.nvim_win_is_valid(win) or not buf or not vim.api.nvim_buf_is_valid(buf) then
		return
	end
	local mode = (vim.api.nvim_get_mode().mode:sub(1, 1) == 'i' and 'i' or 'n')
	local items = M.help_items(bufnr, mode)
	if #items == 0 then
		return
	end
	local lines = M.help_lines(items, mode, vim.api.nvim_win_get_width(win) - 1)
	-- descending pickers keep blank rows above the results: anchor on the top visible row;
	-- all rows go below it as virt_lines, so the help starts on line 2
	local row = vim.fn.line('w0', win) - 1
	vim.api.nvim_buf_set_extmark(buf, help_ns, row, 0, {
		virt_lines = vim.tbl_map(function(line) return { { line, 'TelescopeResultsTitle' } } end, lines),
	})
end

---Show the key help in the results of the picker of prompt buffer `bufnr` until input or
---results arrive; again when a search ends with no results.
---@param bufnr integer
function M.help_attach(bufnr)
	if vim.g.telescope_keyhelp == false or not vim.api.nvim_buf_is_valid(bufnr) then
		return
	end
	local ok, picker = pcall(require('telescope.actions.state').get_current_picker, bufnr)
	if not ok or not picker then
		return
	end
	local function has_results()
		-- manager is false until the first search ends
		if type(picker.manager) ~= 'table' then
			return false
		end
		return picker.manager:num_results() > 0
	end
	if not has_results() then
		help_show(picker, bufnr)
	end
	picker:register_completion_callback(function()
		if has_results() then
			help_clear(picker)
		else
			help_show(picker, bufnr)
		end
	end)
	vim.api.nvim_create_autocmd('TextChangedI', {
		buffer = bufnr,
		callback = function()
			if picker:_get_prompt() ~= '' then
				help_clear(picker)
			end
		end,
	})
	vim.api.nvim_create_autocmd('ModeChanged', {
		buffer = bufnr,
		callback = function()
			-- redraw only while shown
			local marks = vim.api.nvim_buf_get_extmarks(picker.results_bufnr, help_ns, 0, -1, { limit = 1 })
			if #marks > 0 then
				help_show(picker, bufnr)
			end
		end,
	})
end

-- }}}

return M
