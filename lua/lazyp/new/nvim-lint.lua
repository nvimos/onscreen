-- Linters that have no language server (todo-ideas 14e): lua/genja/ext/lint.lua.
-- genja-commit lints gitcommit buffers through it with its own gitlint linter.
-- Install the tools: :MasonToolsInstall (mason-tool-installer reads require('genja.ext.lint').mason).

---@type LazySpec
return {
	'mfussenegger/nvim-lint',
	event = 'VeryLazy',

	opts = {
		---@type table<string, string[]> genja.ext.lint runs its own list (genja.ext.lint.by_ft) per buffer
		linters_by_ft = {},
	},

	config = function(_, opts)
		require('lint').linters_by_ft = opts.linters_by_ft
		require('genja.ext.lint').setup()
	end,
}
