# overseer.nvim, terse

Task runner: starts commands (make targets, npm scripts, own templates) as
tasks, keeps their output, shows status, restarts them. Spec:
`lua/lazyp/maybe/overseer.lua`, loads on the `:Overseer*` commands or a
`require('overseer')` (e.g. from `<F2>`).

## In this config

- `<F2>`, `make: targets (N)`: sub-picker of the Makefile targets above the buffer (oil: oil's dir), with
  a prefix for included files (`lazy: sync`). `<CR>` runs it as an overseer
  task and opens the task list. Code: `lua/genja/f2/` (make.lua, run.lua).
- Own templates: `lua/overseer/template/user/` (php_test_all, php_test_file,
  run_script). Every file there is a template; `php_test.lua` is a helper and
  disabled in the spec.

## Commands

    :OverseerRun [name]      pick a template and run it (make, npm, cargo, just,
                             .vscode/tasks.json, own templates); with a name, run
                             that one directly: :OverseerRun make\ sync
    :OverseerShell [cmd]     run any shell command as a task (! = create, don't start)
    :OverseerToggle          task list on/off (bottom); ! = don't jump into it
    :OverseerOpen / Close    same, explicitly
    :OverseerTaskAction      pick a task, then an action for it

## Task list keys

    <CR>    action menu for the task under the cursor
    o       open output          <C-f>  output in a float
    <C-v>   output in vsplit     <C-s>  split       <C-t>  tab
    p       toggle output preview
    { }     previous / next task
    <C-k> <C-j>  scroll the output
    dd      dispose (remove) the task
    <C-e>   edit the task (cmd, cwd, env) before rerunning
    q       close the list       ?  all keys

## Most used actions (<CR> in the list, or :OverseerTaskAction)

- restart: rerun with the same command, output buffer reused.
- watch: restart whenever a file is saved (the `restart_on_save` component).
- open float / vsplit / tab: read the output.
- open output in quickfix / set quickfix diagnostics: jump through errors.
- stop, dispose.

## From Lua

```lua
local overseer = require('overseer')
overseer.run_task({ name = 'make sync' })          -- a template by name
local task = overseer.new_task({ cmd = { 'make', 'log' }, cwd = vim.fn.getcwd() })
task:start()                                       -- an ad-hoc command
overseer.open({ enter = false })                   -- show the list, stay in the buffer
```

Errors into the quickfix list: add the component
`{ 'on_output_quickfix', open = true }` to the task's `components`
(keep `'default'` in the list too).

## Own template, minimal

`lua/overseer/template/user/<name>.lua`:

```lua
return {
	name = 'php lint file',
	builder = function()
		return { cmd = { 'php', '-l', vim.fn.expand('%:p') } }
	end,
	condition = { filetype = { 'php' } },
}
```

More: `:help overseer`, the plugin's `doc/` (tutorials, guides).
