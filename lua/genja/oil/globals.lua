-- Global helpers the oil modules use, gathered as one module.
-- All are defined elsewhere as globals; listed here to untangle them later.

local fn = require('genja.fn') -- also defines these as globals

local M = {}

M.IsDir              = fn.IsDir
M.Dirname            = fn.Dirname
M.Extensionname      = fn.Extensionname
M.IsVideoExtension   = fn.IsVideoExtension
M.IsPictureExtension = fn.IsPictureExtension
M.Join               = fn.Join
M.JoinPaths          = fn.JoinPaths

-- global from lua/genja/fu.lua, which returns no module; looked up at call time
M.StripSceneTags = function(name)
	return StripSceneTags(name)
end

return M
