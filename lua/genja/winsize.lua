-- Window sizes in big steps (idea 28). Keys in lua/genja/map-zero.lua (Windows):
--   <M-=> / <M-->  grow / shrink the current window along its split
--   <M-0>          cycle the left/top share of the split: 50 → 30 → 70 → 60 (percent)
--   <leader>wr     resize mode (which-key loop over <leader>W…): h j k l = 0, <Esc> leaves
-- smart-splits.nvim is an alternative, spec disabled: lua/lazyp/new/smart-splits.lua.
local SRC = 'lua/genja/winsize.lua: '

local M = {}

---@class genja.WinsizeConfig
---@field step 'percent'|'cells' percent of the screen, or fixed columns/lines
---@field percent integer step in percent of 'columns' / 'lines'
---@field cols integer step in columns (step = 'cells')
---@field rows integer step in lines (step = 'cells')
---@field shares integer[] <M-0> cycle: share of the first (left/top) window, in percent

---@type genja.WinsizeConfig
M.config = {
	step = 'percent',
	percent = 10,
	cols = 8,
	rows = 4,
	shares = { 50, 30, 70, 60 },
}

---@return boolean
local function has_vertical_neighbour()
	local cur = vim.fn.winnr()
	return vim.fn.winnr('h') ~= cur or vim.fn.winnr('l') ~= cur
end

---@param vertical boolean width (true) or height
---@return integer
local function step_size(vertical)
	local c = M.config
	if c.step == 'cells' then
		if vertical then
			return c.cols
		end
		return c.rows
	end
	if vertical then
		return math.max(1, math.floor(vim.o.columns * c.percent / 100))
	end
	return math.max(1, math.floor(vim.o.lines * c.percent / 100))
end

--- Grow (sign 1) or shrink (sign -1) the current window along its split.
--- Side by side: width; stacked: height; both: `axis` picks ('width'|'height').
---@param sign 1|-1
---@param axis? 'width'|'height'
function M.resize(sign, axis)
	local vertical = has_vertical_neighbour()
	if axis == 'width' then
		vertical = true
	elseif axis == 'height' then
		vertical = false
	end
	local win = vim.api.nvim_get_current_win()
	local n = step_size(vertical) * sign
	if vertical then
		vim.api.nvim_win_set_width(win, vim.api.nvim_win_get_width(win) + n)
	else
		vim.api.nvim_win_set_height(win, vim.api.nvim_win_get_height(win) + n)
	end
end

-- {{{ share cycle (<M-0>)

---Width of a winlayout() node: a leaf's width, a column's first leaf, a row's children plus separators.
---@param node table
---@return integer
local function node_width(node)
	if node[1] == 'leaf' then
		return vim.api.nvim_win_get_width(node[2])
	end
	if node[1] == 'col' then
		return node_width(node[2][1])
	end
	local sum = 0
	for _, child in ipairs(node[2]) do
		sum = sum + node_width(child)
	end
	return sum + #node[2] - 1
end

---Height of a winlayout() node, the same way with rows and columns swapped.
---@param node table
---@return integer
local function node_height(node)
	if node[1] == 'leaf' then
		return vim.api.nvim_win_get_height(node[2])
	end
	if node[1] == 'row' then
		return node_height(node[2][1])
	end
	local sum = 0
	for _, child in ipairs(node[2]) do
		sum = sum + node_height(child)
	end
	-- each window but the last has a statusline between it and the next
	return sum + #node[2] - 1
end

---@param node table
---@param win integer
---@return boolean
local function contains(node, win)
	if node[1] == 'leaf' then
		return node[2] == win
	end
	for _, child in ipairs(node[2]) do
		if contains(child, win) then
			return true
		end
	end
	return false
end

---Innermost split ('row' or 'col') holding `win`, and the index of the child that holds it.
---@param node table
---@param win integer
---@return table? split, integer? index
local function innermost_split(node, win)
	if node[1] == 'leaf' then
		return nil, nil
	end
	for i, child in ipairs(node[2]) do
		if contains(child, win) then
			local inner, idx = innermost_split(child, win)
			if inner then
				return inner, idx
			end
			return node, i
		end
	end
	return nil, nil
end

---Any window inside a node; setting its width (row child) or height (col child) sizes the node.
---@param node table
---@return integer
local function some_win(node)
	if node[1] == 'leaf' then
		return node[2]
	end
	return some_win(node[2][1])
end

--- Next share from config.shares for the split the current window is in.
--- Two windows: the first (left/top) gets the share. More: the current one does.
function M.cycle()
	local win = vim.api.nvim_get_current_win()
	local split, idx = innermost_split(vim.fn.winlayout(), win)
	if not split or not idx then
		vim.notify(SRC .. 'only one window, nothing to share')
		return
	end
	local shares = M.config.shares
	local i = (vim.t.winsize_share or 0) % #shares + 1
	vim.t.winsize_share = i
	local pct = shares[i]

	local target = split[2][idx]
	if #split[2] == 2 then
		target = split[2][1]
	end
	if split[1] == 'row' then
		local total = node_width(split)
		vim.api.nvim_win_set_width(some_win(target), math.floor(total * pct / 100))
	else
		local total = node_height(split)
		vim.api.nvim_win_set_height(some_win(target), math.floor(total * pct / 100))
	end
	local other = 100 - pct
	vim.api.nvim_echo({ { string.format('split %d/%d', pct, other) } }, false, {})
end
-- }}}

--- Resize mode: which-key popup over the <leader>W keys, open until <Esc>.
function M.mode()
	local ok, wk = pcall(require, 'which-key')
	if not ok then
		vim.notify(SRC .. 'which-key not loaded; use <leader>W… keys directly', vim.log.levels.WARN)
		return
	end
	---@diagnostic disable-next-line: undefined-field
	wk.show({ keys = '<leader>W', loop = true })
end

--- Switch step between percent and fixed cells.
function M.toggle_step()
	if M.config.step == 'percent' then
		M.config.step = 'cells'
	else
		M.config.step = 'percent'
	end
	vim.notify(SRC .. 'step: ' .. M.config.step)
end

return M
