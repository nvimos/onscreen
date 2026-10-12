---@type LazySpec
return {
	-- not used: 2026-10
	{ 'beauwilliams/statusline.lua',
		lazy = false,
		config = function()
			local statusline = require('statusline')
			statusline.lsp_diagnostics = false
			statusline.ale_diagnostics = true
			vim.o.laststatus=3
		end,
		dependencies = {
			"kosayoda/nvim-lightbulb",
			"nathunsmitty/nvim-ale-diagnostic", -- archived: 2021-11
		},
		enabled = false --[[ laughably bad code.
		implemented through autocommands on buffer enter and leave
		-- ruler is nice except for wobbly column count ( L 12/22 c)
		-- small mode-indicator is pretty cool, changing colors gets old fast, though
		-- implements git-branch in lua, though using sync io, uses fs-watcher


		]]
		},


	-- [[ statusline ]]
	-- not used: 2026-10
	{ 'ojroques/nvim-hardline', }
	-- 'vim-airline/vim-airline'
}
