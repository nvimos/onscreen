# map-plugin: miss log and :checkhealth

`lua/genja/map-plugin/init.lua` no longer pops a WARN when `Maps:keys()` or
`Maps:mappings()` finds nothing. Instead, once per kind + name per session:

- the miss goes into the module's list (`require('genja.map-plugin'):status()`);
- one line is appended to `stdpath('log')/genja-map-plugin.log`
  (here `nvim-data/logs/`): `2026-10-24 00:19:04 no keys for 'aerial' (lua/lazyp/ui/aerial.lua)`.
  The file is the caller's, relative to the config dir.

`:checkhealth genja.map-plugin` (`lua/genja/map-plugin/health.lua`, runtime only, doesn't read the log):

- misses this session, each with the calling file (warn);
- registered keys no spec asked for: spec disabled or renamed (warn);
- registered mappings not run yet: the plugin hasn't loaded, or its spec is off (info).

`init.lua` skips `health.lua` when it loads the definition files.

## Test

1. `:checkhealth genja.map-plugin` after a normal start: no misses; `genja-splitpad` under
   "keys no spec asked for" (its spec is in `lua/lazyp/no/`); copilot, gitsigns, harpoon,
   mini-git, nvim-emmet under "not used yet".
2. Open a file in a git repo (gitsigns loads), rerun: gitsigns is gone from "not used yet".
3. Rename `lua/genja/map-plugin/zenmode.lua` to `zenmode.lua.off`, restart, rerun:
   "no keys for 'zenmode', called from lua/lazyp/ui/zenmode.lua". No popup at startup.
   `:e ~/AppData/Local/nvim-data/logs/genja-map-plugin.log` has the same line. Rename it back.

Unit tests: `make test` in `lua/genja/map-plugin/` (`tests/map-plugin/test_health.lua`): clean load gives no notification and no miss; only genja-splitpad has keys without an active spec; keys/mappings leave the "unasked" lists once used; zenmode spec without its entry gets nil keys, one miss naming `lua/lazyp/ui/zenmode.lua`, a health warn, one log line (also when asked twice), no notification. The `:checkhealth` buffer itself is not captured (vim.health is stubbed).
