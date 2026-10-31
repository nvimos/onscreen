-- Options: defaults merged with setup(opts).

---@class genja-commit.Keys
---@field commit string|string[] popup: commit; several keys: <C-CR> doesn't reach nvim through Windows Terminal
---@field fill string popup: insert 'update: <file>'
---@field abort string[] popup, normal mode: close
---@field generate string all gitcommit buffers: write the message
---@field cancel string while generating: stop

---@class genja-commit.LintOpts
---@field title_max integer
---@field body_max integer
---@field debounce integer ms after the last change
---@field install_gitlint boolean install gitlint via Mason when Python is on PATH

---@class genja-commit.ClaudeOpts
---@field model? string
---@field effort? string

---@class genja-commit.CopilotOpts
---@field model? string

---@class genja-commit.GeminiOpts
---@field model? string

---@class genja-commit.AichatOpts
---@field role? string used when `aichat --list-roles` has it
---@field model? string

---@class genja-commit.GenerateOpts
---@field order string[] first one on PATH is used: 'claude', 'copilot', 'gemini', 'aichat'
---@field timeout integer seconds
---@field diff_max integer bytes of staged diff sent
---@field subjects integer recent commit subjects sent as style examples
---@field prompt? string replaces the built-in instructions
---@field claude genja-commit.ClaudeOpts
---@field copilot genja-commit.CopilotOpts
---@field gemini genja-commit.GeminiOpts
---@field aichat genja-commit.AichatOpts

---@alias genja-commit.Window 'split'|'float'

---@class genja-commit.Opts
---@field window? genja-commit.Window commit message window: a split at the bottom, or a centred float
---@field keys? genja-commit.Keys
---@field lint? genja-commit.LintOpts
---@field generate? genja-commit.GenerateOpts
---@field copilot? boolean set b:copilot_enabled in gitcommit buffers
---@field conventional? boolean Conventional Commits mode when git config and project files don't say
---@field conventional_types? string[] allowed types in that mode
---@field on_commit? fun(dir: string) after a successful popup commit

---Opts after merging with the defaults: every field set.
---@class genja-commit.Config
---@field window genja-commit.Window
---@field keys genja-commit.Keys
---@field lint genja-commit.LintOpts
---@field generate genja-commit.GenerateOpts
---@field copilot boolean
---@field conventional boolean
---@field conventional_types string[]
---@field on_commit? fun(dir: string)

local M = {}

---@type genja-commit.Config
local defaults = {
	window = 'split', -- the float was awkward to use (2026-10-31)
	keys = {
		commit = { '<C-CR>', '<M-CR>', '<C-s>' },
		fill = '<M-u>',
		abort = { '<Esc>', 'q' },
		generate = '<M-g>',
		cancel = '<C-c>',
	},
	lint = {
		title_max = 65,
		body_max = 72,
		debounce = 300,
		install_gitlint = true,
	},
	generate = {
		order = { 'claude', 'copilot', 'gemini', 'aichat' },
		timeout = 60,
		diff_max = 20000,
		subjects = 15,
		claude = { model = 'haiku', effort = 'low' },
		copilot = {},
		gemini = {},
		aichat = { role = 'gitcommit' },
	},
	copilot = true,
	conventional = false,
	conventional_types = {
		'feat', 'fix', 'docs', 'style', 'refactor', 'perf', 'test', 'build', 'ci', 'chore', 'revert',
	},
}

---@type genja-commit.Config
local current = vim.deepcopy(defaults)

---@param opts? genja-commit.Opts
function M.set(opts)
	opts = opts or {}
	current = vim.tbl_deep_extend('force', vim.deepcopy(defaults), opts)
	-- lists replace, not merge by index
	if opts.keys and opts.keys.abort then
		current.keys.abort = opts.keys.abort
	end
	if opts.generate and opts.generate.order then
		current.generate.order = opts.generate.order
	end
	if opts.conventional_types then
		current.conventional_types = opts.conventional_types
	end
end

---@return genja-commit.Config
function M.get()
	return current
end

return M
