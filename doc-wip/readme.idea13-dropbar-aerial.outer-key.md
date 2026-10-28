# Idea 13: dropbar (breadcrumbs) + aerial (outline)

Where the cursor is: dropbar's crumbs in the winbar. Overview of the file:
aerial's sidebar or nav float. Not run or tested yet. Analysis and plugin
comparison: `doc-wip/idea-oct.13-symbols.md`.

Files:

- `lua/lazyp/ui/dropbar.lua`, `lua/lazyp/ui/aerial.lua`: specs
- `lua/lazyp/new/genja-statusline.lua`: embeds dropbar in genja's winbar
- `plug-wip/genja-statusline.nvim/lua/genja-statusline/winbar.lua`: the
  `winbar_extra` option that does the embedding
- `plug-wip/genja-statusline.nvim/lua/genja-statusline/keypath.lua`: json/yaml
  key path without plugins, not wired up

## Setup, once

- `:Lazy sync` (installs dropbar.nvim and aerial.nvim).
- Restart nvim. dropbar loads on `VeryLazy`, so the crumbs appear after the
  first cursor move.
- Optional: `:set mousemoveevent` for dropbar's hover highlight.

## dropbar.nvim: breadcrumbs

- Shows the symbol path at the cursor after the file name in the winbar, e.g.
  `init  M › setup › opts` or, in yaml, `spec › containers › image`.
- Sources, chosen once per window when its bar is created:
  - LSP symbols, falling back to treesitter
  - files over 1 MiB: treesitter only (LSP sends the whole symbol tree per
    request; the treesitter walk from the cursor costs the same at any size)
  - markdown: headings
  - no path source: genja shows the file name already
- Only file buffers in normal windows; oil, help, terminal, quickfix and
  floats show genja's part only.
- Help stays off on purpose (checked upstream 2026-10-18): dropbar's
  treesitter source has no vimdoc node types (h1, h2, h3, tag), and vimdoc
  headings are flat siblings, so there is no path to show. dropbar's own
  default turns help off too. Use aerial in help.

### Keys

- `<leader>;` pick mode: each crumb gets a letter from `jwfasrzxc`; press
  it to open that crumb's menu
- `[;` jump to the start of the current context (function, block, key)
- `];` select the next context
- Mouse: click a crumb for a menu of its siblings

### In a dropbar menu

- `<CR>` jump to the entry (or open its submenu)
- `i` fuzzy filter the entries; `<Esc>` leaves the filter, `<Up>`/`<Down>` move
- `q` / `<Esc>` close the menu
- `<LeftMouse>` click an entry; outside the menus closes them all

### How it is embedded

- genja owns `'winbar'` (global `%{%v:lua.require'genja-statusline'.Winbar()%}`).
  dropbar's default would replace it per window with `%{%v:lua.dropbar()%}`.
- So dropbar runs with `bar.enable = false`: its attach step never sets
  `winbar`, but its update autocmds still refresh bars that exist.
- genja's `winbar_extra` option takes functions `fn(buf, win) -> string`. The
  config passes one that returns `_G.dropbar()`, which creates the bar for the
  window on first call and returns its cached string (with dropbar's own
  highlights and click handlers).
- The parts come after a `%<`, so a narrow window cuts the crumbs from the
  left and the innermost symbol stays visible.

### The other way round: genja inside dropbar

- Possible: a dropbar source is a table with `get_symbols(buf, win, cursor)`
  returning `dropbar_symbol_t` items (`name`, `name_hl`, `icon`, `on_click`).
  A source could return genja's file name and flags as symbols; dropbar would
  then own `winbar` (`bar.enable` back to its default).
- Not done: genja is the base, and it stays usable without dropbar.
- The key path module could become a dropbar source the same way, if
  dropbar's treesitter crumbs for json/yaml turn out worse.

## aerial.nvim: outline

- Sidebar with the file's symbols as a tree, nav float, telescope picker.
- Treesitter first, LSP as fallback; markdown, asciidoc and man pages too.
- json: keys whose value is an object; yaml: mappings, lists and list items
  with a `name:` key (ansible tasks, workflow steps).
- One sidebar that follows the current window (`attach_mode = 'global'`); it
  closes itself on buffers it can't outline (oil, terminal).
- Help works out of the box: aerial has a vimdoc query (h1/h2 headings and
  `*tags*`, kind Interface, in the default filter), and its "special" ignore
  rule lets `buftype=help` through.
- Off above 10000 lines or 2 MB (aerial's default). For big files use the
  crumbs.

### Keys

- `<leader>mo` sidebar on/off (cursor stays in the code)
- `<leader>mO` nav float: the symbols around the cursor in columns
- `<leader>ja` telescope picker over the file's symbols
- `[o` / `]o` previous / next symbol

### In the sidebar

- `<CR>` jump; `<C-v>` / `<C-s>` jump in a vsplit / split
- `p` scroll the code to the symbol without leaving the sidebar
- `<C-j>` / `<C-k>` move and scroll the code along
- `{` / `}` previous / next symbol; `[[` / `]]` up a level
- `o` / `za` fold toggle; `O` recursive; `l` / `h` open / close; `zR` / `zM` all
- `q` close; `?` all keys

### In the nav float

- `h` / `l` parent / child column, `<CR>` jump, `<C-c>` close

## Key path without plugins (genja-statusline keypath.lua)

- `spec.containers[0].image` style path for json, jsonc, json5, yaml,
  yaml.ansible; treesitter walk from cursor to root, cut from the left at 60
  characters.
- Not shown. To try it, add to `winbar_extra` in
  `lua/lazyp/new/genja-statusline.lua`:
  ```lua
  winbar_extra = {
  	dropbar_part,
  	function(buf, win) return require('genja-statusline.keypath').render(buf, win) end,
  },
  ```
- With dropbar on, json/yaml then shows both; make `dropbar_part` return `''`
  when `require('genja-statusline.keypath').supports(buf)` to keep one.

## Quirks and open points

- Untested: that dropbar's update autocmds refresh a bar it didn't attach
  (read from its source: they update every bar that exists).
- dropbar truncates against the full window width; genja's file name comes
  first, so long crumbs are cut by nvim's `%<` instead.
- A bar's sources are picked once per window; a file that grows past 1 MiB
  keeps LSP crumbs until the window is reopened.
- `[o`/`]o` and `<leader>ja` load aerial on first use; the sidebar needs a
  treesitter parser or an LSP with document symbols.
- Not in the `g.` action menu (#17) yet.

## Docs

- `:help dropbar`, https://github.com/Bekaboo/dropbar.nvim
- `:help aerial`, https://github.com/stevearc/aerial.nvim
- `:help genja-statusline-keypath`
