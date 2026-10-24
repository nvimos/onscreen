-- Keys for lua/lazyp/ui-gui/neovim-gui-shim.lua: <leader>mQ toggles nvim-qt GUI options.
-- Same singletons as the GuiFuncs picker and the right-click menu (lua/genja/ui/gui-func-state.lua).

local SRC = 'lua/genja/map-plugin/neovim-gui-shim.lua: '

local GuiFuncState = require('genja.ui.gui-func-state')

---@param func fun(): genja.GuiFunc one of GuiFuncState's Gui* functions
---@return fun()
local function toggle(func)
	return function()
		local f = func()
		if not f:available() then
			vim.notify(SRC .. f.name .. ' not defined (not nvim-qt?)', vim.log.levels.WARN)
			return
		end
		f:advance()
		vim.notify(SRC .. f.name .. ' ' .. f:text())
	end
end

---@param Maps genja.MapPlugin
return function(Maps)
	local spec_name = Maps.current_file()

	Maps:add_keys(spec_name, {
		{ '<leader>mQt', toggle(GuiFuncState.GuiTabline),          desc = 'GUI: tabline toggle' },
		{ '<leader>mQb', toggle(GuiFuncState.GuiTablineBuffers),   desc = 'GUI: tabline buffers toggle' },
		{ '<leader>mQp', toggle(GuiFuncState.GuiPopupmenu),        desc = 'GUI: popupmenu toggle' },
		{ '<leader>mQs', toggle(GuiFuncState.GuiScrollBar),        desc = 'GUI: scrollbar toggle' },
		{ '<leader>mQe', '<cmd>GuiTreeviewToggle<cr>',           desc = 'GUI: treeview toggle' },
		{ '<leader>mQl', toggle(GuiFuncState.GuiRenderLigatures),  desc = 'GUI: render ligatures toggle' },
		{ '<leader>mQa', toggle(GuiFuncState.GuiRenderFontAttr),   desc = 'GUI: render bold/italic toggle' },
		{ '<leader>mQc', toggle(GuiFuncState.GuiAdaptiveColor),    desc = 'GUI: adaptive color toggle' },
		{ '<leader>mQf', toggle(GuiFuncState.GuiAdaptiveFont),     desc = 'GUI: adaptive font toggle' },
		{ '<leader>mQF', toggle(GuiFuncState.GuiWindowFullScreen), desc = 'GUI: window fullscreen toggle' },
		{ '<leader>mQm', toggle(GuiFuncState.GuiWindowMaximized),  desc = 'GUI: window maximized toggle' },
		{ '<leader>mQw', toggle(GuiFuncState.GuiWindowFrameless),  desc = 'GUI: window frameless toggle' },
		{ '<leader>mQh', toggle(GuiFuncState.GuiMousehide),        desc = 'GUI: mouse hide toggle' },
	})
end
