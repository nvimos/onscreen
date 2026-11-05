# PHP debugging: configure and test the UI

Status: prepared 2026-11-05, not started. Part of v2026 (release checklist).
Leaning: keep the existing plugins (nvim-dap + nvim-dap-ui); compare one lighter UI before deciding.

## What exists

- lua/lazyp/debug/dap-php.lua: nvim-dap, loads on `ft = php` or a key. Adapter: Mason's
  php-debug-adapter (installed), run as `node phpDebug.js` (node 20 on Windows); one
  configuration "Listen for Xdebug" on port 9003, no pathMappings. Only when PHP is enabled in genja.
- lua/lazyp/debug/dap.lua: nvim-dap-ui with nvim-nio; `dapui.setup()` in dap-php.lua; no auto open/close.
- nvim-dap-virtual-text: installed as a go.nvim dependency, not set up for PHP.
- Keys (lua/genja/map-plugin/dap-php.lua): `<leader>db` breakpoint, `<leader>dc` start/continue,
  `<leader>do` over, `<leader>di` into, `<leader>dx` stop, `<leader>du` UI. which-key group `<leader>d` Debug.
  Not in readme.cheatsheet.md yet.
- The header comment assumes PHP on Windows (Local by Flywheel), paths equal, no mappings.

## Gaps (from reading the code, not tested)

1. PHP runs in DDEV inside WSL (`weasel-ddev`, the phpactor distro): Xdebug in the web container
   connects out to the IDE on 9003. The adapter listens on Windows; whether DDEV's container
   reaches it (mirrored networking, `host.docker.internal`, DDEV's `xdebug_ide_location`) is unknown.
2. pathMappings: container `/var/www/html` <-> the project as nvim sees it
   (`//wsl.localhost/weasel-ddev/home/...` or `/home/...`). Breakpoints only hit when they match.
   Same translation problem phpactor solved (lang/php.lua); maybe the adapter runs inside WSL instead.
3. No "run this script" (CLI) configuration, only listen for web requests.
4. Missing keys: step out, run to cursor, conditional/log breakpoint, hover/eval, clear breakpoints.
5. UI: dap-ui opens several splits at once (IDE-like); open/close by hand only.
6. Breakpoint signs and colours: defaults.

## UI candidates (compare in the session)

1. nvim-dap-ui (installed): scopes, breakpoints, stacks, watches, repl, console as splits; layouts configurable.
2. nvim-dap-view (igorlfs/nvim-dap-view): one window with tabs; lighter, closer to the "plain" goal.
3. Only nvim-dap's widgets: `require('dap.ui.widgets')` hover/scopes floats on demand, plus the REPL.
4. vdebug (Vim, talks DBGp to Xdebug, no adapter): fallback if the DAP path fails in WSL.

## Test session (one step per question)

Before: a DDEV project in weasel-ddev with `ddev xdebug on`; PHP enabled in genja.

1. Open a PHP file of the project, `<leader>db` on a line: breakpoint sign shows.
2. `<leader>dc`: "Listen for Xdebug" starts, no error.
3. Load the page in the browser: does nvim stop at the breakpoint? (networking, gap 1)
4. If it connects but doesn't stop: path mappings (gap 2).
5. Stopped: `<leader>du`: dap-ui layout readable? Which panes are useful, which noise?
6. Step over / into, look at variables: scopes pane vs hover.
7. Same with nvim-dap-view; compare.
8. `<leader>dx`: session ends, UI closes, layout back as before.

## Questions for the user (ask in the session)

1. Which project to test with (DDEV, framework)?
2. Web requests only, or also CLI scripts and PHPUnit/Pest tests under the debugger (neotest has dap support)?
3. UI: open automatically when a session starts and close when it ends, or only by key?
4. Which panes matter: variables, watches, call stack, breakpoints list, REPL, console output?
5. Should the debug layout live in its own tab (fits the tab workflow), or as splits in the current one?
6. Zen idea (todo-ideas.md "zen modes"): is the debug layout that "digging" mode?
