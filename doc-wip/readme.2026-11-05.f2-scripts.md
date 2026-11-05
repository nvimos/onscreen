# composer and npm scripts as tasks (2026-11-05)

auto-todo N. Code: `lua/genja/f2/collect/scripts.lua`, registered in `lua/genja/f2/init.lua` (group `script`).

## What it does

- `<F2>` shows `composer scripts in <dir> (N)` and `<runner> scripts in <dir> (N)` when a
  `composer.json` / `package.json` with `scripts` is found above the buffer's dir (oil: its dir).
- Picking one opens a sub-picker of the scripts; `<Tab>` marks several; each runs as an overseer task:
  `composer run-script <name>`, `<runner> run <name>`. Runner from the lockfile: bun (`bun.lock`,
  `bun.lockb`), pnpm, yarn, else npm.
- `:OverseerRun` lists the same scripts through overseer's own npm and composer templates (built in,
  on by default in overseer v2).
- Scripts run on the host; in a DDEV project `composer` may need `ddev composer` instead (not done).

## Test

1. Open a file in a project with a `composer.json` that has `scripts`; `<F2>`: a `script` row.
2. Pick it, pick a script: an overseer task runs it (`<leader>` overseer toggle or `:OverseerToggle`).
3. A JS project with `package.json` and `bun.lockb`: the row says `bun scripts in ...`.
4. `:OverseerRun`: the npm/composer scripts are listed there too.
