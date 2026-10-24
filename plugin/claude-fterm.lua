-- Idea #19 A: keys for Claude Code in a floaterm (plug-wip/genja-claudefterm.nvim, which also has :ClaudeFterm).
local map = vim.keymap.set

local function prompt() require('genja-ask').open() end
local function paste_context() require('genja-claudefterm').paste_context() end
local function list() require('genja-claudefterm').list() end

map({ 'n', 'x' }, '<leader>pc', prompt, { desc = 'Claude: ask popup, same as <M-?> (visual: with selection)' })
map('n', '<leader>pC', paste_context, { desc = 'Claude: paste @file into claude' })
map('x', '<leader>pC', paste_context, { desc = 'Claude: paste selection into claude' })
map('n', '<leader>mC', list, { desc = 'UI: claude terminals (running, one per project)' })
