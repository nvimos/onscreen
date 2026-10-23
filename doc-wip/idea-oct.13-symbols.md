# Idea 13: json/yaml key path, breadcrumbs, symbol sidebars

Analysis 2026-10-18 for todo #13. Nothing installed or tested. Facts are from
each project's README/config; no Reddit thread comparing them was found, so
"what people say" is thin: scattered comments, LibHunt comparison pages.

## Candidates (from the todo)

- Breadcrumbs: Bekaboo/dropbar.nvim (navigable), SmiteshP/nvim-navic (simpler)
- Sidebars: hedyhli/outline.nvim, stevearc/aerial.nvim, oskarrrrrrr/symbols.nvim

## Breadcrumbs: dropbar vs navic

| | dropbar.nvim | nvim-navic |
|---|---|---|
| Sources | LSP, treesitter, markdown, path, terminal; LSP/TS fallback per buffer | LSP only, one server per buffer |
| JSON/YAML | TS: `pair`, `block_mapping_pair`, `object`, `array` are valid types | needs jsonls (configured) / yamlls (not configured) |
| UI | click a crumb: sibling menu, pick mode, fuzzy filter, preview, mouse | text only; click jumps; menus via nvim-navbuddy |
| Big files | off above 1 MiB (default `bar.enable`), `max_depth` 16, debounce 32 ms | `lazy_update_context`: update on CursorHold only |
| Needs | nvim 0.11+, no deps | nvim 0.7+, nvim-lspconfig |
| Activity | ~600 commits, 12 open issues | ~200 commits, 27 open issues |

- Winner: dropbar (faster, more flexible, more features).
- Catch: dropbar's default `bar.enable` skips windows that already have a
  `winbar`; genja-statusline sets one. Either dropbar owns the winbar, or its
  string is embedded in ours (not checked how).

## Sidebars: aerial vs outline vs symbols

| | aerial.nvim | outline.nvim | symbols.nvim |
|---|---|---|---|
| Sources | TS first (70+ langs incl json, yaml), then LSP, markdown, asciidoc, man | LSP; built-in markdown, norg, JSX; external providers (TS, ctags) | LSP; TS for TS, markdown, vimdoc, org, json, jsonl, make |
| json/yaml without LSP | both | no | json only |
| Features | left/right/float, nav float, telescope/fzf/snacks, next/prev jumps, folds, lualine crumbs | tree, live preview/edit, follows cursor | fuzzy search, preview/edit, per-language filters |
| Big files | off above 10000 lines or 2 MB; `update_delay` 300 ms | slow first open (LSP); preview copies the whole buffer | TS JSON slow on big files, so JSON prefers LSP |
| Maturity | ~2.4k stars, MIT, stevearc (oil, overseer) | ~1k stars, active fork of symbols-outline | ~150 stars, main branch may break, API experimental |

- Winner: aerial (TS first with LSP fallback, per-filetype backends, widest
  language coverage, most features, most mentioned in comments).
- outline.nvim if only what the LSP reports is wanted.

## Per filetype / per size

- Loading by filetype works: lazy `ft`, dropbar `bar.enable`, aerial
  `backends`/`filter_kind` per filetype.
- Size cost runs the other way from "sidebar for massive files":
  - A cursor path walks from the cursor node to the root: cost follows
    nesting depth, not file size; treesitter re-parses edits incrementally.
  - A sidebar builds and redraws the whole symbol tree; that's why aerial
    turns off above 10k lines and dropbar above 1 MB.
  - LSP symbols are heavier still: the whole tree per request. jsonls and
    yamlls likely cap symbols at 5000 items (`maxItemsComputed`; unverified).
- Suggested split:
  - winbar path for every size (dropbar, or the planned ~30-line TS walk in
    genja-statusline: no dependency, json/yaml only, no size limit)
  - sidebar on demand (`cmd`/`keys`) for skimming normal files
  - massive files: raise dropbar's 1 MB cap or use the TS walk; no sidebar
  - optional rule: small file -> aerial may auto-open; big file -> winbar only

## Language coverage

- dropbar: anything with a TS parser or a documentSymbol LSP; broadest for crumbs.
- aerial: 70+ TS languages + LSP + markdown/asciidoc/man; broadest sidebar.
- outline.nvim: LSP languages + markdown/norg/man.
- symbols.nvim: LSP + a few TS formats; no YAML without yamlls.
- navic: LSP only. Here: no YAML (yamlls not set up), no Makefile.
- Windows: none of them documents anything Windows-specific.

## State in this repo

- jsonls configured (`plug-wip/genja-completion011.nvim/lua/genja/lang/json.lua`); no yamlls.
- json and yaml parsers in `lua/lazyp/my/load-treesitter.lua`.
- None of the five plugins installed.
- Winbar comes from `plug-wip/genja-statusline.nvim`.

## Sources

- https://github.com/Bekaboo/dropbar.nvim, `lua/dropbar/configs.lua`
- https://github.com/SmiteshP/nvim-navic
- https://github.com/hedyhli/outline.nvim
- https://github.com/stevearc/aerial.nvim, `queries/yaml/aerial.scm`
- https://github.com/oskarrrrrrr/symbols.nvim
- https://www.libhunt.com/compare-outline.nvim-vs-aerial.nvim
- https://www.libhunt.com/compare-dropbar.nvim-vs-aerial.nvim
- https://petejon.es/posts/2025-01-29-using-neovim-for-r/ (aerial for markdown outlines)
- Related key-path tools: myzel394/jsonfly.nvim, jessesimpson36/whereami.nvim,
  mosheavni/yaml-companion.nvim
