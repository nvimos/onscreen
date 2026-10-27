# Replacing nvim-cmp with blink.cmp in genja-completion011

Done 2026-10-27 (tag before-blink-2026-w44 is the state before). Checked against cmp.saghen.dev (blink.cmp v1.10.2).

## Upstream facts that matter here

- Install: `saghen/blink.cmp`, `version = '1.*'`: lazy checks out a release tag and blink downloads its prebuilt Rust fuzzy matcher (needs curl and git).
- Windows x86_64 has a prebuilt binary (`libblink_cmp_fuzzy.dll` in `nvim-data/lazy/blink.cmp/target/release/`).
- `fuzzy.implementation = 'prefer_rust_with_warning'` falls back to the Lua matcher when the binary is missing; `'lua'` needs no binary at all.
- Neovim 0.11: blink adds its LSP capabilities itself; `require('blink.cmp').get_lsp_capabilities()` is only needed to merge your own.
- Off per buffer: `vim.b.completion = false` (the default `enabled` also skips `buftype=prompt`).
- Per filetype: `sources.per_filetype = { lua = { inherit_defaults = true, 'lazydev' } }`.
- Providers: `score_offset`, `min_keyword_length`, `max_items`, `fallbacks` (used when a provider returns nothing), `enabled` (may be a function).
- Defaults: path `score_offset = 3`; buffer `-3`; `lsp` and `path` fall back to `buffer`.
- Custom source: a module with `new(opts)`, optional `enabled()` and `get_trigger_characters()`, and `get_completions(ctx, callback)`.
    - `callback({ items, is_incomplete_forward, is_incomplete_backward })`.
    - blink filters by keyword itself; the source must not.
    - Kinds come from `require('blink.cmp.types').CompletionItemKind`.
    - Registered under `sources.providers.<id> = { name, module, opts }`.
- Cmdline: on by default, preset `'cmdline'`: `<Tab>`/`<S-Tab>` show and select, `<C-n>`/`<C-p>`, `<C-y>` accept, `<C-e>` cancel. Menu `auto_show` is off by default.
- Selection defaults: `preselect = true`, `auto_insert = true`; with these, `<CR>` would accept the first item without a selection.
- Snippets: preset `default` uses `vim.snippet`; friendly-snippets only if installed.

## Feature by feature (lua/genja/completion/*.lua)

| file | today (nvim-cmp) | blink.cmp | work |
|---|---|---|---|
| init.lua | features fill one `cmp.setup()` table | features fill one blink `opts` table; `require('blink.cmp').setup(opts)` | small: the loop stays, the table shape changes |
| keymaps | `<Tab>` next/snippet/complete, `<S-Tab>`, `<CR>` confirm only a selected item, `<F2>`/`<F3>`, `^K` abort, `<C-Space>` | `keymap = { preset = 'none', ['<Tab>'] = { 'select_next', 'snippet_forward', <fn: show if text before>, 'fallback' }, ... }`; `<CR>` = `{ 'accept', 'fallback' }` with `completion.list.selection.preselect = false` | medium: the has-text-before check becomes a function command |
| snippets | `vim.snippet.expand` | built in (`snippets.preset = 'default'`) | delete the file |
| lsp | `nvim_lsp`, group 1 | built-in `lsp` | delete; `lsp/init.lua` drops the `cmp_nvim_lsp` capabilities block |
| path | `path`, group 1 | built-in `path` | delete |
| buffer | `buffer`, group 2 (only when lsp/path are empty) | built-in `buffer`; the default fallbacks already do "only when empty" | delete |
| lazydev | source with `group_index = 0` | `per_filetype.lua = { inherit_defaults = true, 'lazydev' }`, provider `module = 'lazydev.integrations.blink', score_offset = 100` | small |
| gitignore, sshconfig, gitcommit, dictionary | own cmp sources (`source:complete(params, callback)`) | same logic as blink sources: `get_completions(ctx, callback)`, kinds from `blink.cmp.types`, `per_filetype` instead of `cmp.setup.filetype` | medium: four ports, mostly renames |
| cmdline | cmp-cmdline: `<Tab>`/`<S-Tab>` open and select, `<C-j>`/`<C-k>` while open, `<Down>`/`<Up>` always history; `/` `?` buffer words | built in; `cmdline.keymap` with `<C-j>` = `{ 'select_next', 'fallback' }`, `<Down>` = `{ 'cancel', 'fallback' }`; per-cmdtype sources through a `sources` function on `vim.fn.getcmdtype()` | medium: the `<Down>` close-then-history needs a check |
| appearance | winblend, winhighlight, lspkind symbols | `completion.menu.winblend`, `.winhighlight`, `.draw.columns`; blink ships its own kind icons (lspkind not needed) | small |

The dictionary source's prefix index stays as it is. blink filters by keyword itself, so `get_completions` should return all words of the two-letter bucket (or the prefix matches, to keep the list small) with `is_incomplete_forward = true`.

## Outside the plugin

- `plug-wip/genja-ask.nvim/lua/genja-ask/init.lua`: `cmp.setup.buffer({ enabled = false })` becomes `vim.b[buf].completion = false`. Both can stay during the switch.
- `lua/lazyp/langs/php-laravel.lua`: blade-nav.nvim lists `hrsh7th/nvim-cmp` as a dependency; it has its own blink source (`blade-nav.integrations.blink`), see Decisions.
- `lua/lazyp/langs-comps/copilot.lua`: comments say nvim-cmp owns `<Tab>`; copilot.vim's ghost text is independent.
- genja-commit's CLAUDE.md: "`<CR>` confirms only a selected item" holds only with `preselect = false`.
- `lua/lazyp/new/genja-comp011.lua`: dependency `hrsh7th/nvim-cmp` becomes `saghen/blink.cmp` (`version = '1.*'`). `lua/lazyp/langs-comps/nvim-cmp.lua` and the cmp-* specs get `-- not used: 2026-10`.
- `tests/comps011/test_comps011.lua` (cmp group): `cmp.complete()` / `cmp.get_entries()` / `e.source.name == 'nvim_lsp'` become `require('blink.cmp').show()` and the list module's items with `source_id == 'lsp'`. The exact accessor needs checking in blink's source before rewriting.

## Suggested order

1. Spec: add blink next to nvim-cmp, `enabled = false` on one side, switched by an option in `local.lua`, so going back is one line.
2. Port init, keymaps, appearance and the built-ins; delete snippets, lsp, path, buffer.
3. Port the four own sources; one commit each.
4. cmdline last: it differs the most from the cmp-cmdline setup.
5. Tests: the cmp group against blink; `make D=comps011 G=cmp`.
6. Remove nvim-cmp and the cmp-* plugins once a week of daily use shows no gaps.

Rough size: about 300 lines changed in `lua/genja/completion/`, plus the test helper. Nothing in the LSP half beyond the capabilities block.

## Decisions (2026-10-27)

- `<CR>`: blink's default (first item preselected, `<CR>` accepts it). Keymaps file keeps the old behaviour as a commented-out block:

  ```lua
  -- old nvim-cmp behaviour: nothing preselected, <CR> accepts only an item picked with <Tab>
  -- opts.completion = { list = { selection = { preselect = false, auto_insert = true } } }
  -- opts.keymap['<CR>'] = { 'accept', 'fallback' }
  ```
  genja-commit's CLAUDE.md bullet ("`<CR>` confirms only a selected item") changes with it.
- Fuzzy matcher: the fastest, the prebuilt Rust one: `version = '1.*'`, `fuzzy = { implementation = 'prefer_rust_with_warning' }` (warns and falls back to Lua if the dll is missing).
- blade-nav (Laravel only: `gf` on Blade directives, components, routes, views; completes `<x-` components and `route('` names): has its own blink source, no blink.compat:
  `providers['blade-nav'] = { name = 'blade-nav', module = 'blade-nav.integrations.blink' }`, listed in `per_filetype` for `blade` and `php`. Its spec drops the `hrsh7th/nvim-cmp` dependency (upstream marks it optional).
