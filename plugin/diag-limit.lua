-- Diagnostics limit on from the start: the first 3 per severity and buffer are drawn
-- (lua/genja/ext/diag-limit.lua). Keys: lua/genja/map-lsp.lua.
-- Loads after plugin/diag-align.lua, so the limit wrapper sits outside that one.
require('genja.ext.diag-limit').setup()
