-- Keys for lua/lazyp/ui/zenmode.lua.



---Reconfigure zen-mode for this width, then toggle it.
---@param width number
---@param options table window options inside zen mode
local function zen(width, options)
	local zen_mode = require('zen-mode')
	zen_mode.setup({ window = { width = width, options = options } })
	zen_mode.open()
end


local function zen_off()
	vim.wo.wrap = false
	vim.wo.number = false
	vim.wo.relativenumber = false
	vim.opt.colorcolumn = '0'

	require('zen-mode').close()
	require('genja.ui.gui-func-state').GuiWindowFrameless():set(0)
end

local function zen_wide()
	-- todo: needs work
	vim.wo.wrap = false
	vim.wo.number = false
	vim.wo.relativenumber = false
	vim.opt.colorcolumn = '0'
	require('genja.ui.gui-func-state').GuiWindowFrameless():set(1)
	-- require('genja.ui.gui-func-state').GuiWindowMaximized():set(1)

	zen(120, {})
end

local function zen_relnum()
	-- todo: needs work
	vim.wo.wrap = false
	vim.wo.number = true
	vim.wo.relativenumber = true
	vim.opt.colorcolumn = '4,8,80'
	require('genja.ui.gui-func-state').GuiWindowFrameless():set(1)
	require('genja.ui.gui-func-state').GuiWindowMaximized():set(1)

	zen(80, {})
end

---@param Maps genja.MapPlugin
return function(Maps)
	local spec_name = Maps.current_file()

	Maps:add_keys(spec_name, {
		{ '<leader>mz', '<cmd>ZenMode<cr>', silent = true, desc = 'UI: toggle zen mode' },
		{ '<leader>z0', zen_off, desc = 'Zen: off' },
		{ '<leader>z1', zen_wide, desc = 'Zen: on, width 120' },
		{ '<leader>z2', zen_relnum, desc = 'Zen: on, width 80, relnum' },
	})
end
