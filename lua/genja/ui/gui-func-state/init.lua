-- nvim-qt shim state: one function per Gui* name, each returns that function's singleton.
--   require('genja.ui.gui-func-state').GuiWindowFrameless():advance()
-- Every caller gets the same objects: GuiFuncs picker (mylunsj/gui-funcs), <leader>mQ keys
-- (map-plugin/neovim-gui-shim.lua), right-click menu (popup-menu.lua).

local SRC = 'lua/genja/ui/gui-func-state.lua: '

---@class genja.GuiFunc
---@field name string shim command or function
---@field kind 'option'|'window'|'cycle'|'range'|'action'|'call'|'font'
---@field value? boolean|string|number current value (the shim can't read most back)
---@field var? string g: variable the GUI sets (window kind, GuiLinespace); read at creation, window kind also before each flip
---@field gui_seen? any the g: variable's value at our last read or set
---@field values? string[] cycle kind: the values in order; nil = discover on first use
---@field min? number range kind
---@field max? number range kind
---@field step? number range kind
---@field desc? string
local GuiFunc = {}
GuiFunc.__index = GuiFunc

local M = {}

---@type table<string, genja.GuiFunc>
local made = {}

-- Singleton per name; the GUI's g: variable, when set, wins over the ginit.vim start value.
---@param fields genja.GuiFunc
---@return genja.GuiFunc
local function once(fields)
	local existing = made[fields.name]
	if existing then
		return existing
	end
	local f = setmetatable(fields, GuiFunc)
	if f.var and vim.g[f.var] ~= nil then
		f.gui_seen = vim.g[f.var]
		if f.kind == 'window' then
			f.value = vim.g[f.var] == 1
		else
			f.value = vim.g[f.var]
		end
	end
	made[f.name] = f
	return f
end

---@return boolean
function GuiFunc:available()
	if self.kind == 'font' then
		return vim.fn.exists(':GuiFont') == 2
	end
	if self.kind == 'window' or self.kind == 'call' then
		return vim.fn.exists('*' .. self.name) == 1
	end
	return vim.fn.exists(':' .. self.name) == 2
end

---@return string
function GuiFunc:text()
	if self.kind == 'option' or self.kind == 'window' then
		if self.value then
			return 'on'
		end
		return 'off'
	end
	if self.kind == 'range' then
		if (self.step or 1) < 1 then
			return string.format('%.2f', self.value)
		end
		return tostring(self.value)
	end
	if self.kind == 'cycle' then
		return tostring(self.value)
	end
	return self.desc or ''
end

-- Window kind: take the GUI's g: variable when it changed since our last read or set
-- (title-bar button, OS shortcut). Unchanged means the GUI hasn't caught up with our
-- last set yet (it updates the variable a moment later), so our value stands.
function GuiFunc:read_gui()
	local v = vim.g[self.var]
	if v == nil or v == self.gui_seen then
		return
	end
	self.gui_seen = v
	self.value = v == 1
end

---@param value boolean|string|number
function GuiFunc:set(value)
	self.value = value
	if self.kind == 'window' then
		self.gui_seen = vim.g[self.var]
		local n = 0
		if value and value == 1 then n = 1 end
		if value and value == 0 then n = 0 end

		vim.call(self.name, n)
	elseif self.kind == 'option' then
		local n = 0
		if value then
			n = 1
		end
		vim.cmd(self.name .. ' ' .. n)
	elseif self.kind == 'range' then
		vim.cmd(self.name .. ' ' .. self:text())
	elseif self.kind == 'cycle' then
		vim.cmd(self.name .. ' ' .. value)
	end
end

-- nvim-qt answers :GuiAdaptiveStyleList later with `echo "a\nb"` over RPC.
-- A redir variable fills only at `redir END`, so each tick ends it, reads, and starts again.
---@return string[]
local function discover_styles()
	local out = ''
	vim.cmd('redir => g:mylunsj_gui_styles')
	vim.cmd('GuiAdaptiveStyleList')
	vim.wait(1000, function()
		vim.cmd('redir END')
		out = vim.g.mylunsj_gui_styles or ''
		if out:match('%S') then return true end
		vim.cmd('redir => g:mylunsj_gui_styles')
		return false
	end, 50)
	vim.cmd('silent! redir END')
	vim.g.mylunsj_gui_styles = nil

	local styles = {}
	for _, line in ipairs(vim.split(out, '\n', { trimempty = true })) do
		local name = vim.trim(line)
		if name ~= '' then
			table.insert(styles, name)
		end
	end
	return styles
end

---@return string[]
function GuiFunc:cycle_values()
	if not self.values or #self.values == 0 then
		self.values = discover_styles()
		if #self.values == 0 then
			vim.notify(SRC .. 'no styles from :GuiAdaptiveStyleList', vim.log.levels.WARN)
		end
	end
	return self.values
end

-- Next value: booleans flip, cycles and ranges wrap around to the first value; actions run.
function GuiFunc:advance()
	if not self:available() then
		vim.notify(SRC .. self.name .. ' not defined (not nvim-qt?)', vim.log.levels.WARN)
		return
	end
	if self.kind == 'window' then
		self:read_gui()
	end
	if self.kind == 'option' or self.kind == 'window' then
		self:set(not self.value)
		return
	end
	if self.kind == 'cycle' then
		local values = self:cycle_values()
		if #values == 0 then
			return
		end
		local index = 1
		for i, v in ipairs(values) do
			if v == self.value then
				index = i % #values + 1
			end
		end
		self:set(values[index])
		return
	end
	if self.kind == 'range' then
		-- Count in whole steps so 0.05 doesn't drift.
		local min = self.min or 0
		local max = self.max or 0
		local step = self.step or 1
		local steps = math.floor((self.value - min) / step + 0.5) + 1
		local value = min + steps * step
		if value > max + step / 2 then
			value = min
		end
		self:set(value)
		return
	end
	if self.kind == 'font' then
		vim.cmd('set guifont=*')
		return
	end
	if self.kind == 'call' then
		vim.call(self.name)
		return
	end
	vim.cmd(self.name)
end

-- Start values match ginit.vim.

function M.GuiWindowFrameless()  return once({ name = 'GuiWindowFrameless',  kind = 'window', value = true,  var = 'GuiWindowFrameless' }) end
function M.GuiWindowMaximized()  return once({ name = 'GuiWindowMaximized',  kind = 'window', value = false, var = 'GuiWindowMaximized' }) end
function M.GuiWindowFullScreen() return once({ name = 'GuiWindowFullScreen', kind = 'window', value = false, var = 'GuiWindowFullScreen' }) end
function M.GuiMousehide()        return once({ name = 'GuiMousehide',        kind = 'window', value = true,  var = 'GuiMousehide' }) end

function M.GuiTabline()          return once({ name = 'GuiTabline',          kind = 'option', value = false }) end
function M.GuiTablineBuffers()   return once({ name = 'GuiTablineBuffers',   kind = 'option', value = false }) end
function M.GuiPopupmenu()        return once({ name = 'GuiPopupmenu',        kind = 'option', value = false }) end
function M.GuiScrollBar()        return once({ name = 'GuiScrollBar',        kind = 'option', value = false }) end
function M.GuiRenderLigatures()  return once({ name = 'GuiRenderLigatures',  kind = 'option', value = false }) end
function M.GuiRenderFontAttr()   return once({ name = 'GuiRenderFontAttr',   kind = 'option', value = true }) end
function M.GuiAdaptiveColor()    return once({ name = 'GuiAdaptiveColor',    kind = 'option', value = true }) end
function M.GuiAdaptiveFont()     return once({ name = 'GuiAdaptiveFont',     kind = 'option', value = false }) end

function M.GuiFont()             return once({ name = 'GuiFont',             kind = 'font',   desc = 'font picker (set guifont=*)' }) end
function M.GuiAdaptiveStyle()    return once({ name = 'GuiAdaptiveStyle',    kind = 'cycle',  value = 'Fusion' }) end

function M.GuiLinespace()        return once({ name = 'GuiLinespace',        kind = 'range',  value = 0,   var = 'GuiLinespace', min = 0, max = 5, step = 1 }) end
function M.GuiWindowOpacity()    return once({ name = 'GuiWindowOpacity',    kind = 'range',  value = 1.0, min = 0, max = 1, step = 0.05 }) end

function M.GuiTreeviewToggle()   return once({ name = 'GuiTreeviewToggle',   kind = 'action', desc = 'file tree side panel' }) end
function M.GuiAdaptiveStyleList() return once({ name = 'GuiAdaptiveStyleList', kind = 'action', desc = 'echo the Qt styles' }) end

function M.GuiTreeviewShow() return once({ name = 'GuiTreeviewShow', kind = 'action' }) end
function M.GuiTreeviewHide() return once({ name = 'GuiTreeviewHide', kind = 'action' }) end


-- Raise the GUI window to the front and focus it.
function M.GuiForeground() return once({ name = 'GuiForeground', kind = 'call' }) end

-- Close the GUI window (quits this nvim-qt).
function M.GuiClose() return once({ name = 'GuiClose', kind = 'call' }) end

-- Start another nvim-qt window; takes the command line args as one string, so needs a prompt.
function M.GuiNewWindow() return once({ name = 'GuiNewWindow', kind = 'call' }) end

-- Open the right-click menu (cut, copy, paste, select all) at the mouse position.
function M.GuiShowContextMenu() return once({ name = 'GuiShowContextMenu', kind = 'call' }) end

-- Open files dropped on the window; takes file names, so it needs a file prompt.
function M.GuiDrop() return once({ name = 'GuiDrop', kind = 'call' }) end

-- Return the GUI's name ('nvim-qt'); would show it in a notification.
function M.GuiName() return once({ name = 'GuiName', kind = 'call' }) end

-- Set the clipboard provider to the GUI's own clipboard (no xclip/win32yank needed).
-- function M.GuiClipboard() return once({ name = 'GuiClipboard', kind = 'call' }) end

---All singletons in picker order.
---@return genja.GuiFunc[]
function M.all()
	return {
		M.GuiFont(),
		M.GuiWindowFrameless(),
		M.GuiWindowMaximized(),
		M.GuiWindowFullScreen(),
		M.GuiMousehide(),
		M.GuiTabline(),
		M.GuiTablineBuffers(),
		M.GuiPopupmenu(),
		M.GuiScrollBar(),
		M.GuiRenderLigatures(),
		M.GuiRenderFontAttr(),
		M.GuiAdaptiveColor(),
		M.GuiAdaptiveFont(),
		M.GuiAdaptiveStyle(),
		M.GuiLinespace(),
		M.GuiWindowOpacity(),
		M.GuiTreeviewToggle(),
		M.GuiAdaptiveStyleList(),
		-- M.GuiTreeviewShow(),
		-- M.GuiTreeviewHide(),
		-- M.GuiForeground(),
		-- M.GuiClose(),
		-- M.GuiNewWindow(),
		-- M.GuiShowContextMenu(),
		-- M.GuiDrop(),
		-- M.GuiName(),
		-- M.GuiClipboard(),
	}
end

-- exposed for gui-funcs/test_state.lua
M._discover_styles = discover_styles

return M
