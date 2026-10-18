-- «idea 19 companion»: codecompanion.nvim chat with Claude Code over ACP.
-- Needs Claude Code, `npm install -g @agentclientprotocol/claude-agent-acp`, and
-- CLAUDE_CODE_OAUTH_TOKEN (from `claude setup-token`) in the environment, never in here.
-- Usage and quirks: doc-wip/readme.idea19-companion.md

---@type LazySpec
return {
	'olimorris/codecompanion.nvim',
	version = '^20.0.0', -- the docs used here (interactions key, ACP) describe v20
	dependencies = {
		'nvim-lua/plenary.nvim',
		'nvim-treesitter/nvim-treesitter',
	},
	cmd = { 'CodeCompanion', 'CodeCompanionChat', 'CodeCompanionActions' },
	keys = {
		{ '<leader>ac', '<cmd>CodeCompanionChat Toggle<cr>', desc = 'idea 19 companion: chat toggle' },
		{ '<leader>aa', '<cmd>CodeCompanionActions<cr>', desc = 'idea 19 companion: action palette' },
		-- ':' (not <cmd>) so the visual range reaches the command
		{ '<leader>aa', ':CodeCompanionActions<cr>', mode = 'x', desc = 'idea 19 companion: action palette (selection)' },
	},
	opts = {
		interactions = {
			chat = { adapter = 'claude_code' }, -- ACP agent: runs claude-agent-acp
		},
	},
}
