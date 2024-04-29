require 'genja.winbar' -- Winbar

function is_started_from_windows_shell()
	return [[nvim.exe]] == vim.fn.readdir( '.', [[v:val =~ 'nvim.exe$']])
	                [1]
end


local user_comm = vim.api.nvim_create_user_command

function Cd(to) vim.api.nvim_call_function("chdir", { to }); vim.cmd[[pwd]] end

user_comm( 'CDconfig', function() Cd(vim.fn.stdpath('config')) end,                { desc = "cd stdpath(config)" , bar = true })
user_comm( 'CDconfigg', function() Cd(vim.fn.stdpath('config')..'/lua/genja') end, { desc = "cd ()/lua/genja" , bar = true })
user_comm( 'CD',       function(c) Cd(c.fargs) end,                                { nargs = '*', desc = "cd ?" , bar = true })

user_comm( 'Nospell',  function(c) vim.o.spell = not vim.o.spell end,              { desc = "toggle spelling" , bar = true })


-- user_comm( 'Winbar',       function(c) return "zxc" end,                                { nargs = '*', desc = "cd ?" , bar = true })






-- complete = function() return {'a', 'x', 'c'} end
user_comm( 'Woot', function(c) print(vim.inspect(c)) end, { nargs = '?', force = true, desc = "What is a function?"  })
user_comm( 'Woot', function(c) print(vim.inspect(c)) end, { nargs = '*', force = true, desc = "What is a function?", bar = true  })

function Close_nerdtree_wins() -- <F3> or <space> ee | e. | et
	for _, win in ipairs(vim.api.nvim_list_wins()) do
		local buf = vim.api.nvim_win_get_buf(win)
		local ft = vim.api.nvim_buf_get_option(buf, 'filetype')
		if ft == 'nerdtree' then
			vim.api.nvim_win_close(win, true)
		end
	end
end

-- -- Define a Lua function that takes arguments
-- local function my_function(arg1, arg2)
--     print("Argument 1:", arg1)
--     print("Argument 2:", arg2)
-- end
-- -- Create a custom command that calls the Lua function
-- vim.api.nvim_command("command! -nargs=+ MyFunction lua my_function(<f-args>)")


