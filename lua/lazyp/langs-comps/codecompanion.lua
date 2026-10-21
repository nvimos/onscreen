-- «idea 19 companion»: codecompanion.nvim chat with Claude Code over ACP.
-- Needs Claude Code, `npm install -g @agentclientprotocol/claude-agent-acp`, and
-- CLAUDE_CODE_OAUTH_TOKEN (from `claude setup-token`) in the environment, never in here.
-- Usage and quirks: doc-wip/readme.idea19-companion.md

local Maps = require('genja.map-plugin')

---@type LazySpec
return {
	'olimorris/codecompanion.nvim',
	version = '^20.0.0', -- the docs used here (interactions key, ACP) describe v20
	dependencies = {
		'nvim-lua/plenary.nvim',
		'nvim-treesitter/nvim-treesitter',
	},
	cmd = { 'CodeCompanion', 'CodeCompanionChat', 'CodeCompanionActions' },
	keys = Maps:keys(),
	opts = {
		interactions = {
			chat = { adapter = 'claude_code' }, -- ACP agent: runs claude-agent-acp
		},
	},
}
