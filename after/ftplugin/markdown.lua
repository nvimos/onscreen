-- <F2> tasks: lines to checklist (lua/genja/md-checklist.lua), glow preview (lua/genja/md-glow.lua); vim settings in markdown.vim
require('genja.md-checklist').register(vim.api.nvim_get_current_buf())
require('genja.md-glow').register(vim.api.nvim_get_current_buf())
