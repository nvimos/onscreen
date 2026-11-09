-- lua/genja/ext/md-links.lua: bare URLs to inline links.

local eq = MiniTest.expect.equality
local L = require('genja.ext.md-links')

local T = MiniTest.new_set()

T['name: path without query, host when no path'] = function()
	eq(L.name('https://github.com/tox2ik/genja-util.nvim?tab=readme#top'), 'tox2ik/genja-util.nvim')
	eq(L.name('https://example.org/'), 'example.org')
	eq(L.name('http://example.org'), 'example.org')
end

T['name: a path over 60 chars keeps its last part'] = function()
	local url = 'https://example.org/' .. string.rep('a', 50) .. '/' .. string.rep('b', 20) .. '/page.html'
	eq(L.name(url), 'page.html')
end

T['name: percent escapes decoded'] = function()
	eq(L.name('https://example.org/a%20b'), 'a b')
end

T['link_line: bare URL, trailing period kept outside'] = function()
	eq(L.link_line('see https://x.org/docs/intro.'), 'see [docs/intro](https://x.org/docs/intro).')
end

T['link_line: links, autolinks and code stay'] = function()
	eq(L.link_line('[a](https://x.org/a)'), '[a](https://x.org/a)')
	eq(L.link_line('<https://x.org/a>'), '<https://x.org/a>')
	eq(L.link_line('`https://x.org/a` and https://x.org/b'), '`https://x.org/a` and [b](https://x.org/b)')
end

return T
