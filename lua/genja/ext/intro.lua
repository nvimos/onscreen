-- Intro screen like Nvim 0.13's own (logo, colors, layout), without the
-- charity lines. Follows intro_message()/do_intro_line() in src/nvim/version.c.
-- Drawn as virtual lines on the empty start buffer: the buffer stays
-- unmodified (so :q never warns), and the first edit clears it.

local M = {}

local ns = vim.api.nvim_create_namespace('genja.ext.intro')

local LOGO_ROWS = 3
local SEPARATOR = '────────────────────────────────────────────'

-- full version string as :version prints it, e.g. 'NVIM v0.13.0-dev-1804+gfb1f321b0e'
local function long_version()
	for _, line in ipairs(vim.split(vim.fn.execute('version'), '\n')) do
		if vim.startswith(line, 'NVIM ') then
			return line
		end
	end
	return 'NVIM v' .. tostring(vim.version())
end

-- Nvim's lines, minus the last separator and the two charity lines after it
local function intro_lines()
	return {
		'│ ╲ ││',
		'││╲╲││',
		'││ ╲ │',
		'',
		long_version(),
		SEPARATOR,
		'Nvim is open source and freely distributable',
		'https://neovim.io/#chat',
		SEPARATOR,
		'type  :help nvim<Enter>     if you are new! ',
		'type  :checkhealth<Enter>   to optimize Nvim',
		'type  :q<Enter>             to exit         ',
		'type  :help<Enter>          for help        ',
		SEPARATOR,
		string.format('type  :help news<Enter>     for v%d.%d notes ', vim.version().major, vim.version().minor),
	}
end

-- logo: box characters are Special up to the first '╲' on the row, String from there
local function logo_chunks(line)
	local chunks = {}
	local seen_diagonal = false
	for _, char in ipairs(vim.fn.split(line, '\\zs')) do
		local hl = 'Normal'
		if char:byte() >= 0x80 then
			if char == '╲' then
				seen_diagonal = true
			end
			if seen_diagonal then
				hl = 'String'
			else
				hl = 'Special'
			end
		end
		table.insert(chunks, { char, hl })
	end
	return chunks
end

-- 'type  :cmd<Enter>  text': ':' and '<Enter>' SpecialKey, cmd Identifier
local function command_chunks(line)
	local prefix, cmd, key, rest = line:match('^([^:]*):([^<]*)(<[^>]*>)(.*)$')
	if not prefix then
		return { { line, 'Normal' } }
	end
	return {
		{ prefix, 'Normal' },
		{ ':', 'SpecialKey' },
		{ cmd, 'Identifier' },
		{ key, 'SpecialKey' },
		{ rest, 'Normal' },
	}
end

local function line_chunks(index, line)
	if index <= LOGO_ROWS then
		return logo_chunks(line)
	end
	if vim.startswith(line, 'NVIM') then
		return { { line, 'String' } }
	end
	if line == SEPARATOR then
		return { { line, 'NonText' } }
	end
	return command_chunks(line)
end

-- the window's end-of-buffer char ('fillchars' eob:, default '~'); virtual
-- lines cover those rows, so each one draws it in column 0 itself
local function eob_char(win)
	local fillchars = vim.api.nvim_get_option_value('fillchars', { win = win })
	local char = fillchars:match('eob:([^,]+)')
	if char == nil then
		char = '~'
	end
	return char
end

local function render(buf, win)
	vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)
	local lines = intro_lines()
	local width = vim.api.nvim_win_get_width(win)
	local height = vim.api.nvim_win_get_height(win)

	-- same vertical placement and size limits as Nvim
	local row = math.floor(math.max(height - (#lines - 1), 0) / 2)
	if row < 2 or width < 50 then
		return
	end
	--
	-- shift up by 10% of the height, but keep at least 2 rows
	-- row = math.max(row - math.floor(height * 0.10), 2)
	-- local shift_left = math.floor(width * 0.10)
	local shift_left = 0

	local eob = eob_char(win)
	local eob_width = vim.fn.strdisplaywidth(eob)
	local virt = {}
	-- buffer line 1 takes screen row 0, virtual lines start at row 1
	for _ = 2, row do
		table.insert(virt, { { eob, 'EndOfBuffer' } })
	end
	for i, line in ipairs(lines) do
		-- centred on the whole width like Nvim's; the eob char takes part of the pad
		local pad = math.floor((width - vim.fn.strdisplaywidth(line)) / 2) - shift_left - eob_width
		pad = math.max(pad, 0)
		local chunks = { { eob, 'EndOfBuffer' }, { string.rep(' ', pad), 'Normal' } }
		vim.list_extend(chunks, line_chunks(i, line))
		table.insert(virt, chunks)
	end
	vim.api.nvim_buf_set_extmark(buf, ns, 0, 0, { virt_lines = virt, virt_lines_leftcol = true })
end

local function is_empty_start_buffer(buf)
	if vim.fn.argc() > 0 then
		return false
	end
	if vim.api.nvim_buf_get_name(buf) ~= '' or vim.bo[buf].buftype ~= '' then
		return false
	end
	if vim.api.nvim_buf_line_count(buf) > 1 then
		return false
	end
	return vim.api.nvim_buf_get_lines(buf, 0, 1, false)[1] == ''
end

function M.show()
	local buf = vim.api.nvim_get_current_buf()
	local win = vim.api.nvim_get_current_win()
	if not is_empty_start_buffer(buf) then
		return
	end
	render(buf, win)

	local group = vim.api.nvim_create_augroup('GenjaIntro', { clear = true })
	local function clear()
		if vim.api.nvim_buf_is_valid(buf) then
			vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)
		end
		pcall(vim.api.nvim_del_augroup_by_id, group)
	end
	-- Nvim's intro also goes away on the first edit, buffer switch or split
	vim.api.nvim_create_autocmd({ 'InsertEnter', 'TextChanged', 'BufLeave' }, {
		group = group, buffer = buf, callback = clear,
	})
	vim.api.nvim_create_autocmd('WinNew', { group = group, callback = clear })
	vim.api.nvim_create_autocmd('VimResized', {
		group = group,
		callback = function()
			if vim.api.nvim_win_is_valid(win) and vim.api.nvim_win_get_buf(win) == buf then
				render(buf, win)
			end
		end,
	})
end

return M
