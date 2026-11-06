-- Diagnostics limit: the first 3 per severity and buffer are drawn (lua/genja/ext/diag-limit.lua).
require('genja.ext.diag-limit').setup()

local function toggle_diag_limit() require('genja.ext.diag-limit').toggle() end
local function toggle_diagnostics() vim.diagnostic.enable(not vim.diagnostic.is_enabled()) end

vim.keymap.set('', '<leader>ttt', toggle_diagnostics, { desc = 'Toggle: diagnostics, all'})
vim.keymap.set('', '<leader>tt3', toggle_diag_limit,  { desc = 'Toggle: diagnostics, 3 per severity' })
