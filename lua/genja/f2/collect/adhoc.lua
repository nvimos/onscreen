-- <F2> source, group `adhoc`: one-off fixes for the current context.
--   go mod init <dirname>  a .go file (or an oil dir with .go files) with no
--                          go.mod/go.work above; gopls restarts after it.
-- The rootless check repeats the one in genja-completion011's lang/go.lua.

local run = require('genja.f2.run')

local M = {}

-- restart the gopls clients on Go buffers in or below dir, so they leave
-- single-file mode; re-firing FileType lets vim.lsp.enable attach again
-- (same trick as lang/php.lua)
---@param dir string
local function restart_gopls(dir)
	local bufs = {}
	for _, client in ipairs(vim.lsp.get_clients({ name = 'gopls' })) do
		local below = false
		for buf in pairs(client.attached_buffers) do
			local name = vim.fs.normalize(vim.api.nvim_buf_get_name(buf))
			if vim.startswith(name:lower(), dir:lower() .. '/') then
				below = true
				break
			end
		end
		if below then
			for buf in pairs(client.attached_buffers) do
				bufs[buf] = true
			end
			client:stop(true)
		end
	end
	vim.defer_fn(function()
		for buf in pairs(bufs) do
			if vim.api.nvim_buf_is_loaded(buf) and vim.bo[buf].filetype == 'go' then
				pcall(vim.api.nvim_exec_autocmds, 'FileType', { group = 'nvim.lsp.enable', buffer = buf, modeline = false })
			end
		end
	end, 500)
end

---@param ctx genja.f2.Ctx
---@return genja.f2.Task?
local function go_mod_init(ctx)
	local is_go = ctx.filetype == 'go'
	if ctx.filetype == 'oil' then
		is_go = #vim.fn.glob(ctx.dir .. '/*.go', true, true) > 0
	end
	if not is_go or vim.env.GO111MODULE == 'off' or vim.fn.executable('go') == 0 then
		return nil
	end
	if vim.fs.root(ctx.dir, { 'go.work', 'go.mod' }) then
		return nil
	end
	local dir = ctx.dir
	local name = vim.fs.basename(dir)
	return {
		group = require('genja.f2.groups').adhoc,
		label = 'go mod init ' .. name,
		action = function()
			run.overseer('go mod init ' .. name, { 'go', 'mod', 'init', name }, dir, function(code)
				if code == 0 then
					restart_gopls(dir)
				end
			end)
		end,
	}
end

---@param ctx genja.f2.Ctx
---@param done fun(tasks: genja.f2.Task[])
function M.collect(ctx, done)
	local items = {}
	local go = go_mod_init(ctx)
	if go then
		table.insert(items, go)
	end
	done(items)
end

return M
