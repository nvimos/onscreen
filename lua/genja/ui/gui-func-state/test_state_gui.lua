-- lua/genja/ui/gui-func-state.lua against a real nvim-qt: `make test-gui` starts nvim-qt with this file.
-- run_gui.lua writes the report to gui-report.txt and quits. Outside a GUI every case is skipped.

local eq = MiniTest.expect.equality
local GuiFuncState = require('genja.ui.gui-func-state')

local T = MiniTest.new_set({
	hooks = {
		pre_case = function()
			if vim.fn.has('gui_running') ~= 1 then
				MiniTest.skip('no GUI attached; run with make test-gui')
			end
			-- --noplugin skips the shim; nvim-qt puts its runtime on the rtp
			if vim.fn.exists(':GuiAdaptiveStyleList') ~= 2 then
				vim.cmd('runtime! plugin/nvim_gui_shim.vim')
			end
			if vim.fn.exists(':GuiAdaptiveStyleList') ~= 2 then
				MiniTest.skip('nvim_gui_shim.vim not on the runtimepath')
			end
		end,
	},
})

T['discover_styles'] = MiniTest.new_set()

T['discover_styles']['gets a list of names from nvim-qt'] = function()
	local styles = GuiFuncState._discover_styles()
	eq(type(styles), 'table')
	eq(vim.islist(styles), true)
	eq(#styles > 0, true)
	for _, name in ipairs(styles) do
		eq(type(name), 'string')
		eq(name:match('^%S+$') ~= nil, true)
	end
end

-- Qt ships Fusion on every platform.
T['discover_styles']['includes Fusion'] = function()
	eq(vim.tbl_contains(GuiFuncState._discover_styles(), 'Fusion'), true)
end

T['advance'] = MiniTest.new_set()

T['advance']['cycles GuiAdaptiveStyle through the discovered list'] = function()
	local style = GuiFuncState.GuiAdaptiveStyle()
	local start = style.value
	local values = style:cycle_values()
	for _ = 1, #values do
		style:advance()
		eq(vim.tbl_contains(values, style.value), true)
	end
	-- a full round lands back on the start value (when it is in the list)
	if vim.tbl_contains(values, start) then
		eq(style.value, start)
	end
end

return T
