-- lua/genja/ui/gui-func-state.lua: discover_styles reads the Qt style list nvim-qt echoes back.
-- A fake :GuiAdaptiveStyleList stands in for nvim-qt; runs in the test process.

local eq = MiniTest.expect.equality
local GuiFuncState = require('genja.ui.gui-func-state')

local STYLES = { 'windows11', 'windowsvista', 'Windows', 'Fusion' }

-- nvim-qt sends `echo "a\nb"` (Vimscript newlines) some time after the command.
---@param delay_ms integer|nil nil: echo at once
---@param styles string[]|nil nil: never answer
local function fake_style_list(delay_ms, styles)
	vim.api.nvim_create_user_command('GuiAdaptiveStyleList', function()
		if not styles then
			return
		end
		local echo = 'echo "' .. table.concat(styles, '\\n') .. '"'
		if delay_ms then
			vim.defer_fn(function()
				vim.cmd(echo)
			end, delay_ms)
		else
			vim.cmd(echo)
		end
	end, {})
end

local T = MiniTest.new_set({
	hooks = {
		post_case = function()
			pcall(vim.api.nvim_del_user_command, 'GuiAdaptiveStyleList')
			vim.cmd('silent! redir END')
		end,
	},
})

T['discover_styles'] = MiniTest.new_set()

T['discover_styles']['returns a list from a delayed echo'] = function()
	fake_style_list(200, STYLES)
	local styles = GuiFuncState._discover_styles()
	eq(type(styles), 'table')
	eq(vim.islist(styles), true)
	eq(styles, STYLES)
end

T['discover_styles']['returns a list from an immediate echo'] = function()
	fake_style_list(nil, STYLES)
	eq(GuiFuncState._discover_styles(), STYLES)
end

T['discover_styles']['returns an empty list when the GUI never answers'] = function()
	fake_style_list(nil, nil)
	local styles = GuiFuncState._discover_styles()
	eq(type(styles), 'table')
	eq(#styles, 0)
end

T['discover_styles']['trims names and drops blank lines'] = function()
	fake_style_list(50, { '  Fusion ', '', 'Windows' })
	eq(GuiFuncState._discover_styles(), { 'Fusion', 'Windows' })
end

T['discover_styles']['ends the redir and clears its variable'] = function()
	fake_style_list(50, STYLES)
	GuiFuncState._discover_styles()
	eq(vim.g.mylunsj_gui_styles, nil)
end

return T
