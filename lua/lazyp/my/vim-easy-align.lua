local Maps = require('genja.map-plugin')

---@type LazySpec
return {{
	'junegunn/vim-easy-align',
	lazy = true,
	cmd = 'EasyAlign',
	keys = Maps:keys(),
	-- config = function () end
}}
