vim.env['HOME'] = (vim.env.HOME or vim.env.Userprofile or vim.uv.os_homedir())


if vim.fn.has('win32') == 1 then
	vim.env.GIT_SSH_COMMAND = 'C:/Windows/System32/OpenSSH/ssh.exe'
	function add_win_path(e)
		if not string.find(vim.env.PATH, e, 1, true) then
			vim.env.PATH = e .. ';' .. vim.env.PATH
		end
	end
	add_win_path [[a:\bin]]
	add_win_path (vim.env.home .. [[\.local\bin]])

else
	-- vim.env.SSH_AUTH_SOCK = vim.fn.expand("~/.ssh/agent.sock")
end
