-- Terminal-mode cursor: no blink, bar or block, in the StatusLine color.
local SRC = 'lua/genja/ext/term.lua: '

local M = {}

-- 't:' entries of 'guicursor', picked with :TermCursorShape.
-- blinkon0 only covers nvim's side: since 0.11 the app in the terminal can set its own blink.
local SHAPES = {
	block = 't:block-blinkon0-TermCursor',
	bar = 't:ver25-blinkon0-TermCursor',
}

---@param name string key of SHAPES
function M.set_shape(name)
	local entry = SHAPES[name or '']
	if not entry then
		vim.notify(SRC .. 'unknown shape: ' .. (name or ''), vim.log.levels.WARN)
		return
	end
	-- drop the old terminal-mode entry, keep the other modes
	local kept = vim.tbl_filter(function(part)
		return not vim.startswith(part, 't:')
	end, vim.split(vim.o.guicursor, ',', { trimempty = true }))
	table.insert(kept, entry)
	vim.o.guicursor = table.concat(kept, ',')
end

-- TermCursor bg = StatusLine fg; the char under the cursor in the Normal fg (the TUI ignores guifg)
function M.set_color()
	local sl = vim.api.nvim_get_hl(0, { name = 'StatusLine', link = false })
	if sl.fg == nil then
		vim.notify(SRC .. 'StatusLine has no fg color, TermCursor left as is', vim.log.levels.WARN)
		return
	end
	local normal = vim.api.nvim_get_hl(0, { name = 'Normal', link = false })
	vim.api.nvim_set_hl(0, 'TermCursor', { bg = sl.fg, fg = normal.fg })
end

M.set_shape('block')
M.set_color()

vim.api.nvim_create_autocmd('ColorScheme', {
	group = vim.api.nvim_create_augroup('genja_opt_term', { clear = true }),
	callback = M.set_color,
	desc = 'TermCursor: StatusLine orange again after a colorscheme change',
})

vim.api.nvim_create_user_command('TermCursorShape', function(args)
	M.set_shape(args.args)
end, {
	nargs = 1,
	complete = function() return vim.tbl_keys(SHAPES) end,
	desc = 'Terminal cursor shape: block or bar',
})

return M
