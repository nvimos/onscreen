-- Diagnostic virtual text in one column per paragraph (lua/genja/ext/diag-align.lua).
-- Loads before plugin/diag-limit.lua, so the limit wrapper sits outside this one.
require('genja.ext.diag-align').setup()
