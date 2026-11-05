-- Commit message popup (oil), gitcommit linting, <M-g> message generation.
-- Details: plug-wip/genja-commit.nvim/CLAUDE.md.

local Maps = require('genja.map-plugin')

local Wip = require('genja.plug-wip')

---@type LazySpec
return {
	'tox2ik/genja-commit.nvim',
	dir = Wip.dir('genja-commit.nvim'),
	dependencies = { { 'tox2ik/genja-util.nvim', dir = Wip.dir('genja-util.nvim') } },
	-- also loads on require('genja-commit') from lua/genja/oil/git-commit.lua
	ft = 'gitcommit',
	keys = Maps:keys(),

	---@type genja-commit.Opts
	opts = {
		window = 'split', -- or 'float'
		lint = { title_max = 65, body_max = 72 },
		generate = {
			order = { 'claude', 'copilot', 'gemini', 'aichat', 'ollama' },
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
