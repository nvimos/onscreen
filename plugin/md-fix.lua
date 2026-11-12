-- Markdown fix on save switch (lua/genja/ext/md-fix.lua).
local function toggle() require('genja.ext.md-fix').toggle() end

vim.keymap.set('n', '<leader>tmm', toggle, { desc = 'Toggle: markdown fix on save' })
vim.api.nvim_create_user_command('ToggleMarkdownFix', toggle, { desc = 'Toggle: markdown fix on save' })
