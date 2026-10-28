-- Insert-mode abbreviations for markdown buffers, from lua/genja/ext/md-abbrev.txt:
-- one `wrong right` pair per line (right may have spaces), `#` starts a comment.
-- Read when a markdown buffer opens (after/ftplugin/markdown.vim), so edits apply to new buffers.

local SRC = 'lua/genja/ext/md-abbrev.lua: '

local M = {}

M.FILE = vim.fs.joinpath(vim.fn.stdpath('config'), 'lua', 'genja', 'ext', 'md-abbrev.txt')

---Pairs from `lines`: { wrong, right }; blank and `#` lines skipped.
---@param lines string[]
---@return { [1]: string, [2]: string }[]
function M.parse(lines)
	local pairs_ = {}
	for _, line in ipairs(lines) do
		local text = vim.trim(line)
		if text ~= '' and text:sub(1, 1) ~= '#' then
			local wrong, right = text:match('^(%S+)%s+(.+)$')
			if wrong then
				table.insert(pairs_, { wrong, right })
			end
		end
	end
	return pairs_
end

---Set the abbreviations in `bufnr`.
---@param bufnr integer
---@param file? string default M.FILE
function M.apply(bufnr, file)
	file = file or M.FILE
	if vim.fn.filereadable(file) == 0 then
		return
	end
	local ok, lines = pcall(vim.fn.readfile, file)
	if not ok then
		vim.notify(SRC .. 'cannot read ' .. file, vim.log.levels.WARN)
		return
	end
	for _, pair in ipairs(M.parse(lines)) do
		vim.keymap.set('ia', pair[1], pair[2], { buffer = bufnr, desc = 'Markdown: fix ' .. pair[1] })
	end
end

return M
