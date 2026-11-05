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
    - result 2026-11-05: passes; default sign `B` (class.login.php). Gap 6: nicer sign later.
2. `<leader>dc`: "Listen for Xdebug" starts, no error.
    - result 2026-11-05: starts; first run asks Windows Firewall to allow node. node listens on
      0.0.0.0:9003 and [::]:9003. Gap: no feedback in nvim that it started; add a notify or a
      statusline item (`require('dap').status()`).
3. Load the page in the browser: does nvim stop at the breakpoint? (networking, gap 1)
    - result 2026-11-05: no, page loads normally. Xdebug log: "Could not connect to debugging client.
      Tried: host.docker.internal:9003". Cause: WSL networkingMode=mirrored; `host.docker.internal`
      doesn't resolve in the DDEV web container (`xdebug_ide_location: ""`, DDEV v1.25.4).
    - checks: WSL -> 127.0.0.1:9003 OK; container -> docker gateway 172.19.0.1:9003 refused;
      container -> Windows Wi-Fi IP 192.168.1.236:9003 OK (`.wslconfig` hostAddressLoopback=true).
    - quick fix to test: `ddev config global --xdebug-ide-location=192.168.1.236`, `ddev restart`.
      The IP changes with the network: a lasting fix must find it at start (DDEV hook, or run the
      adapter inside WSL with xdebug_ide_location=wsl2; see gap 2).
    - note: `ddev restart` turns Xdebug off again (project `xdebug_enabled: false`); `ddev xdebug on` after.
    - result 2026-11-05 retry: stops in class.login.php, but the stop line is 2 below the `B` sign.
      Guess: Xdebug moves a breakpoint on a non-executable line to the next executable one.
    - user: the `B` line was blank; works well enough. Passes with the IP workaround.
    - later: `<leader>db` on a blank line could move the sign to the next code line.
4. If it connects but doesn't stop: path mappings (gap 2).
    - result 2026-11-05: skipped, it stopped in the right file without pathMappings. (why it matches
      //wsl.localhost/... to /var/www/html not checked)
5. Stopped: `<leader>du`: dap-ui layout readable? Which panes are useful, which noise?
    - result 2026-11-05: UI fine for now, works; refine later (stack, breakpoints matter: answer 4).
6. Step over / into, look at variables: scopes pane vs hover.
    - result 2026-11-05: stepping tried from the UI, works; keys not tested (expected fine).
      Added `<leader>dK` hover (dap.ui.widgets.hover, K like LSP hover); cheatsheet "Debug" section. Not tested.
7. Same with nvim-dap-view; compare.
    - 2026-11-05: added lua/lazyp/new/dap-view.lua (igorlfs/nvim-dap-view, needs nvim 0.11+), opens on
      Threads (stack); sections threads, breakpoints, scopes, watches, repl. Key `<leader>dv`.
    - result 2026-11-05: both fine, needs getting used to; keep both.
8. `<leader>dx`: session ends, UI closes, layout back as before.
    - result 2026-11-05: session ends, splits stay open; user wants them closed.
      Fixed: dap listeners event_terminated/event_exited close dap-ui and dap-view
      (lua/lazyp/debug/dap-php.lua). Not tested.

## Questions for the user (ask in the session)

1. Which project to test with (DDEV, framework)?
    - answer 2026-11-05: norway4u, `~/code/norway4u` in weasel-ddev. DDEV type php, PHP 8.4,
      apache-fpm, docroot `htdocs`; custom app (Symfony components, Behat `features/`, `tests/`).
      `xdebug_enabled: false`: run `ddev start` and `ddev xdebug on` first.
2. Web requests only, or also CLI scripts and PHPUnit/Pest tests under the debugger (neotest has dap support)?
    - answer 2026-11-05: both. Web requests always handled. CLI scripts and Behat/PHPUnit runs are
      not on by default; switched on only when needed.
3. UI: open automatically when a session starts and close when it ends, or only by key?
    - answer 2026-11-05: open automatically when a request comes in (stopped/attached), by default;
      `<leader>du` still toggles. Make auto-open a setting, so it can be switched later.
    - note: request stalls come from Xdebug `start_with_request` (yes vs trigger), not from the UI;
      only a request at a breakpoint waits.
4. Which panes matter: variables, watches, call stack, breakpoints list, REPL, console output?
    - answer 2026-11-05: call stack and breakpoints list. (variables, watches, REPL, console not named)
5. Should the debug layout live in its own tab (fits the tab workflow), or as splits in the current one?
    - answer 2026-11-05: own tab by default; a config switch to use splits in the current tab instead.
    - Hint: dap-ui has no tab option; open a tab with the stopped file, then `dapui.open()` there;
      close the tab on terminate. Switch next to the auto-open one (answer 3).
6. Zen idea (todo-ideas.md "zen modes"): is the debug layout that "digging" mode?
    - answer 2026-11-05: three levels, each heavier than the last.
      - z1: reading and writing prose, mostly; usable for anything.
      - z2: some UI: diagnostics with the limit (as before), the max-width line (colorcolumn).
      - z3: UI heavy, with the debug layout on, as splits inside the z3 view (not a separate tab).
        So the tab default (answer 5) is for a debug session outside z3; z3 always uses splits.
    - copied to todo-ideas.md "zen modes".

## Implemented 2026-11-05 (after the session, not tested)

- `!` during a session flips F1-F8 (lua/genja/ext/debug-fkeys.lua): F1 continue, F2 step over,
  F3 step into, F4 step out, F5 run to cursor, F6 breakpoint, F7 hover, F8 stop. Armed at
  `<leader>dc` and on the session's initialized event; `!` (map-zero repeat-with-bang) and the
  F-keys' own maps come back at session end. User wants to adjust the F-key list.
- Auto-open on the first stop, own tab by default (lua/genja/ext/debug-ui.lua):
  `g:genja_debug_auto_open`, `g:genja_debug_layout` ('tab' or 'split'). Session end closes dap-ui,
  dap-view and the tab.
- DDEV IP: `<leader>dc` warns when xdebug_ide_location isn't the Windows LAN IP;
  `:DdevXdebugHost` sets it, restarts the project, turns Xdebug on (lua/genja/ext/debug-ddev.lua).
- Notify when the session starts (port). Signs: ● breakpoint, ◆ condition, ◇ log point,
  ○ rejected, ▶ stopped (CursorLine).
- Not done: z3 (zen with the debug splits; zenmode.lua has z1/z2 only); conditional/log
  breakpoint keys; CLI and Behat configurations (answer 2).

### Test (one per question)

1. `<leader>dc` in norway4u: notify names port 9003; no DDEV warning (IP unchanged).
2. Load the page: a new tab opens with dap-ui, stopped line marked ▶.
3. `!`: notify lists the F-keys; F2 steps over, F7 hovers.
4. `!` again: F1 opens the genja-finder grep again.
5. `<leader>dx`: the debug tab closes, `!` repeats the last command again.
6. `:let g:genja_debug_layout = 'split'`, repeat 1-2: dap-ui opens in the current tab.
7. Change xdebug_ide_location by hand, `<leader>dc`: warning; `:DdevXdebugHost`: restarts, fixed.

### Observed 2026-11-05 (user, first use)

- Works, needs getting used to; not perfect.
- Added `<leader>dl`: breakpoints in quickfix, with the adapter's message for rejected ones.
- Open: some breakpoints show the hollow ○ (rejected) next to the ● ones. Guess: set before a
  request connected, or on a line without code. If it's the first, drop ○ while only listening.
- Open: continue runs the request to the end and skips the other breakpoints. Not diagnosed;
  next time check `<leader>dl` (● or ○, message) and whether they are in another file (path mapping).

### Added 2026-11-05 (later, not tested)

- `<leader>dB` conditional breakpoint, `<leader>dp` log point.
- `:DebugCli <cmd>` (ddev exec under the debugger, terminal split), `:DebugBehat [args]`
  (profile ddev; args, else the current .feature). They run the WSL copy: `make ddev-sync` first.
- norway4u's git working copy is on Windows (`C:/Users/jazzo/Local Sites/norway4u`), rsynced into
  WSL by `make ddev-sync`. debug-ddev.lua now handles both copies (distro from phpactor_wsl).
- Hollow ○ left as is until `<leader>dl` shows why. z3 questions parked in todo-ideas.md "zen modes".
