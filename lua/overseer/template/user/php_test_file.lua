-- lua/overseer/template/user/php_test_file.lua
return require('overseer.template.user.php_test').template('php: test this file', function()
	return { vim.fn.expand('%:p') }
end)
