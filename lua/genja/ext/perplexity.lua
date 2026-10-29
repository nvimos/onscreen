-- Perplexity search in the browser; used by plugin/perplexity-search.lua and the right-click menu.

local M = {}

---Open a Perplexity search for `q`; blank queries do nothing.
---@param q string?
function M.search(q)
	q = vim.trim(q or '')
	if q ~= '' then
		vim.ui.open('https://www.perplexity.ai/search?q=' .. vim.uri_encode(q, 'rfc2396'))
	end
end

---Search the visual selection, then leave visual mode.
function M.selection()
	local lines = vim.fn.getregion(vim.fn.getpos('v'), vim.fn.getpos('.'), { type = vim.fn.mode() })
	vim.api.nvim_feedkeys(vim.keycode('<Esc>'), 'n', false)
	M.search(table.concat(lines, '\n'))
end

return M
