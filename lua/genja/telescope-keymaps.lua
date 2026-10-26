-- Telescope keymaps picker with genja-finder's refine keys (<M-f> <M-x> <M-n> <BS>)
-- and <M-r>/<M-R>: show one desc group at a time (`Git:`, `LSP:`, `Fold:` ...), then all again.
-- The groups come from the list shown when the cycle starts, so after <M-f>/<M-x> they cycle
-- within the refined list. Keys: <leader>jM, <leader>jbk, <leader>jb? (lua/genja/map-telescope.lua).
-- Tests: tests/telescope-keymaps/ (`make test D=telescope-keymaps` in tests/).

local SRC = 'lua/genja/telescope-keymaps.lua: '

local M = {}

---A list rotate() showed: the list it was cut from, and which group (0 = all).
---@class genja.KeymapsView
---@field base table   static finder the group was cut from
---@field idx integer  0 = all of base, else index into the groups of base

---Rotation state of one picker.
---@class genja.KeymapsRotation
---@field title string                    the picker's own prompt title
---@field views table<table, genja.KeymapsView> finders rotate() set -> their view; <BS> can bring one back
---@field groups table<table, string[]>   base finder -> its desc groups, most keymaps first

---@type table<integer, genja.KeymapsRotation>
local rotations = {}

---Desc prefix of a keymap entry: `Git` for 'Git: hunk stage', nil when the desc has none.
---@param entry table telescope entry from builtin.keymaps
---@return string|nil
local function group_of(entry)
	local km = entry.value
	if type(km) ~= 'table' or type(km.desc) ~= 'string' then
		return nil
	end
	return km.desc:match('^([^:]+):%s')
end

---Groups in `entries`, the biggest first, ties by name.
---@param entries table[]
---@return string[]
local function collect_groups(entries)
	local counts = {}
	for _, entry in ipairs(entries) do
		local group = group_of(entry)
		if group then
			counts[group] = (counts[group] or 0) + 1
		end
	end
	local groups = vim.tbl_keys(counts)
	table.sort(groups, function(a, b)
		if counts[a] ~= counts[b] then
			return counts[a] > counts[b]
		end
		return a < b
	end)
	return groups
end

---Rotation state for the picker in `bufnr`, created on first use.
---@param bufnr integer prompt buffer
---@param picker table
---@return genja.KeymapsRotation
local function rotation(bufnr, picker)
	if rotations[bufnr] then
		return rotations[bufnr]
	end
	rotations[bufnr] = { title = picker.prompt_title, views = {}, groups = {} }
	vim.api.nvim_create_autocmd('BufWipeout', {
		buffer = bufnr, once = true,
		callback = function() rotations[bufnr] = nil end,
	})
	return rotations[bufnr]
end

---Show the next (step 1) or previous (step -1) group; past the last one shows all keymaps.
---@param bufnr integer prompt buffer
---@param step integer
function M.rotate(bufnr, step)
	local picker = require('telescope.actions.state').get_current_picker(bufnr)
	local rot = rotation(bufnr, picker)

	-- a list rotate() made keeps cycling; any other (first use, <M-f>, <M-x>) starts a cycle on itself
	local base = picker.finder
	local idx = 0
	local view = rot.views[picker.finder]
	if view then
		base = view.base
		idx = view.idx
	elseif type(base.results) ~= 'table' then
		vim.notify(SRC .. 'no fixed result list to rotate', vim.log.levels.INFO)
		return
	end

	local groups = rot.groups[base]
	if not groups then
		groups = collect_groups(base.results)
		rot.groups[base] = groups
	end
	if #groups == 0 then
		return
	end
	-- idx runs 0..#groups, 0 = all
	idx = (idx + step) % (#groups + 1)

	local finder = base
	local title = rot.title
	if idx > 0 then
		local group = groups[idx]
		local kept = {}
		for _, entry in ipairs(base.results) do
			if group_of(entry) == group then
				table.insert(kept, entry)
			end
		end
		finder = require('telescope.finders').new_table({
			results = kept,
			entry_maker = function(entry) return entry end,
		})
		title = string.format('%s [%s: %d/%d]', rot.title, group, idx, #groups)
	end
	rot.views[finder] = { base = base, idx = idx }

	-- refine's titles build on prompt_title, so <M-f> after this keeps the group: `[Git: 1/9] [filter]`
	picker.prompt_title = title
	require('genja-finder.refine').show_title(bufnr)
	picker:refresh(finder, { reset_prompt = false })
end

---Telescope keymaps with the refine keys and <M-r>/<M-R> group rotation.
---@param opts? table passed to builtin.keymaps
function M.open(opts)
	opts = opts or {}
	opts.attach_mappings = function(_, map)
		map({ 'i', 'n' }, '<M-r>', function(bufnr) M.rotate(bufnr, 1) end, { desc = 'keymaps: next desc group' })
		map({ 'i', 'n' }, '<M-R>', function(bufnr) M.rotate(bufnr, -1) end, { desc = 'keymaps: previous desc group' })
		return true
	end
	require('genja-finder').enhance(require('telescope.builtin').keymaps)(opts)
end

return M
