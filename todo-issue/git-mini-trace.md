
## :cli history

guessing:

while browsing :cli up and down
previous git command tried to resolve something

## trace

```
E42: No Errors
vim.schedule callback: Vim:E5108: Lua function: ...o/AppData/Local/nvim-data/lazy/mini-git/lua/mini/git.lua:1181: attempt to index a nil value
stack traceback:
	...o/AppData/Local/nvim-data/lazy/mini-git/lua/mini/git.lua:1181: in function 'git_cli_output'
	...o/AppData/Local/nvim-data/lazy/mini-git/lua/mini/git.lua:731: in function 'ensure_git_subcommands'
	...o/AppData/Local/nvim-data/lazy/mini-git/lua/mini/git.lua:904: in function 'command_get_complete_candidates'
	...o/AppData/Local/nvim-data/lazy/mini-git/lua/mini/git.lua:887: in function <...o/AppData/Local/nvim-data/lazy/mini-git/lua/mini/git.lua:884>
	[C]: in function 'getcompletion'
	...ocal/nvim-data/lazy/cmp-cmdline/lua/cmp_cmdline/init.lua:136: in function 'exec'
	...ocal/nvim-data/lazy/cmp-cmdline/lua/cmp_cmdline/init.lua:202: in function 'complete'
	...AppData/Local/nvim-data/lazy/nvim-cmp/lua/cmp/source.lua:342: in function 'complete'
	...o/AppData/Local/nvim-data/lazy/nvim-cmp/lua/cmp/core.lua:308: in function 'complete'
	...o/AppData/Local/nvim-data/lazy/nvim-cmp/lua/cmp/core.lua:178: in function 'autoindent'
	...o/AppData/Local/nvim-data/lazy/nvim-cmp/lua/cmp/core.lua:170: in function 'on_change'
	...o/AppData/Local/nvim-data/lazy/nvim-cmp/lua/cmp/init.lua:372: in function 'callback'
	...ta/Local/nvim-data/lazy/nvim-cmp/lua/cmp/utils/async.lua:165: in function <...ta/Local/nvim-data/lazy/nvim-cmp/lua/cmp/utils/async.lua:163>
stack traceback:
	[C]: in function 'getcompletion'
	...ocal/nvim-data/lazy/cmp-cmdline/lua/cmp_cmdline/init.lua:136: in function 'exec'
	...ocal/nvim-data/lazy/cmp-cmdline/lua/cmp_cmdline/init.lua:202: in function 'complete'
	...AppData/Local/nvim-data/lazy/nvim-cmp/lua/cmp/source.lua:342: in function 'complete'
	...o/AppData/Local/nvim-data/lazy/nvim-cmp/lua/cmp/core.lua:308: in function 'complete'
	...o/AppData/Local/nvim-data/lazy/nvim-cmp/lua/cmp/core.lua:178: in function 'autoindent'
	...o/AppData/Local/nvim-data/lazy/nvim-cmp/lua/cmp/core.lua:170: in function 'on_change'
	...o/AppData/Local/nvim-data/lazy/nvim-cmp/lua/cmp/init.lua:372: in function 'callback'
	...ta/Local/nvim-data/lazy/nvim-cmp/lua/cmp/utils/async.lua:165: in function <...ta/Local/nvim-data/lazy/nvim-cmp/lua/cmp/utils/async.lua:163>
Type  :qa  and press <Enter> to exit Nvim
```
