# TypeScript projects out of the box (2026-11-10)

What: a project that is only TypeScript gets what a PHP project gets: language servers per framework,
lint, tests and a debugger, starting only where the project calls for them.

Turn on (per machine, `lua/genja/lsp/local.lua` or for the session): `:EnableLang typescript`, then the
frameworks in use: `:EnableLang vue`, `angular`, `svelte`, `astro` (`-save` keeps it).

| Part       | What                                                       | Where |
|------------|------------------------------------------------------------|-------|
| TS / JS    | tsc (TypeScript 7 native server), eslint with a project config | plug-wip/genja-completion011.nvim lang/typescript.lua |
| Vue        | vue_ls for template and style, vtsls + @vue/typescript-plugin for `<script>` in .vue | lang/vue.lua |
| Angular    | angularls, projects with angular.json, the project's @angular/language-service | lang/angular.lua |
| Svelte     | svelte-language-server                                      | lang/svelte.lua |
| Astro      | astro-language-server, projects with astro.config.*        | lang/astro.lua |
| Parsers    | typescript, javascript, tsx, jsdoc, vue, svelte, astro, angular | lua/lazyp/my/load-treesitter.lua |
| Lint       | eslint in js, ts, jsx, tsx, vue, svelte, astro (needs an eslint config) | lua/genja/ext/lint.lua |
| Tests      | neotest-vitest or neotest-jest, by config file              | lua/lazyp/langs/php-neotest.lua |
| Scripts    | package.json scripts in `<F2>` (bun, pnpm, yarn, npm by lockfile) | lua/genja/f2/collect/scripts.lua |
| Debug      | js-debug-adapter: Node launch file, npm run dev, attach; Chrome on the dev server | lua/genja/ext/debug-js.lua |

Debugging uses the same keys as PHP (`<leader>dc` and the F keys, lua/genja/map-plugin/dap-php.lua).

## Test

1. A Vite + React app: `:EnableLang typescript`, open `src/App.tsx`: `:checkhealth vim.lsp` lists tsc (and eslint with a config).
2. A Vue app (`npm create vue@latest`): `:EnableLang vue`, open a `.vue` file: vue_ls and vtsls attach; `K` on a ref in `<script setup>`.
3. An Angular app (`ng new`): `:EnableLang angular`, a component template: completion of component inputs.
4. A SvelteKit app and an Astro site: `:EnableLang svelte` / `astro`, open a component.
5. `<leader>dc` in a .ts file: pick `Node: launch this file`, a breakpoint stops.
6. `<leader>dc`, `Chrome: localhost (dev server)` with `npm run dev` running: a breakpoint in a component stops.
