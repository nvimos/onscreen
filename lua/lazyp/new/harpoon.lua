-- local ok, _ = pcall( require, "harpoon")
-- if not ok then
	-- return { 'theprimeagen/harpoon', enabled = false }
-- end

local Maps = require('genja.map-plugin')

---@type LazySpec
return {
	{
		-- todo: test me 2026-10
		'theprimeagen/harpoon',
		-- enabled = false, --  meh... https://www.youtube.com/watch?v=CdXH-LaX6Ms&ab_channel=Traap
		event = { 'UIEnter' }, -- 
		config = function(_, opts)

			local ok, _ = pcall( require, "harpoon")
			if not ok then
				return
			end

			Maps:mappings(opts)
		end
	},
}
