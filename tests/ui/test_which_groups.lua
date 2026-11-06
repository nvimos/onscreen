-- which-key groups vs mappings, in the real config (lua/lazyp/my/which-key.lua and other specs).
-- Warns, never fails: the lists go to the test notes (MiniTest.add_note).
--   a group with no mapping under its prefix (in any mode)
--   a <leader> prefix with 2+ mappings under it and no group (n and x modes)
-- Keys of plugins not loaded yet count: lazy.nvim maps stubs for them.
-- Buffer-local keys (LSP <leader>c…, gitsigns) don't: no file is open; BUFFER_GROUPS lists those groups.

local child = MiniTest.new_child_neovim()
-- Lua sent to the child, set below
local HELPERS

local T = MiniTest.new_set({
	hooks = {
		pre_once = function()
			local config = vim.fn.stdpath('config')
			dofile(config .. '/tests/helpers/real-config.lua').boot_child(child)
			-- which-key loads on VeryLazy; make sure its config ran
			child.lua([[require('which-key')]])
			child.lua(HELPERS)
		end,
		post_once = child.stop,
	},
})

-- Runs in the child. Works on raw key bytes (vim.keycode) and shows them with keytrans.
HELPERS = [==[
	-- Keys of a raw lhs: a special key is 3 bytes (0x80 ..), a modifier prefix 3 more.
	local function keys(raw)
		local out = {}
		local i = 1
		while i <= #raw do
			local j = i
			if raw:byte(j) == 0x80 then
				if raw:byte(j + 1) == 252 then -- KS_MODIFIER: the key follows
					j = j + 3
				end
				if raw:byte(j) == 0x80 then
					j = j + 2
				else
					j = j + vim.str_utf_end(raw, j)
				end
			else
				j = j + vim.str_utf_end(raw, j)
			end
			table.insert(out, raw:sub(i, j))
			i = j + 1
		end
		return out
	end

	---@return table<string, boolean> raw lhs of the which-key groups
	local function groups()
		local out = {}
		for _, m in ipairs(require('which-key.config').mappings) do
			-- preset/plugin: which-key's own labels for built-in keys (g, z, marks, registers)
			if m.group and m.lhs and not m.preset and not m.plugin then
				out[vim.keycode(m.lhs)] = true
			end
		end
		return out
	end

	---@param modes string[]
	---@return table<string, boolean> raw lhs of the global mappings
	local function mapped(modes)
		local out = {}
		for _, mode in ipairs(modes) do
			for _, m in ipairs(vim.api.nvim_get_keymap(mode)) do
				out[vim.keycode(m.lhs)] = true
			end
		end
		return out
	end

	---Groups with nothing mapped under them.
	_G.empty_groups = function()
		local maps = mapped({ 'n', 'x', 's', 'o', 'i', 'c', 't' })
		local out = {}
		for g in pairs(groups()) do
			local used = false
			for lhs in pairs(maps) do
				if #lhs > #g and vim.startswith(lhs, g) then
					used = true
					break
				end
			end
			if not used then
				table.insert(out, vim.fn.keytrans(g))
			end
		end
		table.sort(out)
		return out
	end

	---<leader> prefixes with 2+ mappings under them, no group and no mapping of their own.
	_G.unlabelled_prefixes = function()
		local leader = vim.keycode('<Leader>')
		local maps = mapped({ 'n', 'x' })
		local grp = groups()
		local count = {}
		for lhs in pairs(maps) do
			if vim.startswith(lhs, leader) then
				local k = keys(lhs:sub(#leader + 1))
				local prefix = leader
				for n = 1, #k - 1 do
					prefix = prefix .. k[n]
					count[prefix] = (count[prefix] or 0) + 1
				end
			end
		end
		local out = {}
		for prefix, n in pairs(count) do
			if n >= 2 and not grp[prefix] and not maps[prefix] then
				table.insert(out, vim.fn.keytrans(prefix) .. ' (' .. n .. ')')
			end
		end
		table.sort(out)
		return out
	end
]==]

local function note(title, list)
	if #list == 0 then
		return
	end
	MiniTest.add_note(title .. ': ' .. table.concat(list, ', '))
end

-- Groups whose keys are buffer-local, so empty here (keytrans form, as empty_groups() returns).
local BUFFER_GROUPS = {
	['<Space>cA'] = 'lua/genja/map-lsp.lua, PHP',
	['<Space>cW'] = 'lua/genja/map-lsp.lua',
	['<Space>cc'] = 'lua/genja/map-lsp.lua',
	['<Space>cd'] = 'lua/genja/map-lsp.lua',
	['<Space>mf'] = 'after/ftplugin/markdown.vim',
	['gS'] = 'lua/genja/map-oil.lua',
}

T['groups: each has a mapping under it'] = function()
	local empty = {}
	for _, g in ipairs(child.lua([[return empty_groups()]])) do
		if not BUFFER_GROUPS[g] then
			table.insert(empty, g)
		end
	end
	note('which-key groups with no mapping', empty)
end

T['groups: <leader> prefixes with 2+ mappings have one'] = function()
	note('<leader> prefixes without a group', child.lua([[return unlabelled_prefixes()]]))
end

return T
