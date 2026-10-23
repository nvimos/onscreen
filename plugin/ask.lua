-- Ask popup (idea 16): lua/genja/ask.lua. <leader>pC (plugin/claude-fterm.lua) opens it too.
local function ask() require('genja.ask').open() end

vim.keymap.set({ 'n', 'i', 'x' }, '<M-?>', ask, { desc = 'AI: ask popup (visual: with selection)' })
