-- Markdown fixers: typos and markdownlint-cli2 rewrite the file, then the buffer reloads.
--   <leader>mfx   fix this buffer now (after/ftplugin/markdown.vim)
--   on save       the same after every :w, unless vim.g.md_fix_on_save = false
-- markdownlint uses the project's config, else the shared lint/.markdownlint.jsonc (as lua/genja/ext/lint.lua).
-- A fixer that isn't installed is skipped (mason: :MasonToolsInstall).

local SRC = 'lua/genja/ext/md-fix.lua: '

local M = {}

local MARKDOWNLINT_CONFIG = vim.fs.joinpath(vim.fn.stdpath('config'), 'lint', '.markdownlint.jsonc')
local MARKDOWNLINT_PROJECT = {
	'.markdownlint-cli2.jsonc', '.markdownlint-cli2.yaml', '.markdownlint-cli2.cjs',
	'.markdownlint.jsonc', '.markdownlint.json', '.markdownlint.yaml', '.markdownlint.yml',
}

---Fixer commands for `file`, in run order; missing tools are left out.
---@param file string
---@return string[][]
function M.commands(file)
	local cmds = {}
	if vim.fn.executable('typos') == 1 then
		table.insert(cmds, { 'typos', '--write-changes', file })
	end
	if vim.fn.executable('markdownlint-cli2') == 1 then
		local cmd = { 'markdownlint-cli2', '--fix' }
		if not vim.fs.root(file, MARKDOWNLINT_PROJECT) and vim.uv.fs_stat(MARKDOWNLINT_CONFIG) then
			vim.list_extend(cmd, { '--config', MARKDOWNLINT_CONFIG })
		end
		table.insert(cmd, file)
		table.insert(cmds, cmd)
	end
	return cmds
end

---Reload `bufnr` from disk, keeping the view in its windows.
---@param bufnr integer
local function reload(bufnr)
	if not vim.api.nvim_buf_is_loaded(bufnr) or vim.bo[bufnr].modified then
		return -- typed into while the fixers ran: keep the user's text
	end
	local views = {}
	for _, win in ipairs(vim.fn.win_findbuf(bufnr)) do
		views[win] = vim.api.nvim_win_call(win, vim.fn.winsaveview)
	end
	vim.api.nvim_buf_call(bufnr, function() vim.cmd('silent edit') end)
	for win, view in pairs(views) do
		if vim.api.nvim_win_is_valid(win) then
			vim.api.nvim_win_call(win, function() vim.fn.winrestview(view) end)
		end
	end
end

---Run the fixers on the file of `bufnr` one after the other, then reload it.
---@param bufnr integer
---@param save boolean write the buffer first (<leader>mfx); false on BufWritePost
function M.fix(bufnr, save)
	local file = vim.api.nvim_buf_get_name(bufnr)
	if file == '' or vim.bo[bufnr].buftype ~= '' then
		return
	end
	if save then
		vim.api.nvim_buf_call(bufnr, function() vim.cmd('silent update') end)
	end
	local cmds = M.commands(file)
	if #cmds == 0 then
		if save then
			vim.notify(SRC .. 'neither typos nor markdownlint-cli2 found; :MasonToolsInstall', vim.log.levels.WARN)
		end
		return
	end
	local i = 0
	local function next_cmd()
		i = i + 1
		if i > #cmds then
			reload(bufnr)
			return
		end
		-- non-zero exit: what's left unfixed; the linters show it
		vim.system(cmds[i], { cwd = vim.fs.dirname(file) }, vim.schedule_wrap(next_cmd))
	end
	next_cmd()
end

---Fix on save for `bufnr`, unless vim.g.md_fix_on_save is false.
---@param bufnr integer
function M.register(bufnr)
	vim.api.nvim_create_autocmd('BufWritePost', {
		buffer = bufnr,
		group = vim.api.nvim_create_augroup('genja_md_fix_' .. bufnr, { clear = true }),
		callback = function()
			if vim.g.md_fix_on_save ~= false then
				M.fix(bufnr, false)
			end
		end,
	})
end

return M
