-- <F2> task: lines to checklist (lua/genja/md-checklist.lua); vim settings in markdown.vim
require('genja.md-checklist').register(vim.api.nvim_get_current_buf())
