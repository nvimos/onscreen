-- Record errors and warnings as they happen, with a traceback, instead of parsing :messages later.
-- NOT ACTIVE: nothing requires this file. Try it with
--   :lua require('genja.ext.messages-capture').enable()
-- or keep it on from lua/genja/init.lua. lua/genja/ext/messages.lua is the passive variant in use.
--
-- What it does: wraps vim.notify (WARN and up, or every level with { all = true }). Each call
-- is stored with time, level, message, and debug.traceback() at the call site, so even a
-- notify without a path in its text points back to the code that sent it. Ring buffer,
-- MAX entries. The original vim.notify still runs: noice, nvim-notify etc. show it as before.
--
-- Ideas for using it
--   - Quickfix of the session's trouble: `M.to_qflist()` -> every recorded entry's first
--     frame outside vim/_* as an item, so :cnext walks the code that complained.
--   - "Last error" key: `M.last()` opens the newest entry's call site. A <F2> item could do the same.
--   - Find the noisy plugin: `M.count_by_source()` groups entries by the file that called notify;
--     a plugin that warns 40 times on startup shows up at the top.
--   - Startup audit: enable() first thing in init.lua, then :lua =require('genja.ext.messages-capture').entries()
--     after VeryLazy to see what complained while loading (lazy's own messages included).
--   - Bug reports: `M.dump()` writes the entries with tracebacks to a scratch buffer to paste.
--   - Tests: tests can enable it in a child nvim and assert "no WARN or ERROR" after a scenario.
--   - Notifications that vanish: a notify shown during a redraw or while the cmdline is busy
--     can scroll away; the record stays.
--   - Mute after the fact: knowing the call site makes a targeted filter easy
--     (e.g. drop one deprecation warning by source file).
--
-- How others do it
--   Vim / Neovim
--   - `:messages`, `:messages clear`, 'messagesopt' (nvim 0.11: history size, hit-enter);
--     `:redir`/`execute('messages')` to capture: what lua/genja/ext/messages.lua does.
--   - `v:errmsg` (last error), `v:exception`/`v:throwpoint` in try/catch: point-in-time only.
--   - noice.nvim: replaces the message UI (ext_messages) and keeps a history,
--     `:Noice history` / `:Noice errors`, with filters and telescope.
--   - nvim-notify: wraps vim.notify, keeps a history (`:Notifications`, telescope extension).
--   - fidget.nvim: LSP progress and an optional vim.notify override with a history window.
--   - messages.nvim (AckslD): `:Messages` opens :messages in a float or buffer.
--   - snacks.nvim (folke): notifier with history, `Snacks.notifier.show_history()`.
--   - Vim plugins: vim-bufferize / `:Bufferize messages`; tpope's scriptease `:Messages` puts
--     :messages tracebacks into the quickfix list, the closest relative of :Messages -quick.
--   Other editors
--   - VS Code: per-extension Output channels; "Developer: Show Logs"; extension host errors
--     carry a stack with clickable file:line.
--   - Emacs: the *Messages* buffer (everything echoed), *Warnings*, and `debug-on-error`
--     dropping into a *Backtrace* buffer with jumpable frames.
--   - JetBrains IDEs: the Event Log / Notifications tool window keeps the history; IDE errors
--     ("red exclamation") collect stack traces with links to the plugin source.
--   - Sublime Text: the console (Ctrl+`) keeps plugin tracebacks with file:line.

local SRC = 'lua/genja/ext/messages-capture.lua: '

local M = {}

local MAX = 200

---@class genja.messages.Entry
---@field time string
---@field level integer
---@field msg string
---@field trace string debug.traceback() where vim.notify was called
---@field file string|nil first frame outside nvim's own runtime and this file
---@field lnum integer|nil

---@type genja.messages.Entry[]
local entries = {}
local original = nil
local min_level = vim.log.levels.WARN

---First caller frame in `trace` that is not nvim's runtime, a C function or this file.
---@param trace string
---@return string|nil file, integer|nil lnum
local function call_site(trace)
	for path, lnum in trace:gmatch('\n%s*(%S-%.lua):(%d+):') do
		local p = vim.fs.normalize(path)
		if not p:find('/runtime/lua/vim/', 1, true) and not p:find('messages%-capture%.lua$') then
			local found = require('genja.ext.messages').resolve(p)
			if found then
				return found, tonumber(lnum)
			end
		end
	end
	return nil, nil
end

---Start recording. opts.all: every level, not just WARN and up.
---@param opts? { all?: boolean }
function M.enable(opts)
	if original then
		return
	end
	if opts and opts.all then
		min_level = vim.log.levels.TRACE
	end
	original = vim.notify
	vim.notify = function(msg, level, o)
		level = level or vim.log.levels.INFO
		if level >= min_level then
			local trace = debug.traceback('', 2)
			local file, lnum = call_site(trace)
			table.insert(entries, {
				time = os.date('%H:%M:%S'),
				level = level,
				msg = tostring(msg),
				trace = trace,
				file = file,
				lnum = lnum,
			})
			if #entries > MAX then
				table.remove(entries, 1)
			end
		end
		return original(msg, level, o)
	end
end

---Stop recording; the entries stay.
function M.disable()
	if original then
		vim.notify = original
		original = nil
	end
end

---Recorded entries, oldest first.
---@return genja.messages.Entry[]
function M.entries()
	return entries
end

---Entries with a call site into the quickfix list (appended), then :copen.
function M.to_qflist()
	local items = {}
	for _, e in ipairs(entries) do
		if e.file then
			table.insert(items, { filename = e.file, lnum = e.lnum, text = e.time .. ' ' .. e.msg:gsub('\n', ' ') })
		end
	end
	if #items == 0 then
		vim.notify(SRC .. 'nothing recorded with a call site', vim.log.levels.INFO)
		return
	end
	vim.fn.setqflist({}, 'a', { title = 'messages-capture', items = items })
	vim.cmd('copen')
end

---Open the newest entry's call site.
function M.last()
	for i = #entries, 1, -1 do
		local e = entries[i]
		if e.file then
			require('genja.ext.messages').open({ filename = e.file, lnum = e.lnum, text = e.msg })
			return
		end
	end
	vim.notify(SRC .. 'nothing recorded with a call site', vim.log.levels.INFO)
end

---How many entries each calling file sent, most first.
---@return { file: string, count: integer }[]
function M.count_by_source()
	local counts = {}
	for _, e in ipairs(entries) do
		local key = e.file or '?'
		counts[key] = (counts[key] or 0) + 1
	end
	local out = {}
	for file, count in pairs(counts) do
		table.insert(out, { file = file, count = count })
	end
	table.sort(out, function(a, b) return a.count > b.count end)
	return out
end

---Entries with their tracebacks in a scratch buffer.
function M.dump()
	local lines = {}
	for _, e in ipairs(entries) do
		table.insert(lines, ('%s [%d] %s'):format(e.time, e.level, e.msg:gsub('\n', ' ')))
		vim.list_extend(lines, vim.split(e.trace, '\n', { trimempty = true }))
		table.insert(lines, '')
	end
	local buf = vim.api.nvim_create_buf(false, true)
	vim.bo[buf].bufhidden = 'wipe'
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
	vim.api.nvim_win_set_buf(0, buf)
end

return M
