-- Show only the first few diagnostics per severity and buffer (virtual text, signs, underline).
-- The rest stay in vim.diagnostic.get(), the loclist and the floats; only the display is cut.
-- First = by line, then column, over every namespace (LSP and each linter together).
--   vim.g.diag_limit   number per severity (default 3); 0 or false: show all
--   b:diag_limit       the same for one buffer, wins over the global one (F2 "show all" sets 0)
-- Keys and setup: plugin/diag-limit.lua. Zen z1 sets the limit to 2 (lua/genja/map-plugin/zenmode.lua).

local SRC = 'lua/genja/diag-limit.lua: '

local M = {}

local DEFAULT = 3
local HANDLERS = { 'virtual_text', 'signs', 'underline' }

---Limit for `bufnr`: b:diag_limit, else g:diag_limit, else DEFAULT; 0 means none.
---@param bufnr integer
---@return integer
function M.limit(bufnr)
	local n = vim.b[bufnr].diag_limit
	if n == nil then
		n = vim.g.diag_limit
	end
	if n == nil then
		n = DEFAULT
	end
	if n == false then
		n = 0
	end
	return n
end

---Identity of a diagnostic across vim.diagnostic.get() copies and handler arguments.
---@param d vim.Diagnostic
---@return string
local function key(d)
	return table.concat({ d.namespace or '', d.lnum, d.col, d.severity or '', d.message }, '\0')
end

---Keys of the diagnostics of `bufnr` that are shown: the first `limit` per severity.
---@param bufnr integer
---@param limit integer
---@return table<string, boolean> shown, integer hidden
local function shown_keys(bufnr, limit)
	local all = vim.diagnostic.get(bufnr)
	table.sort(all, function(a, b)
		if a.lnum ~= b.lnum then
			return a.lnum < b.lnum
		end
		return a.col < b.col
	end)
	local per_severity = {}
	local shown = {}
	local hidden = 0
	for _, d in ipairs(all) do
		local sev = d.severity or vim.diagnostic.severity.ERROR
		per_severity[sev] = (per_severity[sev] or 0) + 1
		if per_severity[sev] <= limit then
			shown[key(d)] = true
		else
			hidden = hidden + 1
		end
	end
	return shown, hidden
end

---How many diagnostics of `bufnr` the limit hides now.
---@param bufnr integer
---@return integer
function M.hidden(bufnr)
	local limit = M.limit(bufnr)
	if limit <= 0 then
		return 0
	end
	local _, hidden = shown_keys(bufnr, limit)
	return hidden
end

---Wrap one built-in handler so it only gets the shown diagnostics.
---@param name string handler in vim.diagnostic.handlers
local function wrap(name)
	local orig = vim.diagnostic.handlers[name]
	if not orig or orig.genja_limited then
		return
	end
	vim.diagnostic.handlers[name] = {
		genja_limited = true,
		show = function(namespace, bufnr, diagnostics, opts)
			local limit = M.limit(bufnr)
			if limit > 0 then
				local shown = shown_keys(bufnr, limit)
				local kept = {}
				for _, d in ipairs(diagnostics) do
					if shown[key(d)] then
						table.insert(kept, d)
					end
				end
				diagnostics = kept
			end
			orig.show(namespace, bufnr, diagnostics, opts)
		end,
		hide = orig.hide,
	}
end

---Redraw every buffer's diagnostics with the current limits.
function M.refresh()
	for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
		if vim.api.nvim_buf_is_loaded(bufnr) then
			vim.diagnostic.show(nil, bufnr)
		end
	end
end

---Set the global limit (0: show all) and redraw.
---@param n integer
function M.set(n)
	vim.g.diag_limit = n
	M.refresh()
end

---<leader>tt3: limit on (3) / off.
function M.toggle()
	if M.limit(0) > 0 and vim.b.diag_limit == nil then
		M.set(0)
		vim.notify(SRC .. 'showing all diagnostics')
	else
		vim.b.diag_limit = nil
		M.set(DEFAULT)
		vim.notify(SRC .. 'first ' .. DEFAULT .. ' diagnostics per severity')
	end
end

---Show everything in this buffer (F2 "show all"); the global limit stays for the others.
---@param bufnr integer
function M.show_all(bufnr)
	vim.b[bufnr].diag_limit = 0
	vim.diagnostic.show(nil, bufnr)
end

---Wrap the handlers once; the namespaces' own configs stay as they are.
function M.setup()
	for _, name in ipairs(HANDLERS) do
		wrap(name)
	end
end

return M
