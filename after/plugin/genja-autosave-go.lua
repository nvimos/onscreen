--[[
	insert at beginning
	vim.api.nvim_buf_set_lines(bufnr, 0, 0, false, {})

	replace whole buffer
	vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, {})

	append to buffer
	vim.api.nvim_buf_set_lines(bufnr, -1, -1, false, {})

	Part 3:
	https://www.youtube.com/watch?v=cf72gMBrsI0&ab_channel=TJDeVries
]]


local append_on_buf_write_post = function(bufnr, argv, pattern)
	bufnr = bufnr or 181
	if argv == '' or argv == nil then
		argv =  {'go', 'test', '.'}
	end
	if pattern == '' or pattern == nil then
		pattern = '*'
	end
	local function setl_00(_, data)
		if data then vim.api.nvim_buf_set_lines(bufnr, 0, 0, false, data) end
	end
	local function setl_0e(_, data)
		if data then vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, data) end
	end

	vim.api.nvim_create_autocmd('BufWritePost', {
		group = vim.api.nvim_create_augroup('GenjaAutorun', { clear = true }),
		pattern = pattern,
		callback = function()
			vim.fn.jobstart(argv, { stdout_buffered = true,
			                              on_stdout = setl_00,
									      on_stderr = setl_00, })
		end
	})
end

vim.api.nvim_create_user_command(
	'RunitAsk',
	function()
		local myBuf = vim.fn.input "Bufnr: "
		local myComm = vim.fn.input "Command: "
		local myPattern = vim.fn.input "Pattern: "
		if myBuf and myComm and myPattern then
			append_on_buf_write_post(tonumber(myBuf), vim.split(myComm, " "), myPattern)
		end
	end,
	{})

vim.api.nvim_create_user_command(
	'RunitGoTestOnSave1',
	function()
		vim.cmd[[vsplit|enew]]
		local newbuf = vim.api.nvim_get_current_buf()
		vim.cmd[[:wincmd w]]
		return
		append_on_buf_write_post(
			newbuf,
			vim.split('go test ./...', " "))
	end,
	{})
