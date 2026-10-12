vim.env['HOME'] = (vim.env.HOME or vim.env.Userprofile)


if vim.fn.has('windows') == 1 then
	vim.env.GIT_SSH_COMMAND = 'C:/Windows/System32/OpenSSH/ssh.exe'

	if not string.find(vim.env.PATH, 'a:\\bin', 1, true) then
		vim.env.PATH = 'a:\\bin;' .. vim.env.PATH
	end
else
	-- vim.env.SSH_AUTH_SOCK = vim.fn.expand("~/.ssh/agent.sock")
end
