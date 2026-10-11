return {
		-- run tasks from makefiles?
		'stevearc/overseer.nvim',
		branch = 'nvim-0.7', -- neovim 0.11 needed for later
		opts = {},
		config = function()
				require('overseer').setup({
						templates = {
								'builtin',
								'user.run_script',
								'user.php_test_file',
								'user.php_test_all',
						},
				})
		end
}
