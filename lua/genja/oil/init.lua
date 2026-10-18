-- oil helpers, one table: require('genja.oil').git_add etc.
-- entry.lua    entries under cursor / visual lines, cd to entry
-- sort.lua     sort modes, per-dir default (BufEnter)
-- open.lua     explorer, shell, browser, vlc, rar, custom <CR>
-- undersort.lua  move entries to _category dirs
-- preview.lua  preview sized to the listing
-- diff.lua     git diff preview
-- git.lua      git add / unstage
-- commit.lua   git commit popup
-- buffers.lua  E211 workaround: drop buffers of deleted files
-- globals.lua  global helpers from elsewhere, as a module

local M = {}

local parts = { 'entry', 'sort', 'open', 'undersort', 'preview', 'diff', 'git', 'commit', 'buffers' }
for _, part in ipairs(parts) do
	for name, value in pairs(require('genja.oil.' .. part)) do
		if type(value) == 'function' then
			M[name] = value
		end
	end
end

return M
