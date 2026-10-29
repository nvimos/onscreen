-- Markdown fixers: typos and markdownlint-cli2 rewrite the file, then the buffer reloads.
-- Leading tabs become spaces first (4 per tab stop, outside code fences); see M.expand_tabs.
-- Then vim key notation in prose gets backticks: <C-x><C-o> -> `<C-x><C-o>`; see M.escape_keys.
--   <leader>mfx   fix this buffer now (after/ftplugin/markdown.vim)
--   on save       the same after every :w, unless vim.g.md_fix_on_save = false
--                 <leader>tm / :ToggleMarkdownFix switch it (plugin/md-fix.lua)
-- markdownlint uses the project's config, else the shared lint/.markdownlint.jsonc (as lua/genja/ext/lint.lua).
-- A fixer that isn't installed is skipped (mason: :MasonToolsInstall).

local SRC = 'lua/genja/ext/md-fix.lua: '

local M = {}

local MARKDOWNLINT_CONFIG = vim.fs.joinpath(vim.fn.stdpath('config'), 'lint', '.markdownlint.jsonc')
local MARKDOWNLINT_PROJECT = {
	'.markdownlint-cli2.jsonc', '.markdownlint-cli2.yaml', '.markdownlint-cli2.cjs',
	'.markdownlint.jsonc', '.markdownlint.json', '.markdownlint.yaml', '.markdownlint.yml',
}

---Fixer commands for `file`, in run order; missing tools are left out.
---@param file string
---@return string[][]
function M.commands(file)
	local cmds = {}
	if vim.fn.executable('typos') == 1 then
		table.insert(cmds, { 'typos', '--write-changes', file })
	end
	if vim.fn.executable('markdownlint-cli2') == 1 then
		local cmd = { 'markdownlint-cli2', '--fix' }
		if not vim.fs.root(file, MARKDOWNLINT_PROJECT) and vim.uv.fs_stat(MARKDOWNLINT_CONFIG) then
			vim.list_extend(cmd, { '--config', MARKDOWNLINT_CONFIG })
		end
		table.insert(cmd, file)
		table.insert(cmds, cmd)
	end
	return cmds
end

---Leading whitespace of `ws` with tabs expanded to the next multiple of 4 (CommonMark tab stops).
---@param ws string
---@return string
local function expand_indent(ws)
	local col = 0
	for c in ws:gmatch('.') do
		if c == '\t' then
			col = col + 4 - col % 4
		else
			col = col + 1
		end
	end
	return string.rep(' ', col)
end

---Fence state after `line`: the marker of the open fence, or nil outside one.
---@param line string
---@param fence string|nil
---@return string|nil fence
---@return boolean marker true when `line` opens or closes a fence
local function fence_step(line, fence)
	local marker = line:match('^%s*(```+)') or line:match('^%s*(~~~+)')
	if not marker then
		return fence, false
	end
	if not fence then
		return marker, true
	end
	if marker:sub(1, 1) == fence:sub(1, 1) and #marker >= #fence then
		return nil, true
	end
	return fence, true
end

---Rewrite `file` with leading tabs as spaces, outside fenced code blocks.
---markdownlint counts a tab as 1 column, so its MD007/MD010 fixes flatten tab-indented lists.
---@param file string
function M.expand_tabs(file)
	local ok, lines = pcall(vim.fn.readfile, file, 'b')
	if not ok then
		return
	end
	local fence = nil
	local changed = false
	for i, line in ipairs(lines) do
		local marker
		fence, marker = fence_step(line, fence)
		if not marker and not fence then
			local ws, rest = line:match('^([ \t]*\t[ \t]*)(.*)$')
			if ws then
				lines[i] = expand_indent(ws) .. rest
				changed = true
			end
		end
	end
	if changed then
		vim.fn.writefile(lines, file, 'b')
	end
end

-- Vim key notation (:h key-notation), lower case. Ported from md-fix.vim-keys-escape.vim.
local NAMED_KEYS = {
	nul = true, bs = true, tab = true, nl = true, ff = true, cr = true, ['return'] = true, enter = true,
	esc = true, space = true, lt = true, bslash = true, bar = true, del = true, csi = true, xcsi = true,
	eol = true, ignore = true, nop = true, help = true, undo = true, insert = true, home = true, ['end'] = true,
	pageup = true, pagedown = true, up = true, down = true, left = true, right = true,
}
-- <kPlus>, <kEnter> ... (<k0>..<k9> are matched separately)
local KEYPAD_KEYS = {
	up = true, down = true, left = true, right = true, home = true, ['end'] = true, origin = true,
	pageup = true, pagedown = true, del = true, insert = true, plus = true, minus = true, multiply = true,
	divide = true, point = true, comma = true, equal = true, enter = true,
}
-- mapping pseudo-keys and :map arguments
local PSEUDO_KEYS = {
	leader = true, localleader = true, plug = true, sid = true, snr = true, cmd = true, scriptcmd = true,
	buffer = true, nowait = true, silent = true, script = true, expr = true, unique = true, special = true,
}
local MOUSE_BUTTONS = { 'left', 'right', 'middle', 'x1', 'x2' }
local MOUSE_ACTIONS = { 'mouse', 'drag', 'release', 'mousenm', 'dragnm', 'releasenm' }
local MOUSE_OTHER = {
	scrollwheelup = true, scrollwheeldown = true, scrollwheelleft = true, scrollwheelright = true,
	mousemove = true,
}

---@param s string lower case, click count stripped
---@return boolean
local function is_mouse(s)
	if MOUSE_OTHER[s] then
		return true
	end
	for _, button in ipairs(MOUSE_BUTTONS) do
		for _, action in ipairs(MOUSE_ACTIONS) do
			if s == button .. action then
				return true
			end
		end
	end
	return false
end

---True when `name` (the text between < and >) is vim key notation.
---@param name string
---@return boolean
local function is_key(name)
	local s = name:lower()
	if NAMED_KEYS[s] or PSEUDO_KEYS[s] then
		return true
	end
	if s:match('^f%d%d?$') or s:match('^char%-%d+$') or s:match('^char%-0x%x+$') then
		return true
	end
	if s:match('^k%d$') or KEYPAD_KEYS[s:match('^k(%a+)$') or ''] then
		return true
	end
	-- modifiers S C M A D T, then an optional 2-4 click count: <C-j>, <M-S-F5>, <C-]>, <A-2-LeftMouse>
	local rest = s
	local mods = 0
	while rest:match('^[scmadt]%-.') do
		rest = rest:sub(3)
		mods = mods + 1
	end
	rest = rest:gsub('^[2-4]%-(.)', '%1')
	if mods > 0 and (rest:match('^%w+$') or rest:match('^[^%s>]$')) then
		return true
	end
	return is_mouse(rest)
end

---End of the key at `pos` in `line`, or nil; <leader> takes its suffix (<leader>ff).
---@param line string
---@param pos integer
---@return integer|nil
local function key_end(line, pos)
	local name = line:match('^<([^%s<>]+)>', pos)
	if not name or not is_key(name) then
		return nil
	end
	local stop = pos + #name + 1
	local lower = name:lower()
	if lower == 'leader' or lower == 'localleader' then
		stop = stop + #line:match('^%w*', stop + 1)
	end
	return stop
end

---Code spans of `line` as { start, stop } pairs; an unclosed backtick run is plain text.
---@param line string
---@return integer[][]
local function code_spans(line)
	local spans = {}
	local i = 1
	while true do
		local s, e = line:find('`+', i)
		if not s then
			break
		end
		local close = nil
		local j = e + 1
		while true do
			local cs, ce = line:find('`+', j)
			if not cs then
				break
			end
			if ce - cs == e - s then
				close = ce
				break
			end
			j = ce + 1
		end
		if close then
			table.insert(spans, { s, close })
			i = close + 1
		else
			i = e + 1
		end
	end
	return spans
end

---@param spans integer[][]
---@param s integer
---@param e integer
---@return boolean
local function overlaps(spans, s, e)
	for _, span in ipairs(spans) do
		if s <= span[2] and e >= span[1] then
			return true
		end
	end
	return false
end

---`line` with vim key notation outside code spans wrapped in backticks.
---Adjacent keys share one span (<C-x><C-o>); keys touching a backtick are left alone.
---@param line string
---@return string
function M.escape_keys_line(line)
	local spans = code_spans(line)
	local out = {}
	local from = 1
	local p = line:find('<', 1, true)
	while p do
		local stop = key_end(line, p)
		local ok = false
		if stop then
			local next_stop = key_end(line, stop + 1)
			while next_stop do
				stop = next_stop
				next_stop = key_end(line, stop + 1)
			end
			local touches = line:sub(p - 1, p - 1) == '`' or line:sub(stop + 1, stop + 1) == '`'
			ok = not touches and not overlaps(spans, p, stop)
		end
		if ok and stop then
			local keys = line:sub(p, stop)
			table.insert(out, line:sub(from, p - 1))
			if keys:find('`', 1, true) then
				-- <M-`> needs a double backtick span
				table.insert(out, '`` ' .. keys .. ' ``')
			else
				table.insert(out, '`' .. keys .. '`')
			end
			from = stop + 1
			p = line:find('<', from, true)
		else
			p = line:find('<', p + 1, true)
		end
	end
	table.insert(out, line:sub(from))
	return table.concat(out)
end

---Rewrite `file` with vim key notation in backticks; markdown takes <M-v> for an HTML tag (MD033) and hides it.
---Skips fenced code blocks and indented ones (4+ spaces after a blank line, outside lists).
---@param file string
function M.escape_keys(file)
	local ok, lines = pcall(vim.fn.readfile, file, 'b')
	if not ok then
		return
	end
	local fence = nil
	local in_list = false
	local in_code = false
	local prev_blank = true
	local changed = false
	for i, line in ipairs(lines) do
		local marker
		fence, marker = fence_step(line, fence)
		if marker or fence then
			prev_blank = false
			in_code = false
		elseif line:match('^%s*$') then
			prev_blank = true
		else
			local indent = #line:match('^ *')
			if indent >= 4 and not in_list and (prev_blank or in_code) then
				in_code = true
			else
				in_code = false
				if line:match('^%s*[-*+]%s') or line:match('^%s*%d+[.)]%s') then
					in_list = true
				elseif indent == 0 then
					in_list = false
				end
			end
			if not in_code then
				local fixed = M.escape_keys_line(line)
				if fixed ~= line then
					lines[i] = fixed
					changed = true
				end
			end
			prev_blank = false
		end
	end
	if changed then
		vim.fn.writefile(lines, file, 'b')
	end
end

---Reload `bufnr` from disk, keeping the view in its windows.
---@param bufnr integer
local function reload(bufnr)
	if not vim.api.nvim_buf_is_loaded(bufnr) or vim.bo[bufnr].modified then
		return -- typed into while the fixers ran: keep the user's text
	end
	local views = {}
	for _, win in ipairs(vim.fn.win_findbuf(bufnr)) do
		views[win] = vim.api.nvim_win_call(win, vim.fn.winsaveview)
	end
	vim.api.nvim_buf_call(bufnr, function() vim.cmd('silent edit') end)
	for win, view in pairs(views) do
		if vim.api.nvim_win_is_valid(win) then
			vim.api.nvim_win_call(win, function() vim.fn.winrestview(view) end)
		end
	end
end

---Run the fixers on the file of `bufnr` one after the other, then reload it.
---@param bufnr integer
---@param save boolean write the buffer first (<leader>mfx); false on BufWritePost
function M.fix(bufnr, save)
	local file = vim.api.nvim_buf_get_name(bufnr)
	if file == '' or vim.bo[bufnr].buftype ~= '' then
		return
	end
	if save then
		vim.api.nvim_buf_call(bufnr, function() vim.cmd('silent update') end)
	end
	local cmds = M.commands(file)
	if #cmds == 0 then
		if save then
			vim.notify(SRC .. 'neither typos nor markdownlint-cli2 found; :MasonToolsInstall', vim.log.levels.WARN)
		end
		return
	end
	M.expand_tabs(file)
	M.escape_keys(file)
	local i = 0
	local function next_cmd()
		i = i + 1
		if i > #cmds then
			reload(bufnr)
			return
		end
		-- non-zero exit: what's left unfixed; the linters show it
		vim.system(cmds[i], { cwd = vim.fs.dirname(file) }, vim.schedule_wrap(next_cmd))
	end
	next_cmd()
end

---Switch fix on save on/off for all markdown buffers.
function M.toggle()
	local on = vim.g.md_fix_on_save == false
	vim.g.md_fix_on_save = on
	if on then
		vim.notify(SRC .. 'fix on save on')
	else
		vim.notify(SRC .. 'fix on save off')
	end
end

---Fix on save for `bufnr`, unless vim.g.md_fix_on_save is false.
---@param bufnr integer
function M.register(bufnr)
	vim.api.nvim_create_autocmd('BufWritePost', {
		buffer = bufnr,
		group = vim.api.nvim_create_augroup('genja_md_fix_' .. bufnr, { clear = true }),
		callback = function()
			if vim.g.md_fix_on_save ~= false then
				M.fix(bufnr, false)
			end
		end,
	})
end

return M
