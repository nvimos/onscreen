-- <F2> tasks: lines to checklist (lua/genja/md-checklist.lua), glow preview (lua/genja/md-glow.lua); vim settings in markdown.vim
-- Fixers (lua/genja/md-fix.lua): <leader>mfx now, on save unless vim.g.md_fix_on_save = false.
-- Abbreviations from lua/genja/md-abbrev.txt (lua/genja/md-abbrev.lua).
local buf = vim.api.nvim_get_current_buf()
require('genja.md-checklist').register(buf)
require('genja.md-glow').register(buf)
require('genja.md-fix').register(buf)
require('genja.md-abbrev').apply(buf)

vim.keymap.set('n', '<leader>mfx', function() require('genja.md-fix').fix(buf, true) end,
	{ buffer = buf, desc = 'Markdown: fix typos and lint (typos, markdownlint)' })
