-- not used: 2026-10
-- Replaced by neogit (UI), gitsigns (hunks), diffview (diffs), mini.git (:Git).

---@type LazySpec
return {
	-- git ui
	'tpope/vim-fugitive',
	enabled = false,
	lazy = true,
	cmd = 'Git'
}
