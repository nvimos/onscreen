-- vim: foldmethod=marker foldlevel=0
-- focus.nvim ships no LuaLS types for its config; these mirror Focus.config in lua/focus/init.lua.

local Maps = require('genja.map-plugin')

-- {{{ docs
---@class FocusAutoresizeOpts
---@field enable? boolean resize splits on WinEnter
---@field width? integer force width of the focused window (0 = golden ratio)
---@field height? integer force height of the focused window (0 = golden ratio)
---@field minwidth? integer
---@field minheight? integer
---@field focusedwindow_minwidth? integer
---@field focusedwindow_minheight? integer
---@field height_quickfix? integer
---@field equalise_min_cols? integer use equal splits when columns >= this (0 = off)
---@field equalise_min_rows? integer use equal splits when lines >= this (0 = off)

---@class FocusSplitOpts
---@field bufnew? boolean
---@field tmux? boolean

---@class FocusColorcolumnOpts
---@field enable? boolean
---@field list? string

---@class FocusUiOpts
---@field number? boolean
---@field relativenumber? boolean
---@field hybridnumber? boolean
---@field absolutenumber_unfocussed? boolean
---@field cursorline? boolean
---@field cursorcolumn? boolean
---@field colorcolumn? FocusColorcolumnOpts
---@field signcolumn? boolean
---@field winhighlight? boolean

---@class FocusOpts
---@field enable? boolean
---@field commands? boolean
---@field autoresize? FocusAutoresizeOpts
---@field split? FocusSplitOpts
---@field ui? FocusUiOpts

-- }}}

-- {{{ excluded buf and filetypes
-- focus has no exclude option; it skips buffers with vim.b.focus_disable set.
local excluded_buftypes = {
	'terminal', -- floaterm, :terminal
	'nofile',   -- plugin panels and scratch buffers
	'prompt',
}

-- oil is buftype 'acwrite', which also covers other write-handled buffers, so match it by filetype.
local excluded_filetypes = {
	'oil',
}
-- }}}

---Autocmd callback: mark the buffer so focus leaves its windows alone. {{{
---@param ev vim.api.keyset.create_autocmd.callback_args
local function disable_focus_for_excluded(ev)
	if false
		or vim.tbl_contains(excluded_buftypes, vim.bo[ev.buf].buftype)
		or vim.tbl_contains(excluded_filetypes, vim.bo[ev.buf].filetype)
	then
		vim.b[ev.buf].focus_disable = true
	end
end
-- }}}


-- {{{ Wire excluded types
local function wire_excluded_types_autocmd(_, o)
	-- Created before setup() so it runs ahead of focus's own WinEnter resize.
	vim.api.nvim_create_autocmd({ 'BufWinEnter', 'FileType', 'TermOpen', 'WinEnter' }, {
		group = vim.api.nvim_create_augroup('PluginFocusLuaExclude', { clear = true }),
		callback = disable_focus_for_excluded,
		desc = 'focus.lua: disable focus for excluded buftypes and wintypes',
	})
	require('focus').setup(o)
	-- After setup(): set before, setup() skips its WinEnter autocmd and focus can never turn on.
	vim.g.focus_disable = true -- off by default; focus reads this on every resize
end
-- }}}

---@type FocusOpts
local focus_opts = {
	enable = true,
	autoresize = {
		enable = true,
		width = 0,
		height = 0,
	},
	ui = {
		signcolumn = false,
	},
}

---@type LazySpec
return {
	'beauwilliams/focus.nvim',
	enabled = true,
	event = { "VimEnter", "WinNew", "WinEnter" },
	keys = Maps:keys(),
	opts = focus_opts,
	config = wire_excluded_types_autocmd,
}
