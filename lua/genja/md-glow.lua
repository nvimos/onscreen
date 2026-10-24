-- Markdown: preview the buffer's file with glow in a new terminal window; any key closes it.
-- <F2> task, registered per markdown buffer from after/ftplugin/markdown.lua.
-- Windows only for now; the other branch only says so.
local SRC = 'lua/genja/md-glow.lua: '

local M = {}

-- pwsh single-quoted string: ' is doubled, nothing else expands
---@param s string
---@return string
local function pwsh_quote(s)
	return "'" .. s:gsub("'", "''") .. "'"
end

---@param file string
local function open_windows(file)
	if vim.fn.executable('pwsh') == 0 then
		vim.notify(SRC .. 'pwsh not found', vim.log.levels.ERROR)
		return
	end
	local script = table.concat({
		'$Host.UI.RawUI.WindowTitle = ' .. pwsh_quote('glow: ' .. vim.fs.basename(file)),
		'Set-Location -LiteralPath ' .. pwsh_quote(vim.fs.dirname(file)),
		'glow ' .. pwsh_quote(file),
		"Write-Host ''",
		"Write-Host '-- any key closes --' -NoNewline",
		'[void][Console]::ReadKey($true)',
	}, '\n')
	-- -EncodedCommand (base64 of UTF-16LE) avoids quoting the path through two shells
	local utf16 = vim.iconv(script, 'utf-8', 'utf-16le')
	if not utf16 then
		vim.notify(SRC .. 'iconv to utf-16le failed', vim.log.levels.ERROR)
		return
	end
	local encoded = vim.base64.encode(utf16)
	-- the outer pwsh runs hidden (job); Start-Process gives the inner one its own window
	local outer = "Start-Process pwsh -ArgumentList '-NoProfile','-EncodedCommand','" .. encoded .. "'"
	local job = vim.fn.jobstart({ 'pwsh', '-NoProfile', '-NonInteractive', '-Command', outer })
	if job <= 0 then
		vim.notify(SRC .. 'could not start pwsh (' .. job .. ')', vim.log.levels.ERROR)
	end
end

-- not tested; pick a terminal ($TERMINAL, x-terminal-emulator, ...) when needed
---@param _file string
local function open_unix(_file)
	vim.notify(SRC .. 'glow preview: only implemented on Windows', vim.log.levels.WARN)
end

function M.preview()
	local file = vim.api.nvim_buf_get_name(0)
	if file == '' or vim.bo.buftype ~= '' then
		vim.notify(SRC .. 'buffer has no file', vim.log.levels.WARN)
		return
	end
	if vim.fn.executable('glow') == 0 then
		vim.notify(SRC .. 'glow not found', vim.log.levels.ERROR)
		return
	end
	if vim.bo.modified then
		vim.notify(SRC .. 'unsaved changes, glow shows the file on disk', vim.log.levels.WARN)
	end
	file = vim.fs.normalize(vim.fn.fnamemodify(file, ':p'))
	if vim.fn.has('win32') == 1 then
		open_windows(file)
	else
		open_unix(file)
	end
end

---@param buf integer
function M.register(buf)
	require('genja.f2').add_task('markdown', 'preview: glow in a new terminal')
		:fn(function()
			M.preview()
		end)
		:buffer(buf)
		:add()
end

return M
