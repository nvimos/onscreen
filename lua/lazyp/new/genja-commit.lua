-- Commit message popup (oil), gitcommit linting, <M-g> message generation.
-- Details: plug-wip/genja-commit.nvim/CLAUDE.md.

local Maps = require('genja.map-plugin')

---@type LazySpec
return {
	dir = vim.fn.stdpath('config') .. '/plug-wip/genja-commit.nvim',
	dependencies = { { dir = vim.fn.stdpath('config') .. '/plug-wip/genja-util.nvim' } },
	-- also loads on require('genja-commit') from lua/genja/oil/git-commit.lua
	ft = 'gitcommit',
	keys = Maps:keys(),

	---@type genja-commit.Opts
	opts = {
		lint = { title_max = 65, body_max = 72 },
		generate = {
			order = { 'claude', 'copilot', 'gemini', 'aichat' },
			timeout = 60,
			claude = { model = 'haiku', effort = 'low' },
			aichat = { role = 'gitcommit' },
		},
		-- Conventional Commits off unless a project or git config turns it on;
		-- per repo: git config genja-commit.conventional true|false
		conventional = false,
		on_commit = function() require('genja.oil').refresh_oil_git() end,
	},

	config = function(_, opts)
		require('genja-commit').setup(opts)
	end,
}
