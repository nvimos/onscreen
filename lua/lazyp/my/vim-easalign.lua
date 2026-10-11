return {{
	'junegunn/vim-easy-align',
	lazy = true,
	cmd = 'EasyAlign',
	keys = {
		-- Start interactive EasyAlign in visual mode (e.g. vipga)          -- nmap ga <Plug>(EasyAlign)
		-- Start interactive EasyAlign for a motion/text object (e.g. gaip) -- xmap ga <Plug>(EasyAlign)
		{ 'ga', '<plug>(EasyAlign)', mode = { 'n', 'x', }, desc = 'EasyAlign', noremap = true, silent = true }
	},
	-- config = function () end
}}
