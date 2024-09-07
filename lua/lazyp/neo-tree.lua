return {
	{
		'nvim-neo-tree/neo-tree.nvim',
		enabled = true,
		branch = 'v3.x',
		dependencies = {
			'nvim-lua/plenary.nvim',
			'nvim-lua/plenary.nvim',
			'nvim-tree/nvim-web-devicons',
			'MunifTanjim/nui.nvim',
			'3rd/image.nvim',
		},
		cmd = 'Neotree',
		keys = {
			{ '<leader>fw', '<cmd>Neotree toggle<cr>', { noremap = true, silent = true, desc = "NeoTree" } }
		-- vim.keymap.set('n', "<leader>ft", "<cmd>Neotree toggle<cr>", { desc = "NeoTree" })
		-- vim.keymap.set('n', "<leader>fw", "<cmd>Neotree toggle<cr>", { desc = "NeoTree" })
		},
		config = function()
			require('neo-tree').setup()
		end,
	},
}
