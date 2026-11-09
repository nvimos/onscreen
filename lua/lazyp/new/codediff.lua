-- VSCode-style side-by-side or inline diffs with char-level highlights, an explorer panel,
-- hunk staging, history, PR review and merge conflicts.
-- Upstream: esmuellert/codediff.nvim. Alternatives: diffview, unified.nvim, deltaview.nvim.
-- Downloads a prebuilt diff library on first use (curl or PowerShell, no compiler): `:CodeDiff install`, `:CodeDiff install!` to force.
-- To try: `:CodeDiff` (changes), `:CodeDiff main...HEAD` (branch as in a PR), `:CodeDiff history main..HEAD`,
-- `:CodeDiff pr 512`, `:CodeDiff --inline`. The explorer folder icons want a Nerd Font.

---@type LazySpec
return {
	'esmuellert/codediff.nvim',
	cmd = 'CodeDiff',
	---@type table
	opts = {
		diff = {
			layout = 'side-by-side', -- default; 'inline' = one pane with virtual lines
			-- filler_text = '╱', -- default; '' gives blank alignment rows
			-- compute_moves = false, -- default; true detects moved blocks
			-- jump_to_first_change = true, -- default
			-- ignore_trim_whitespace = false, -- default
			-- compact = false, -- default; true folds unchanged code (toggle with gc)
		},
		explorer = {
			-- position = 'left', -- default; or 'bottom'
			-- width = 40, -- default
			-- view_mode = 'list', -- default; or 'tree'
			-- initial_focus = 'explorer', -- default; or 'original', 'modified'
			-- focus_on_select = false, -- default
		},
		history = {
			-- position = 'bottom', -- default; or 'left'
			-- height = 15, -- default
			-- date_format = '%ar', -- default, relative
		},
		-- highlights = { line_insert = 'DiffAdd', line_delete = 'DiffDelete', char_insert = nil, char_delete = nil }, -- default
	},
}
