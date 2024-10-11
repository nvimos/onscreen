vim.filetype.add({
	extension = {
		yml = 'yaml.ansible',
		-- bar = function(path, bufnr)
		-- 	if true then
		-- 		return 'barscript', function(bufnr)
		-- 			-- Set a buffer variable
		-- 			vim.b[bufnr].barscript_version = 2
		-- 		end
		-- 	end
		-- 	return 'bar'
		-- end,
	}
})
