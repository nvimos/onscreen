# JS/TS tests in neotest: vitest or jest (2026-11-10)

What: the neotest keys that run PHP and Go tests now run JS/TS tests of a React front end too.
Where: `lua/lazyp/langs/php-neotest.lua` (neotest-vitest, neotest-jest), keys as before (`lua/genja/map-plugin/php-neotest.lua`).

Which runner:

- vitest: a `vitest.config.*`, `vitest.workspace.*` or `vite.config.*` up the tree
- jest: a `jest.config.*`, or a `"jest"` key in the nearest `package.json`; never in a vitest project
- neither: the adapters skip the file

neotest loads on php, go, javascript, typescript, javascriptreact and typescriptreact buffers.

## Test

1. A Vite + React project with vitest: open `src/App.test.tsx`, run the nearest test: the vitest result shows inline.
2. A jest project (`jest.config.js`): same, jest runs it.
3. A project with both configs: the test runs once (vitest).
