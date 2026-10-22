-- Linters that have no language server (todo-ideas 14e).
-- genja-commit lints gitcommit buffers through it with its own gitlint linter.

---@type LazySpec
return {
	'mfussenegger/nvim-lint',
	-- lazy (default), no trigger: loads on the first require('lint') (genja-commit)

	opts = {
		---@type table<string, string[]>
		linters_by_ft = {},
	},

	config = function(_, opts)
		require('lint').linters_by_ft = opts.linters_by_ft
	end,
}
