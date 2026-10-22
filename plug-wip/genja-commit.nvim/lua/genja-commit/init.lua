-- genja-commit: commit message popup, gitcommit linting, message generation.

local config = require('genja-commit.config')
local convention = require('genja-commit.convention')
local git = require('genja-commit.git')
local popup = require('genja-commit.popup')
local lint = require('genja-commit.lint')
local generate = require('genja-commit.generate')

local M = {}

---Lint, <M-g> and copilot for one gitcommit buffer.
---@param buf integer
function M.attach(buf)
	if vim.b[buf].genja_commit_attached then
		return
	end
	vim.b[buf].genja_commit_attached = true
	local opts = config.get()
	-- once per buffer: lint runs on every change; reopen to pick up a new setting
	vim.b[buf].genja_commit_conventional = convention.enabled(git.buf_dir(buf))
	if opts.copilot then
		vim.b[buf].copilot_enabled = true
	end
	vim.keymap.set({ 'n', 'i' }, opts.keys.generate, function() generate.run(buf) end,
		{ buffer = buf, desc = 'Commit: generate message' })
	lint.attach(buf)
end

---@param opts? genja-commit.Opts
function M.setup(opts)
	config.set(opts)
	local group = vim.api.nvim_create_augroup('genja_commit', { clear = true })
	vim.api.nvim_create_autocmd('FileType', {
		group = group,
		pattern = 'gitcommit',
		callback = function(ev) M.attach(ev.buf) end,
	})
	-- loaded by the gitcommit buffer itself (lazy `ft`)
	if vim.bo.filetype == 'gitcommit' then
		M.attach(vim.api.nvim_get_current_buf())
	end
end

---Open the commit popup for the repo at dir.
---@param dir? string
function M.open(dir)
	popup.open(dir)
end

return M
