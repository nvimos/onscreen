-- Keys for lua/lazyp/new/dial.lua.
-- The group is picked per filetype (vim.b.dial_group overrides), as in LazyVim's dial extra.

-- filetype -> group registered in the spec; others use 'default'
---@type table<string, string>
local group_by_ft = {
	lua = 'lua',
	typescript = 'typescript',
	typescriptreact = 'typescript',
	javascript = 'typescript',
	javascriptreact = 'typescript',
	go = 'go',
	php = 'php',
	css = 'css',
	scss = 'css',
	markdown = 'markdown',
	yaml = 'yaml',
	['yaml.ansible'] = 'yaml',
	json = 'json',
	jsonc = 'json',
}

---@param increment boolean
---@param mode 'normal'|'gnormal'|'visual'|'gvisual'
---@return fun()
local function dial(increment, mode)
	return function()
		local group = vim.b.dial_group or group_by_ft[vim.bo.filetype] or 'default'
		local direction = 'decrement'
		if increment then
			direction = 'increment'
		end
		require('dial.map').manipulate(direction, mode, group)
	end
end

---@param Maps genja.MapPlugin
return function(Maps)
	local spec_name = Maps.current_file()

	Maps:add_keys(spec_name, {
		{ '<C-a>', dial(true, 'normal'), desc = 'Dial: increment' },
		{ '<C-x>', dial(false, 'normal'), desc = 'Dial: decrement' },
		{ 'g<C-a>', dial(true, 'gnormal'), desc = 'Dial: increment, dot repeats to next' },
		{ 'g<C-x>', dial(false, 'gnormal'), desc = 'Dial: decrement, dot repeats to next' },
		{ '<C-a>', dial(true, 'visual'), mode = 'x', desc = 'Dial: increment selection' },
		{ '<C-x>', dial(false, 'visual'), mode = 'x', desc = 'Dial: decrement selection' },
		{ 'g<C-a>', dial(true, 'gvisual'), mode = 'x', desc = 'Dial: increment selection, progressive' },
		{ 'g<C-x>', dial(false, 'gvisual'), mode = 'x', desc = 'Dial: decrement selection, progressive' },
	})
end
