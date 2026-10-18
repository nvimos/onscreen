-- Idea #19 A: keys for Claude Code in a floaterm (code: lua/genja/claude.lua).
-- :ClaudeFterm is in lua/genja/auto-alias.vim with the other Fterm commands.
local map = vim.keymap.set

local function paste_context() require('genja.claude').paste_context() end
local function prompt() require('genja.claude').prompt() end

map('n', '<leader>pc', paste_context, { desc = 'Claude: paste @file into claude' })
map('x', '<leader>pc', paste_context, { desc = 'Claude: paste selection into claude' })
map({ 'n', 'x' }, '<leader>pC', prompt, { desc = 'Claude: prompt popup (visual: with selection)' })
