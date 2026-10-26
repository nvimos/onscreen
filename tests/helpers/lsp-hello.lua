-- Time a language server from opening a file to its first useful answer: attach, then a completion
-- at the end of the file's last line that contains `want`. Runs inside an nvim with the real config.
-- Used by tests/comps011 (ready cases) and tests/manual/measure-lua-ls.ps1:
--   local r = dofile('tests/helpers/lsp-hello.lua').measure(file, 'hello', 15000)
-- r: { server, attach_ms, ready_ms, tries } or { error, ms }; times count from opening the file.
local M = {}

---@param t0 number vim.uv.hrtime() at start
---@return integer
local function since(t0)
	return math.floor((vim.uv.hrtime() - t0) / 1e6)
end

---@param file string
---@param want string completion label to wait for
---@param timeout integer ms for attach + ready together
---@return table
function M.measure(file, want, timeout)
	-- lazy's VeryLazy waits for UIEnter, which a headless nvim never sends
	if vim.g.did_very_lazy ~= true then
		vim.api.nvim_exec_autocmds('UIEnter', {})
	end

	local t0 = vim.uv.hrtime()
	vim.cmd.edit(vim.fn.fnameescape(file))

	local client = nil
	vim.wait(timeout, function()
		client = vim.lsp.get_clients({ bufnr = 0 })[1]
		return client ~= nil
	end, 20)
	if not client then
		return { error = 'no client attached', ms = since(t0) }
	end
	local r = { server = client.name, attach_ms = since(t0), tries = 0 }

	-- end of the last line; built by hand: normal mode can't put the cursor past the last char
	local last = vim.api.nvim_buf_line_count(0)
	local line = vim.api.nvim_buf_get_lines(0, last - 1, last, false)[1]
	local params = {
		textDocument = vim.lsp.util.make_text_document_params(0),
		position = { line = last - 1, character = #line },
	}

	-- the server answers an empty list until it is ready: ask again
	while since(t0) < timeout do
		r.tries = r.tries + 1
		local res = vim.lsp.buf_request_sync(0, 'textDocument/completion', params, 2000)
		for _, x in pairs(res or {}) do
			local list = x.result or {}
			for _, item in ipairs(list.items or list) do
				if item.label == want then
					r.ready_ms = since(t0)
					return r
				end
			end
		end
		vim.wait(100)
	end
	return { error = ('no %q within %d ms'):format(want, timeout), ms = since(t0), attach_ms = r.attach_ms, tries = r.tries }
end

return M
