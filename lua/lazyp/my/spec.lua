-- https://github.com/LunarVim/Neovim-from-scratch/blob/master/lua/user/plugins.lua

-- pcall(require, 'genja.plugins-dashboard')
-- pcall(require, 'genja.plugins-lsp')
return {

	-- { 'folke/neoconf.nvim', cmd = "Neoconf" },
	-- { "folke/neodev.nvim", opts = { } },


	--{
	--	'Wansmer/treesj',
	--	keys = { '<leader>m', '<leader>j', '<space>s' },

	--	dependencies = { 'nvim-treesitter/nvim-treesitter' },
	--	config = function()
	--		require('treesj').setup({--[[ your config ]]})
	--	end,
	--	-- keys = {
	--	--     { "J", "<cmd>TSJToggle<cr>", desc = "Join Toggle" },
	--	-- },
	--	-- opts = { use_default_keymaps = false, max_join_length = 150 },
	--},


}

--vim.list_extend(P or {}, plugs)
--return P
