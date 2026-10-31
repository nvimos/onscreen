-- Terminal-mode cursor: no blink, bar or block, in the StatusLine color. Terminal windows: scrolloff 0,
-- terminal mode on enter. Leave a terminal, toggle a floaterm, save sessions with idle shells.
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

-- Terminal windows: scrolloff 0. Apps like claude move the cursor up to redraw; with a
-- scrolloff nvim scrolls the window after it, and the view jitters.
vim.api.nvim_create_autocmd({ 'TermOpen', 'BufWinEnter' }, {
	group = vim.api.nvim_create_augroup('genja_term_scrolloff', { clear = true }),
	callback = function(ev)
		if vim.bo[ev.buf].buftype == 'terminal' then
			vim.opt_local.scrolloff = 0
		end
	end,
	desc = 'Terminal windows: scrolloff 0, no view jumps while the app redraws',
})

-- Entering a terminal window starts terminal mode, so jumping in needs no `i`.
-- Only while the job runs: a finished job's buffer would close on the first key.
vim.api.nvim_create_autocmd({ 'WinEnter', 'BufEnter' }, {
	group = vim.api.nvim_create_augroup('genja_term_insert', { clear = true }),
	callback = function(ev)
		if vim.bo[ev.buf].buftype ~= 'terminal' then
			return
		end
		local chan = vim.bo[ev.buf].channel
		if chan > 0 and vim.fn.jobwait({ chan }, 0)[1] == -1 then
			vim.cmd.startinsert()
		end
	end,
	desc = 'Terminal windows: terminal mode on enter',
})

local FLOAT_NAME = 'generic'

-- Toggle one floaterm named FLOAT_NAME; create it on first use.
-- :FloatermToggle with an unknown name only errors, so look for its buffer first.
function M.toggle_float()
	for _, buf in ipairs(vim.api.nvim_list_bufs()) do
		if vim.api.nvim_buf_is_valid(buf) and vim.b[buf].floaterm_name == FLOAT_NAME then
			vim.cmd('FloatermToggle ' .. FLOAT_NAME)
			return
		end
	end
	vim.cmd('FloatermNew --name=' .. FLOAT_NAME)
end

-- Leave the window: to the previous window in the tab, else the next tab, else a new tab.
function M.jump_out()
	local cur = vim.api.nvim_get_current_win()
	local others = 0
	for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
		if win ~= cur and vim.api.nvim_win_get_config(win).relative == '' then
			others = others + 1
		end
	end
	if others > 0 then
		local prev = vim.fn.win_getid(vim.fn.winnr('#'))
		if prev ~= 0 and prev ~= cur then
			vim.api.nvim_set_current_win(prev)
		else
			vim.cmd.wincmd('w')
		end
		return
	end
	if #vim.api.nvim_list_tabpages() > 1 then
		vim.cmd.tabnext()
	else
		vim.cmd.tabnew()
	end
end

-- Program name of a command line: first word (or quoted path), no dir, no .exe, lowercase.
---@param cmdline string
---@return string
local function exe_name(cmdline)
	local s = vim.trim(cmdline)
	local exe = s:match('^"([^"]+)"') or s:match('^(%S+)') or ''
	return vim.fn.fnamemodify(exe, ':t:r'):lower()
end

-- Shell for a bare :terminal: pwsh on Windows, bash elsewhere; nil when not installed.
-- 'shell' stays cmd.exe / $SHELL: system(), :!, shellescape() and os.execute callers expect it.
---@return string|nil
function M.term_shell()
	if vim.fn.has('win32') == 1 then
		if vim.fn.executable('pwsh') == 1 then
			return 'pwsh'
		end
		if vim.fn.executable('powershell') == 1 then
			return 'powershell'
		end
		return nil
	end
	if vim.fn.executable('bash') == 1 then
		return 'bash'
	end
	return nil
end

-- :vert, :tab, :bot … in front of :terminal
local MODIFIERS = { 'vertical', 'horizontal', 'tab', 'botright', 'topleft', 'aboveleft', 'belowright',
	'leftabove', 'rightbelow' }

---@param word string
---@param full string
---@param min integer shortest accepted abbreviation
---@return boolean
local function is_abbrev(word, full, min)
	return #word >= min and vim.startswith(full, word)
end

-- Cmdline with term_shell() added when it is a bare :te[rminal] (modifiers allowed); else nil.
---@param line string
---@return string|nil
function M.bare_terminal(line)
	local words = vim.split(vim.trim(line), '%s+', { trimempty = true })
	local last = table.remove(words)
	if last == nil or not is_abbrev(last, 'terminal', 2) then
		return nil
	end
	for _, word in ipairs(words) do
		local known = false
		for _, mod in ipairs(MODIFIERS) do
			if is_abbrev(word, mod, 2) then
				known = true
			end
		end
		if not known then
			return nil
		end
	end
	local shell = M.term_shell()
	if shell == nil then
		return nil
	end
	return vim.trim(line) .. ' ' .. shell
end

-- Keys for the cmdline <CR> map (lua/genja/abbreviations.vim): a bare :terminal gets term_shell().
---@return string
function M.cmdline_cr()
	local line = M.bare_terminal(vim.fn.getcmdline())
	if line == nil then
		return vim.keycode('<C-]><CR>')
	end
	return vim.keycode('<C-u>') .. line .. vim.keycode('<CR>')
end

-- nvim's own process list; works on every OS below, until one needs its own check.
---@param pid integer
---@return boolean|nil
local function api_has_children(pid)
	local ok, children = pcall(vim.api.nvim_get_proc_children, pid)
	if not ok then
		return nil
	end
	return #children > 0
end

-- Does pid have child processes? One branch per OS: only tested on Windows 11; the others use
-- the same API untested and may need their own check (e.g. pgrep -P, ps), so each has a slot.
-- nil: unknown, the terminal counts as busy.
---@param pid integer
---@return boolean|nil
local function has_children(pid)
	local sysname = vim.uv.os_uname().sysname
	if sysname == 'Windows_NT' then
		return api_has_children(pid)
	elseif sysname == 'Linux' then
		return api_has_children(pid)
	elseif sysname == 'Darwin' then
		return api_has_children(pid)
	elseif sysname:match('BSD$') then
		return api_has_children(pid)
	end
	return nil
end

-- A terminal running 'shell' with no child process: safe to save, its restart loses nothing.
---@param buf integer
---@return boolean
local function is_idle_shell(buf)
	local chan = vim.bo[buf].channel
	if chan <= 0 or vim.fn.jobwait({ chan }, 0)[1] ~= -1 then
		return false
	end
	-- name: term://{cwd}//{pid}:{cmd}
	local cmd = vim.api.nvim_buf_get_name(buf):match('^term://.-//%d+:(.*)$')
	if cmd == nil then
		return false
	end
	local name = exe_name(cmd)
	if name ~= exe_name(vim.o.shell) and name ~= M.term_shell() then
		return false
	end
	return has_children(vim.fn.jobpid(chan)) == false
end

-- :mksession! that keeps idle shell terminals; they come back as new shells in their start dir.
-- Other terminals: their windows show a blank buffer while saving (layout stays), then get it back.
---@param path string session file
function M.mksession(path)
	local swapped = {} ---@type table<integer, integer> window -> terminal buffer
	local unlisted = {} ---@type integer[]
	for _, buf in ipairs(vim.api.nvim_list_bufs()) do
		if vim.bo[buf].buftype == 'terminal' and not is_idle_shell(buf) then
			for _, win in ipairs(vim.fn.win_findbuf(buf)) do
				if vim.api.nvim_win_get_config(win).relative == '' then
					swapped[win] = buf
				end
			end
			if vim.bo[buf].buflisted then
				table.insert(unlisted, buf)
			end
		end
	end

	local blank = vim.api.nvim_create_buf(false, true)
	local ssop = vim.o.sessionoptions
	local ei = vim.o.eventignore
	-- no autocmds: floaterm's BufHidden hook would close the window
	vim.o.eventignore = 'all'
	for win in pairs(swapped) do
		vim.api.nvim_win_set_buf(win, blank)
	end
	for _, buf in ipairs(unlisted) do
		vim.bo[buf].buflisted = false
	end
	vim.opt.sessionoptions:append('terminal')

	local ok, err = pcall(vim.cmd.mksession, { vim.fn.expand(path), bang = true })

	vim.o.sessionoptions = ssop
	for win, buf in pairs(swapped) do
		vim.api.nvim_win_set_buf(win, buf)
	end
	for _, buf in ipairs(unlisted) do
		vim.bo[buf].buflisted = true
	end
	vim.o.eventignore = ei
	vim.api.nvim_buf_delete(blank, { force = true })
	if not ok then
		vim.notify(SRC .. 'mksession failed: ' .. tostring(err), vim.log.levels.ERROR)
	end
end

vim.api.nvim_create_user_command('TermCursorShape', function(args)
	M.set_shape(args.args)
end, {
	nargs = 1,
	complete = function() return vim.tbl_keys(SHAPES) end,
	desc = 'Terminal cursor shape: block or bar',
})

return M
