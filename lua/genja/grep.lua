--- Custom live grep: ripgrep wrapper with rg flags typed in the prompt and a root choice.
--- Prompt syntax: `pattern  -g *.lua -t php`  (two spaces split the pattern from rg args).
--- In the picker: <M-r> cycle root (cwd > git > file), <M-i> toggle ignored dirs, <M-g> add `  -g `.

local pickers = require 'telescope.pickers'
local finders = require 'telescope.finders'
local make_entry = require 'telescope.make_entry'
local sorters = require 'telescope.sorters'
local actions = require 'telescope.actions'
local action_state = require 'telescope.actions.state'
local conf = require('telescope.config').values

---@alias genja.GrepRoot 'cwd'|'git'|'file'

---@class genja.LiveGrepOpts
---@field root? genja.GrepRoot     where rg runs (default 'cwd')
---@field cwd? string|false        explicit directory, overrides root
---@field hidden? boolean          search dotfiles (default true)
---@field no_ignore? boolean       --no-ignore and drop `exclude` (default false)
---@field exclude? string[]        names excluded unless no_ignore (default node_modules, vendor)
---@field extra_args? string[]     always passed to rg
---@field separator? string        splits pattern from rg args in the prompt (default '  ')
---@field min_chars? integer       pattern length before rg runs (default 2)
---@field default_text? string     initial prompt

local M = {}

---@type genja.LiveGrepOpts
M.defaults = {
	root = 'cwd',
	hidden = true,
	no_ignore = false,
	exclude = { 'node_modules', 'vendor' },
	extra_args = {},
	separator = '  ',
	min_chars = 2,
}

---@type genja.GrepRoot[]
local roots = { 'cwd', 'git', 'file' }

---@param r genja.GrepRoot
---@return genja.GrepRoot
local function next_root(r)
	for i, v in ipairs(roots) do
		if v == r then return roots[i % #roots + 1] end
	end
	return roots[1]
end

---@param root genja.GrepRoot
---@return string dir
function M.resolve_root(root)
	local cwd = vim.uv.cwd() or vim.fn.getcwd()
	local name = vim.api.nvim_buf_get_name(0)
	local is_file = name ~= '' and vim.bo.buftype == ''
	if root == 'file' then
		return is_file and vim.fs.dirname(name) or cwd
	elseif root == 'git' then
		return vim.fs.root(is_file and name or cwd, '.git') or cwd
	end
	return cwd
end

--- Split rg args, honouring "double" and 'single' quotes.
---@param s string
---@return string[]
local function split_args(s)
	local out, i, n = {}, 1, #s
	while i <= n do
		local c = s:sub(i, i)
		if c:match '%s' then
			i = i + 1
		elseif c == '"' or c == "'" then
			local j = s:find(c, i + 1, true) or n + 1
			out[#out + 1] = s:sub(i + 1, j - 1)
			i = j + 1
		else
			local j = s:find('%s', i) or n + 1
			out[#out + 1] = s:sub(i, j - 1)
			i = j
		end
	end
	return out
end

---@param o genja.LiveGrepOpts
---@return fun(prompt: string): string[]?
local function command_generator(o)
	local base = { 'rg', '--color=never', '--no-heading', '--with-filename',
		'--line-number', '--column', '--smart-case', '--glob', '!.git' }
	if o.hidden then base[#base + 1] = '--hidden' end
	if o.no_ignore then
		base[#base + 1] = '--no-ignore'
	else
		for _, d in ipairs(o.exclude) do vim.list_extend(base, { '--glob', '!' .. d }) end
	end
	vim.list_extend(base, o.extra_args)

	return function(prompt)
		if not prompt or prompt == '' then return nil end
		local pat, rest = prompt, nil
		local s = prompt:find(o.separator, 1, true)
		if s then pat, rest = prompt:sub(1, s - 1), prompt:sub(s + #o.separator) end
		if #pat < o.min_chars then return nil end
		local cmd = vim.deepcopy(base)
		if rest then vim.list_extend(cmd, split_args(rest)) end
		vim.list_extend(cmd, { '--', pat })
		return cmd
	end
end

--- Close the picker and open it again with `patch`, keeping the prompt text.
---@param bufnr integer
---@param o genja.LiveGrepOpts
---@param patch genja.LiveGrepOpts
local function reopen(bufnr, o, patch)
	local prompt = action_state.get_current_line()
	actions.close(bufnr)
	M.live_grep(vim.tbl_extend('force', o, patch, { default_text = prompt }))
end

---@param opts? genja.LiveGrepOpts
function M.live_grep(opts)
	---@type genja.LiveGrepOpts
	local o = vim.tbl_extend('force', M.defaults, opts or {})
	o.cwd = o.cwd or M.resolve_root(o.root)

	pickers.new(o, {
		prompt_title = ('rg [%s%s] %s'):format(o.root, o.no_ignore and ' +ignored' or '',
			vim.fn.fnamemodify(o.cwd, ':~')),
		finder = finders.new_job(command_generator(o), make_entry.gen_from_vimgrep(o), nil, o.cwd),
		previewer = conf.grep_previewer(o),
		sorter = sorters.highlighter_only(o),
		attach_mappings = function(_, map)
			map({ 'i', 'n' }, '<M-r>', function(bufnr)
				reopen(bufnr, o, { root = next_root(o.root), cwd = false })
			end, { desc = 'grep: cycle root cwd/git/file' })
			map({ 'i', 'n' }, '<M-i>', function(bufnr)
				reopen(bufnr, o, { no_ignore = not o.no_ignore })
			end, { desc = 'grep: toggle ignored dirs' })
			map('i', '<M-g>', function(bufnr)
				local line = action_state.get_current_line()
				if not line:find(o.separator, 1, true) then
					action_state.get_current_picker(bufnr):set_prompt(line .. o.separator .. '-g ')
				end
			end, { desc = 'grep: add -g glob' })
			return true
		end,
	}):find()
end

return M
