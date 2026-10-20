-- Idea #19 A (and #16): Claude Code in a floaterm named 'claude', fed from the editor.
--   :ClaudeFterm   toggle the terminal; started on first use, in :pwd (or resumed, see below)
--   <leader>pc     paste context: normal = @file mention, visual = path:lines + code.
--                  Jumps into the terminal to type the question.
--   <leader>pC     prompt popup (draft, history, brief mode). <CR> sends and submits;
--                  the cursor stays in the editor. In visual mode the selection is attached.
--   <C-q>, <C-j>, <C-Space>   in the claude terminal: back to the previous window
--   <C-Left>                  in the claude terminal: to the window on the left
-- Pasting into the running session avoids `claude -p` startup time and keeps context.
--
-- Session marker: :ClaudeFterm resumes the session named in the file.
--   Marker: one comment line in the file, made with 'commentstring':
--     -- claude-session: <uuid> <title>
--   Start: a new claude gets `--session-id <new uuid>`, so its transcript is known:
--     ~/.claude/projects/<cwd, non-alnum -> '-'>/<uuid>.jsonl
--   Write: /rename in claude appends {"type":"custom-title","customTitle":...} to that
--     transcript. A timer reads what was appended; on a new title the marker goes into
--     the buffer claude was started from (state.origin_buf), replacing an older marker.
--     The buffer is changed but not saved.
--   Read: when claude starts, the first and last MARKER_SCAN lines of the current buffer
--     are searched. Found: `--resume <uuid>` in the session's cwd.
--   Cwd: glob ~/.claude/projects/*/<uuid>.jsonl and read its "cwd" field.
--     The dir name can't be decoded (the '-' encoding is lossy). Fallback: the parent
--     of the file whose encoded name is that dir.
--
-- Terminal buffer name: `claude-ft «<title>»`, title capped at TITLE_MAX chars with '…';
--   no title yet: `claude-ft «<basename of cwd>»`. Shown in the tabline and winbar.
--   b:claude_session_id holds the session id.

local M = {}

local src = 'nvim/lua/genja/claude.lua: '
local TERM = 'claude'
local BRIEF = 'Answer briefly: at most 3 short sentences, plain text, no markdown.\n\n'
local HISTORY_MAX = 50
---:FloatermNew options as { option = value }, plus `cmd` for the command to run.
---Given by the caller (:ClaudeFterm in auto-alias.vim); --name is set here.
---@alias genja.claude.TermOpts table<string, string|number>

local state = {
	cwd = nil,       -- :pwd claude was started in; paths are made relative to it
	draft = nil,     -- popup text kept between popups, cleared on send
	history = {},    -- sent prompts, oldest first (this session only)
	brief = false,   -- <C-b> in the popup: ask for a short plain-text answer
	---@type genja.claude.TermOpts last given to toggle(); floaterm defaults until then
	term_opts = { cmd = 'claude' },
	---@type integer|nil buffer claude was started from; gets the session marker
	origin_buf = nil,
	---@type uv.uv_timer_t|nil polls the transcript for /rename
	watch_timer = nil,
}

-- {{{ session marker

local MARKER = 'claude%-session: (%x+%-%x+%-%x+%-%x+%-%x+)'
local MARKER_SCAN = 5 -- lines at the top and at the bottom searched for the marker
local POLL_MS = 2000
local TITLE_MAX = 16 -- chars of the session title in the terminal buffer name, '…' included

---True while the terminal job in `bufnr` runs.
---@param bufnr integer
---@return boolean
local function job_running(bufnr)
	if not vim.api.nvim_buf_is_valid(bufnr) then
		return false
	end
	local chan = vim.bo[bufnr].channel
	return chan > 0 and vim.fn.jobwait({ chan }, 0)[1] == -1
end

---Claude's config dir: $CLAUDE_CONFIG_DIR or ~/.claude.
---@return string
local function claude_dir()
	local dir = vim.env.CLAUDE_CONFIG_DIR
	if dir == nil or dir == '' then
		dir = '~/.claude'
	end
	return vim.fs.normalize(dir)
end

---Random version 4 UUID, for `claude --session-id`.
---@return string
local function new_uuid()
	local bytes = { assert(vim.uv.random(16)):byte(1, 16) }
	bytes[7] = bytes[7] % 16 + 0x40 -- version 4
	bytes[9] = bytes[9] % 64 + 0x80 -- RFC 4122 variant
	local hex = ''
	for _, b in ipairs(bytes) do
		hex = hex .. string.format('%02x', b)
	end
	return hex:sub(1, 8) .. '-' .. hex:sub(9, 12) .. '-' .. hex:sub(13, 16) .. '-'
		.. hex:sub(17, 20) .. '-' .. hex:sub(21, 32)
end

---Session id in the marker of `buf`, and the marker's 0-based line.
---@param buf integer
---@return string|nil id, integer|nil lnum
local function find_marker(buf)
	local count = vim.api.nvim_buf_line_count(buf)
	for i, line in ipairs(vim.api.nvim_buf_get_lines(buf, 0, MARKER_SCAN, false)) do
		local id = line:match(MARKER)
		if id then
			return id, i - 1
		end
	end
	local start = math.max(MARKER_SCAN, count - MARKER_SCAN)
	for i, line in ipairs(vim.api.nvim_buf_get_lines(buf, start, count, false)) do
		local id = line:match(MARKER)
		if id then
			return id, start + i - 1
		end
	end
	return nil, nil
end

---Transcript of session `id`, in whichever project dir claude put it.
---@param id string
---@return string|nil path
local function transcript_path(id)
	local found = vim.fn.glob(claude_dir() .. '/projects/*/' .. id .. '.jsonl', true, true)
	return found[1]
end

---Last /rename title in a transcript, if any.
---@param path string transcript
---@return string|nil
local function transcript_title(path)
	local fd = io.open(path, 'r')
	if not fd then
		return nil
	end
	local title = nil
	for line in fd:lines() do
		if line:find('"type":"custom-title"', 1, true) then
			local ok, entry = pcall(vim.json.decode, line)
			if ok and type(entry) == 'table' and type(entry.customTitle) == 'string' then
				title = entry.customTitle
			end
		end
	end
	fd:close()
	return title
end

---Name the claude terminal buffer `claude-ft «title»`, or after claude's cwd without a title.
---@param bufnr integer
---@param title string|nil
local function set_term_name(bufnr, title)
	if not vim.api.nvim_buf_is_valid(bufnr) then
		return
	end
	local label = nil
	if title and vim.trim(title) ~= '' then
		-- slashes would split the name for :t in the tabline
		label = vim.trim(title):gsub('%s+', ' '):gsub('[/\\]', '-')
		if vim.fn.strchars(label) > TITLE_MAX then
			label = vim.fn.strcharpart(label, 0, TITLE_MAX - 1) .. '…'
		end
	else
		label = vim.fs.basename(state.cwd or vim.fn.getcwd())
	end
	local name = 'claude-ft «' .. label .. '»'

	local old = vim.api.nvim_buf_get_name(bufnr)
	if vim.fn.fnamemodify(old, ':t') == name then
		return
	end
	if not pcall(vim.api.nvim_buf_set_name, bufnr, name) then
		-- E95: another buffer has that name
		pcall(vim.api.nvim_buf_set_name, bufnr, name .. ' ' .. bufnr)
	end
	-- renaming leaves an unlisted buffer with the old name; a term:// one would start a shell
	for _, b in ipairs(vim.api.nvim_list_bufs()) do
		if b ~= bufnr and not vim.api.nvim_buf_is_loaded(b) and vim.api.nvim_buf_get_name(b) == old then
			vim.api.nvim_buf_delete(b, { force = true })
		end
	end
end

---Directory a session was started in: the first existing "cwd" in its transcript,
---else the parent of `file` that encodes to the transcript's project dir name.
---@param path string transcript
---@param file string file the marker is in
---@return string|nil
local function session_cwd(path, file)
	local fd = io.open(path, 'r')
	if fd then
		for line in fd:lines() do
			local raw = line:match('"cwd":("[^"]*")')
			if raw then
				local ok, cwd = pcall(vim.json.decode, raw)
				if ok and type(cwd) == 'string' and vim.fn.isdirectory(cwd) == 1 then
					fd:close()
					return cwd
				end
			end
		end
		fd:close()
	end
	-- claude names project dirs after the cwd with every non-alphanumeric char as '-'
	local project = vim.fs.basename(vim.fs.dirname(path)):lower()
	for dir in vim.fs.parents(file) do
		if dir:gsub('[^%w]', '-'):lower() == project then
			return dir
		end
	end
	return nil
end

---Put the marker for session `id` into the origin buffer, replacing an older marker.
---@param id string
---@param title string
local function write_marker(id, title)
	local buf = state.origin_buf
	if not buf or not vim.api.nvim_buf_is_loaded(buf) or not vim.bo[buf].modifiable then
		vim.notify(src .. 'session renamed, but the buffer claude was started from is gone', vim.log.levels.WARN)
		return
	end
	local cs = vim.bo[buf].commentstring
	local at = cs:find('%s', 1, true)
	if not at then
		vim.notify(src .. "no 'commentstring' for this filetype; marker not written", vim.log.levels.WARN)
		return
	end
	local text = 'claude-session: ' .. id .. ' ' .. title:gsub('%s+', ' ')
	local line = cs:sub(1, at - 1) .. text .. cs:sub(at + 2)

	local _, lnum = find_marker(buf)
	if lnum then
		if vim.api.nvim_buf_get_lines(buf, lnum, lnum + 1, false)[1] == line then
			return
		end
		vim.api.nvim_buf_set_lines(buf, lnum, lnum + 1, false, { line })
	else
		vim.api.nvim_buf_set_lines(buf, -1, -1, false, { line })
	end
	local name = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(buf), ':~:.')
	vim.notify(src .. 'session marker written to ' .. name .. ' (not saved)')
end

---Stop polling the transcript.
local function stop_watch()
	if state.watch_timer then
		state.watch_timer:stop()
		state.watch_timer:close()
		state.watch_timer = nil
	end
end

---Poll session `id`'s transcript for /rename (custom-title lines) while claude runs.
---Polled, not watched: a new session's transcript appears only once claude writes it.
---@param id string
---@param bufnr integer claude terminal
---@param from_end boolean skip what the transcript holds now (resumed session)
---@param title string|nil current title, from the transcript of a resumed session
local function watch_session(id, bufnr, from_end, title)
	stop_watch()
	local path = nil
	local offset = 0
	if from_end then
		path = transcript_path(id)
		if path then
			offset = math.max(vim.fn.getfsize(path), 0)
		end
	end

	local timer = assert(vim.uv.new_timer())
	state.watch_timer = timer
	timer:start(POLL_MS, POLL_MS, vim.schedule_wrap(function()
		if state.watch_timer ~= timer then
			return
		end
		if not job_running(bufnr) then
			stop_watch()
			return
		end
		if not path then
			path = transcript_path(id)
			if not path then
				return
			end
		end
		local fd = io.open(path, 'rb')
		if not fd then
			return
		end
		fd:seek('set', offset)
		local data = fd:read('*a') or ''
		fd:close()
		-- only whole lines; a half-written one is read next time
		local cut = data:find('\n[^\n]*$')
		if not cut then
			return
		end
		offset = offset + cut
		for line in data:sub(1, cut):gmatch('[^\n]+') do
			if line:find('"type":"custom-title"', 1, true) then
				local ok, entry = pcall(vim.json.decode, line)
				if ok and type(entry) == 'table' and type(entry.customTitle) == 'string'
					and entry.customTitle ~= title then
					title = entry.customTitle
					write_marker(id, title)
					set_term_name(bufnr, title)
				end
			end
		end
	end))
end

---@class genja.claude.Start
---@field term_opts genja.claude.TermOpts with the session flag added to `cmd`
---@field id string session id
---@field resumed boolean
---@field cwd string
---@field title string|nil /rename title of a resumed session

---How to start claude from the current buffer: resume the session in its marker, else a new one.
---@return genja.claude.Start
local function session_start()
	local opts = vim.deepcopy(state.term_opts)
	local cmd = opts.cmd or 'claude'
	local buf = vim.api.nvim_get_current_buf()
	local file = vim.api.nvim_buf_get_name(buf)

	if vim.bo[buf].buftype == '' and file ~= '' then
		local id = find_marker(buf)
		if id then
			local path = transcript_path(id)
			local cwd = nil
			local title = nil
			if path then
				cwd = session_cwd(path, file)
				title = transcript_title(path)
			end
			if cwd then
				opts.cmd = cmd .. ' --resume ' .. id
				-- floaterm splits its options on unescaped spaces
				opts.cwd = vim.fs.normalize(cwd):gsub(' ', '\\ ')
				return { term_opts = opts, id = id, resumed = true, cwd = cwd, title = title }
			end
			vim.notify(src .. 'no transcript or cwd for session ' .. id .. '; starting a new one', vim.log.levels.WARN)
		end
	end

	local id = new_uuid()
	opts.cmd = cmd .. ' --session-id ' .. id
	return { term_opts = opts, id = id, resumed = false, cwd = vim.fn.getcwd() }
end
-- }}}

-- {{{ terminal

---Make sure vim-floaterm is loaded (its spec loads on commands only).
local function load_floaterm()
	require('lazy').load({ plugins = { 'vim-floaterm' } })
end

---Buffer of the running 'claude' floaterm; a dead job is killed and counts as none.
---@return integer|nil bufnr
local function term_bufnr()
	load_floaterm()
	local bufnr = vim.fn['floaterm#terminal#get_bufnr'](TERM)
	if bufnr == -1 or not vim.api.nvim_buf_is_valid(bufnr) then
		return nil
	end
	if not job_running(bufnr) then
		vim.cmd('FloatermKill ' .. TERM)
		return nil
	end
	return bufnr
end

---Window showing `bufnr`, if any.
---@param bufnr integer
---@return integer|nil win
local function term_win(bufnr)
	for _, win in ipairs(vim.api.nvim_list_wins()) do
		if vim.api.nvim_win_get_buf(win) == bufnr then
			return win
		end
	end
	return nil
end

---Wait until a freshly started claude has drawn its UI, then run `cb`.
---A guess: first output + 800 ms. The folder-trust question or a slow MCP start
---can still be on screen then, and the paste lands there instead of the prompt.
---@param bufnr integer terminal buffer
---@param cb fun()
local function when_ready(bufnr, cb)
	local waited = 0
	local function poll()
		local text = table.concat(vim.api.nvim_buf_get_lines(bufnr, 0, -1, false), '')
		if vim.trim(text) ~= '' then
			vim.defer_fn(cb, 800) -- the input box comes a moment after the first output
			return
		end
		if waited >= 15000 then
			vim.notify(src .. 'claude did not start within 15 s', vim.log.levels.WARN)
			return
		end
		waited = waited + 200
		vim.defer_fn(poll, 200)
	end
	poll()
end

---Terminal-mode keys in the claude buffer to get back to the editor.
---Buffer-local: a global <C-w> map would break claude's delete-word.
---@param bufnr integer terminal buffer
local function set_term_keys(bufnr)
	local back = '<C-\\><C-n><C-w>p'
	vim.keymap.set('t', '<C-q>', back, { buffer = bufnr, desc = 'Claude: back to previous window' })
	-- replaces claude's own <C-j> newline; <S-CR> or \<CR> still add one
	-- check this: does nvim's terminal pass <S-CR> to claude as Shift+Enter, or as plain Enter?
	vim.keymap.set('t', '<C-j>', back, { buffer = bufnr, desc = 'Claude: back to previous window' })
	-- a terminal (e.g. Windows Terminal) may send <C-Space> as <C-@>; map that too if this doesn't fire
	vim.keymap.set('t', '<C-Space>', back, { buffer = bufnr, desc = 'Claude: back to previous window' })
	-- replaces claude's own <C-Left> word-left
	vim.keymap.set('t', '<C-Left>', '<C-\\><C-n><C-w>h', { buffer = bufnr, desc = 'Claude: to the window on the left' })
end

---:FloatermNew arguments from `opts`: sorted `--option=value`, then the command.
---@param opts genja.claude.TermOpts
---@return string
local function fterm_args(opts)
	local keys = vim.tbl_keys(opts)
	table.sort(keys)
	local args = { '--name=' .. TERM }
	for _, key in ipairs(keys) do
		if key ~= 'cmd' and key ~= 'name' then
			table.insert(args, '--' .. key .. '=' .. tostring(opts[key]))
		end
	end
	table.insert(args, opts.cmd or 'claude')
	return table.concat(args, ' ')
end

---Start claude or show it, then call `cb(bufnr)` once it can take input.
---@param focus boolean true: stay in the terminal (terminal mode); false: back to the editor
---@param cb? fun(bufnr: integer)
local function open(focus, cb)
	local origin = vim.api.nvim_get_current_win()
	local bufnr = term_bufnr()
	local is_new = bufnr == nil
	if is_new then
		local start = session_start()
		state.cwd = start.cwd
		state.origin_buf = nil
		if vim.bo.buftype == '' and vim.api.nvim_buf_get_name(0) ~= '' then
			state.origin_buf = vim.api.nvim_get_current_buf()
		end
		-- claude's title updates make the mouse cursor flicker between normal and hourglass;
		-- related: "terminalProgressBarEnabled": false in claude's settings.json.
		-- Set only while the job starts, so other terminals keep their titles.
		local old_title_env = vim.env.CLAUDE_CODE_DISABLE_TERMINAL_TITLE
		vim.env.CLAUDE_CODE_DISABLE_TERMINAL_TITLE = '1'
		vim.cmd('FloatermNew ' .. fterm_args(start.term_opts))
		vim.env.CLAUDE_CODE_DISABLE_TERMINAL_TITLE = old_title_env
		bufnr = term_bufnr()
		if bufnr then
			set_term_keys(bufnr)
			vim.b[bufnr].claude_session_id = start.id
			set_term_name(bufnr, start.title)
			watch_session(start.id, bufnr, start.resumed, start.title)
		end
	elseif not term_win(bufnr) then
		vim.cmd('FloatermShow ' .. TERM)
	end
	if not bufnr then
		vim.notify(src .. 'could not start claude', vim.log.levels.ERROR)
		return
	end

	if focus then
		local win = term_win(bufnr)
		if win then
			vim.api.nvim_set_current_win(win)
			vim.cmd.startinsert()
		end
	elseif vim.api.nvim_win_is_valid(origin) then
		vim.cmd.stopinsert()
		vim.api.nvim_set_current_win(origin)
	end

	if not cb then
		return
	end
	if is_new then
		when_ready(bufnr, function() cb(bufnr) end)
	else
		cb(bufnr)
	end
end

---Type `text` into claude as one bracketed paste (newlines don't submit), optionally submit.
---@param bufnr integer terminal buffer
---@param text string
---@param submit boolean true: press Enter after the paste
local function paste(bufnr, text, submit)
	local chan = vim.bo[bufnr].channel
	vim.api.nvim_chan_send(chan, '\27[200~' .. text .. '\27[201~')
	if submit then
		-- a short gap, so the paste is taken in before Enter
		vim.defer_fn(function() vim.api.nvim_chan_send(chan, '\r') end, 100)
	end
end

---:ClaudeFterm: hide claude when shown, else show (start) it and jump in.
---@param term_opts? genja.claude.TermOpts kept for later starts, also by <leader>pc/pC;
---  only used when claude is (re)started
function M.toggle(term_opts)
	if term_opts then
		state.term_opts = term_opts
	end
	local bufnr = term_bufnr()
	if bufnr and term_win(bufnr) then
		vim.cmd('FloatermHide ' .. TERM)
		return
	end
	open(true)
end

---Kill the claude terminal, if one runs; used by `:s:` before :qa (a running job blocks :qa).
---Doesn't load floaterm just for this.
function M.kill()
	stop_watch()
	if vim.g.loaded_floaterm == nil then
		return
	end
	if vim.fn['floaterm#terminal#get_bufnr'](TERM) ~= -1 then
		vim.cmd('FloatermKill ' .. TERM)
	end
end
-- }}}

-- {{{ context

---`file` relative to claude's start dir (or :pwd), forward slashes; absolute when outside.
---@param file string
---@return string
local function rel_path(file)
	local base = state.cwd or vim.fn.getcwd()
	local rel = vim.fs.relpath(base, file)
	if rel then
		return rel
	end
	return vim.fs.normalize(file)
end

---Lines of the linewise range of the current visual selection.
---@return integer first, integer last
local function visual_range()
	local a = vim.fn.line('v')
	local b = vim.fn.line('.')
	if a > b then
		a, b = b, a
	end
	return a, b
end

---Selection as `path:first-last` plus a fenced code block; nil for a buffer without a file.
---@param first integer
---@param last integer
---@return string|nil text, string|nil label e.g. 'lua/genja/f2.lua:10-20'
local function selection_context(first, last)
	local file = vim.api.nvim_buf_get_name(0)
	-- oil://, term:// etc. have no usable path
	if file == '' or vim.bo.buftype ~= '' then
		return nil, nil
	end
	local label = rel_path(file) .. ':' .. first .. '-' .. last
	local code = table.concat(vim.api.nvim_buf_get_lines(0, first - 1, last, false), '\n')
	-- fence longer than any backtick run in the code, so it can't close early
	local ticks = '```'
	for run in code:gmatch('`+') do
		if #run >= #ticks then
			ticks = string.rep('`', #run + 1)
		end
	end
	local text = label .. '\n' .. ticks .. vim.bo.filetype .. '\n' .. code .. '\n' .. ticks .. '\n\n'
	return text, label
end

---Leave visual mode (after the range was read).
local function exit_visual()
	vim.api.nvim_feedkeys(vim.keycode('<Esc>'), 'n', false)
end

---<leader>pc: paste the file (@mention) or the selection into claude, then jump in to ask.
function M.paste_context()
	local is_visual = vim.fn.mode():match('^[vV\22]') ~= nil
	local text = nil
	if is_visual then
		local first, last = visual_range()
		exit_visual()
		text = selection_context(first, last)
	else
		local file = vim.api.nvim_buf_get_name(0)
		if file ~= '' and vim.bo.buftype == '' then
			text = '@' .. rel_path(file) .. ' '
		end
	end
	if not text then
		vim.notify(src .. 'nothing to paste: this buffer has no file', vim.log.levels.WARN)
		return
	end
	open(true, function(bufnr) paste(bufnr, text, false) end)
end
-- }}}

-- {{{ prompt popup

---Keep `prompt` in the history (no repeats in a row, at most HISTORY_MAX).
---@param prompt string
local function remember(prompt)
	if state.history[#state.history] ~= prompt then
		table.insert(state.history, prompt)
	end
	if #state.history > HISTORY_MAX then
		table.remove(state.history, 1)
	end
end

---Popup title: what gets sent along, and whether brief mode is on.
---@param label string|nil attached selection
---@return string
local function popup_title(label)
	local title = ' Claude'
	if label then
		title = title .. ' + ' .. label
	end
	if state.brief then
		title = title .. ' [brief]'
	end
	return title .. ' '
end

---<leader>pC: popup for a prompt sent to the running claude; selection attached in visual mode.
function M.prompt()
	local context, label = nil, nil
	if vim.fn.mode():match('^[vV\22]') then
		local first, last = visual_range()
		exit_visual()
		context, label = selection_context(first, last)
	end

	local buf = vim.api.nvim_create_buf(false, true)
	vim.bo[buf].bufhidden = 'wipe'
	vim.bo[buf].filetype = 'markdown'
	if state.draft then
		vim.api.nvim_buf_set_lines(buf, 0, -1, false, state.draft)
	end

	local width = math.min(80, vim.o.columns - 4)
	local height = math.min(6, vim.o.lines - vim.o.cmdheight - 4)
	local win = vim.api.nvim_open_win(buf, true, {
		relative = 'editor',
		width = width,
		height = math.max(height, 1),
		row = math.floor((vim.o.lines - height) / 2),
		col = math.floor((vim.o.columns - width) / 2),
		style = 'minimal',
		border = 'rounded',
		title = popup_title(label),
		title_pos = 'center',
		footer = ' <CR> send · <S-CR>/<C-j> newline · <C-p>/<C-n> history · <C-b> brief · <Esc><Esc> close ',
		footer_pos = 'center',
	})
	vim.wo[win].wrap = true
	local ok_cmp, cmp = pcall(require, 'cmp')
	if ok_cmp then
		cmp.setup.buffer({ enabled = false }) -- a completion menu would take <CR>
	end

	local closed = false
	local history_index = nil -- nil: editing the draft; else position in state.history
	local scratch = nil       -- the draft while browsing history

	---Close the popup, keeping its text as the draft.
	local function close()
		if closed then
			return
		end
		closed = true
		if vim.api.nvim_buf_is_valid(buf) then
			local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
			state.draft = lines
			if vim.trim(table.concat(lines, '\n')) == '' then
				state.draft = nil
			end
		end
		if vim.api.nvim_get_current_win() == win then
			vim.cmd.stopinsert()
		end
		if vim.api.nvim_win_is_valid(win) then
			vim.api.nvim_win_close(win, true)
		end
	end

	---Send the prompt (plus selection, plus brief note) and submit it; empty does nothing.
	local function send()
		local prompt = vim.trim(table.concat(vim.api.nvim_buf_get_lines(buf, 0, -1, false), '\n'))
		close()
		if prompt == '' then
			return
		end
		state.draft = nil
		remember(prompt)
		local text = (context or '') .. prompt
		if state.brief then
			text = BRIEF .. text
		end
		open(false, function(bufnr) paste(bufnr, text, true) end)
	end

	---Show history entry `index` (nil: back to the draft) in the popup.
	---@param index integer|nil
	local function show_history(index)
		history_index = index
		local text = scratch or {}
		if index then
			text = vim.split(state.history[index], '\n', { plain = true })
		end
		vim.api.nvim_buf_set_lines(buf, 0, -1, false, text)
		local last = vim.api.nvim_buf_line_count(buf)
		vim.api.nvim_win_set_cursor(win, { last, #vim.api.nvim_buf_get_lines(buf, last - 1, last, false)[1] })
	end

	---<C-p>: one prompt back in history.
	local function history_prev()
		if #state.history == 0 then
			return
		end
		if history_index == nil then
			scratch = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
			show_history(#state.history)
		elseif history_index > 1 then
			show_history(history_index - 1)
		end
	end

	---<C-n>: one prompt forward; past the newest, back to the draft.
	local function history_next()
		if history_index == nil then
			return
		end
		if history_index < #state.history then
			show_history(history_index + 1)
		else
			show_history(nil)
		end
	end

	---<C-b>: toggle brief mode (remembered), shown in the title.
	local function toggle_brief()
		state.brief = not state.brief
		vim.api.nvim_win_set_config(win, { title = popup_title(label), title_pos = 'center' })
	end

	local function o(desc) return { buffer = buf, desc = desc } end
	vim.keymap.set({ 'i', 'n' }, '<CR>', send, o 'Claude: send prompt')
	vim.keymap.set('i', '<S-CR>', '<CR>', { buffer = buf, desc = 'Claude: newline' }) -- noremap: plain newline
	vim.keymap.set({ 'i', 'n' }, '<C-p>', history_prev, o 'Claude: previous prompt')
	vim.keymap.set({ 'i', 'n' }, '<C-n>', history_next, o 'Claude: next prompt')
	vim.keymap.set({ 'i', 'n' }, '<C-b>', toggle_brief, o 'Claude: toggle brief answer')
	-- like snacks.input: <Esc> in insert only leaves insert mode, so the text can be edited
	vim.keymap.set('n', '<Esc>', close, o 'Claude: close (keeps draft)')
	vim.keymap.set('n', 'q', close, o 'Claude: close (keeps draft)')
	-- leaving the popup closes it too; scheduled: no window closing inside WinLeave
	vim.api.nvim_create_autocmd('WinLeave', {
		buffer = buf,
		once = true,
		callback = function() vim.schedule(close) end,
	})
	vim.api.nvim_win_set_cursor(win, { 1, 0 })
	vim.cmd.startinsert({ bang = true })
end
-- }}}

return M
