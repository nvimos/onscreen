-- Completion entry point (nvim-cmp).
--
-- Each feature is one file in this directory that returns
--
--   function(cmp, opts) ... end
--
-- and adds its part to `opts`, the table that is finally passed to cmp.setup().
-- To add a feature, add a file and put its name in M.features.

local M = {}

M.features = {
	'keymaps', -- <Tab>, <CR>, ...
	'snippets', -- snippet expansion
	'lsp', -- language servers
	'path', -- file names
	'buffer', -- words in the buffer
	'lazydev', -- require('...') module names in Lua
	'cmdline', -- : commands, :help topics, / search
	'appearance', -- windows and icons
}

function M.setup()
	local cmp = require('cmp')
	local opts = { sources = {} }
	for _, name in ipairs(M.features) do
		require('genja.completion.' .. name)(cmp, opts)
	end
	cmp.setup(opts)
end

return M
