-- Keys for lua/lazyp/ui/zenmode.lua.
--   <leader>z1  width 120, no numbers, frameless; diagnostics off
--   <leader>z2  width 80, relnum, colorcolumn 4,8,80, frameless + maximized; diagnostics off
--   <leader>z0  close; frameless and maximized off, window size as before z1/z2;
--               diagnostics back on (unless off before zen) with the default limit of 3
-- z1 <-> z2 while zen is open: zen closes first, an open zen window would keep its old width.

local function gui()
	return require('genja.ui.gui-func-state')
end

---What z1/z2 changed, saved before the first of them; nil while zen is off.
---@type { columns: integer, lines: integer, diag_enabled: boolean, maximized: boolean }|nil
local before = nil

---Remember the size and whether diagnostics are on, before the first z1/z2.
local function remember()
	if before then
		return
	end
	before = { columns = vim.o.columns, lines = vim.o.lines, diag_enabled = vim.diagnostic.is_enabled(), maximized = false }
end

---Open zen with this width, closing an open zen window first.
---@param width number
---@param options table window options inside zen mode
local function zen(width, options)
	local zen_mode = require('zen-mode')
	if require('zen-mode.view').is_open() then
		zen_mode.close()
	end
	zen_mode.setup({ window = { width = width, options = options } })
	zen_mode.open()
end

-- nvim-qt recreates the window on a frameless change; a maximize call right after it loses the
-- size to restore (2026-11-05: Frameless(0) | Maximized(0) on one line stays maximized).
-- So the second of the two calls waits this long.
local GUI_SETTLE_MS = 150

---Maximize on (z2) or off (z1, z0); off only when zen turned it on.
---@param on boolean
local function maximized(on)
	if on then
		-- z0 within GUI_SETTLE_MS of z2: zen is off already, stay unmaximized.
		if not before then
			return
		end
		gui().GuiWindowMaximized():set(1)
		before.maximized = true
	elseif before and before.maximized then
		gui().GuiWindowMaximized():set(0)
		before.maximized = false
	end
end

local function zen_off()
	vim.wo.wrap = false
	vim.wo.number = false
	vim.wo.relativenumber = false
	vim.opt.colorcolumn = '0'

	require('zen-mode').close()
	if before then
		-- Un-maximize while still frameless, frameless off after: see GUI_SETTLE_MS.
		maximized(false)
		vim.defer_fn(function() gui().GuiWindowFrameless():set(0) end, GUI_SETTLE_MS)
		vim.o.columns = before.columns
		vim.o.lines = before.lines
		-- nil: the default limit (3); set() redraws, enable() shows them again
		require('genja.ext.diag-limit').set(nil)
		vim.diagnostic.enable(before.diag_enabled)
		before = nil
	else
		gui().GuiWindowFrameless():set(0)
	end
end

local function zen_wide()
	remember()
	vim.wo.wrap = false
	vim.wo.number = false
	vim.wo.relativenumber = false
	vim.opt.colorcolumn = '0'
	gui().GuiWindowFrameless():set(1)
	vim.defer_fn(function() maximized(false) end, GUI_SETTLE_MS)
	vim.diagnostic.enable(false)

	zen(120, {})
end

local function zen_relnum()
	remember()
	vim.wo.wrap = false
	vim.wo.number = true
	vim.wo.relativenumber = true
	vim.opt.colorcolumn = '4,8,80'
	gui().GuiWindowFrameless():set(1)
	vim.defer_fn(function() maximized(true) end, GUI_SETTLE_MS)
	vim.diagnostic.enable(false)

	zen(80, {})
end

---@param Maps genja.MapPlugin
return function(Maps)
	local spec_name = Maps.current_file()

	Maps:add_keys(spec_name, {
		{ '<leader>mz', '<cmd>ZenMode<cr>', silent = true, desc = 'UI: toggle zen mode' },
		{ '<leader>z0', zen_off, desc = 'Zen: off, size as before, diagnostics on' },
		{ '<leader>z1', zen_wide, desc = 'Zen: on, width 120, no diagnostics' },
		{ '<leader>z2', zen_relnum, desc = 'Zen: on, width 80, relnum, maximized, no diagnostics' },
	})
end
