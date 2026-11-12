# Neovim config (On-Screen Nvim; Lua profile `genja`)

Neovim 0.11+ config on Windows, at `%LOCALAPPDATA%\nvim`.
Plugin data in `%LOCALAPPDATA%\nvim-data`.
Plugin manager: lazy.nvim.
Depends on genja-plugins (my own plugins) for lot's of the functionality
Offers an optional Flutter based Gui for pull requests, and project management (OpenSpeck, backlog.md)

<!-- {{{ cuaude meta -->
## Cluaude.md meta instructions

### How this file is kept

One `##` heading per feature, `###` for its parts, a short paragraph or list item per decision.
Headings stop at level 3; below that, a list of parallel rules.
Unmarked text was stated by user.
`Hint:` is a working note for Claude.
`(inferred)` marks Claude's reading of the code or history: confirm or delete.

### Formatting CLAUDE.md

Wrap prose at 100 columns. Keep a backtick span on one line where it fits.

Structure with headings down to level 3 (`###`). Put decisions in short paragraphs under their
heading. Where a topic has several parallel rules, use a list instead of a fourth heading level.

List items don't end with a period; paragraphs do.

<!-- }}} -->

## Color design

When asked to change or add colors, work like a good front-end and color designer: derive, measure,
keep a hierarchy. The colors live in `lua/genja/hilite.lua` (one function per topic, each called
from `M.setup` and again on `ColorScheme`) with plain fallbacks in `lua/genja/hilite.vim`. For the
`cc` helper (`darken`, `lighten`, `blend`, `bg_from`) see `## Highlight colors`.

### Measure, don't guess

The colorscheme (`lunaperche`) decides what a link resolves to, so a hex in the code says little.
Resolve the real colors headless (`nvim_get_hl` with `link = false`) and compute the contrast ratio
against the real `Normal` background (`#000000`, text `#c6c6c6`) before and after a change. Say
plainly when it was not measured.

Contrast targets, against `Normal`:

- text that must be read (heading text, inline code, closed-fold text): 4.5 and up
- secondary (comments, heading markers, diagnostic text): about 3.5 to 4.5
- chrome (fold column, underlines): about 2 to 3, quiet but still there; the fold column sits near 2
- below 1.5 a mark is invisible on a dark background

### Derive, don't hardcode

Start from a related color and move it: `cc(base):blend(other, percent)`, `:darken()`, `:lighten()`.
Typical sources: the `StatusLine` foreground (the orange accent), the `Normal` foreground (to quiet
a color towards the text) and the `Normal` background (for surfaces).

- Blend towards `Normal` fg to make something less prominent, towards the accent to tie it to the UI
- Start from a named constant, not from the current group, so running the function again doesn't
  blend twice
- Put the percentage in a named constant (0 keeps the start, 100 becomes the target); adjust in
  steps of 10 to 15 and say which way is "more" in the comment
- A group that follows another is a link, not a copy (`hi! link`)

### Hierarchy

Prominence follows importance. From loud to quiet: headings, then text-like marks (inline code,
closed fold text), then comments and markers, then chrome (fold column, underlines).

- Headings: bold for the top levels, a step darker per level below, same hue
- Markers (`#`, delimiters): the same hue as their text, darker, so the text carries the line
- Comments: gray, no background, and never louder than the code around them
- Chrome borrows the accent but stays dim

### Surfaces

- No background on inline marks (code, comments); they sit on `Normal`
- A float gets the `Normal` background lightened a few percent: it stands out but stays dark, never
  a mid gray
- Padding is part of the surface: same background, no border or box
- The colorscheme's gray `NormalFloat` is for floats not worth styling

### Scope

Highlight groups are global; there are no buffer-local groups. Scope a color by the group name
(`@markup.raw.markdown_inline`, `markdownH1`: they exist only in markdown) or per window with
`winhighlight` (`after/ftplugin/markdown.lua` swaps the html comment group for `MdComment`; the
diagnostic float sets it in `lua/genja/ext/diag-float.lua`). Never recolor a shared group such as
`Comment` or `NormalFloat` for one filetype or one float.

### Fallback

`lua/genja/hilite.vim` carries a plain hex for every color the Lua derives, so nvim still looks
right if the Lua part doesn't run. Keep both in step: each side has a comment naming the other, and
the Lua constant is the same hex.

## Nvim Distribution Goal

### Position

An alternative to the nvim distributions: some are bloated, others too small; On-Screen Nvim aims to
be a ready-to-go setup in between. Not a contest: no claim to be better than other distributions.

The distributions tried were either too slow and too far from the Vim feel, or good starting points
without well-integrated coding workflows built on LSP.

So: no animated or sliding UI messages; keep input instant, startup fast and the Vim feel intact;
make the LSP coding workflows (completion, diagnostics, lint, tests, git, AI) work together out of
the box.

### Feel

- Slow and un-Vim-like meant: animated notifications and sliding messages inside the nvim UI (a
  desktop paradigm that doesn't fit nvim), and typing input that lagged; much clunkier than Vim.
  Vim's responsiveness is the bar
- Startup below 1 s, ideally
- Not an IDE-looking nvim. The current setup is the user's own take on a clean Vi-like experience
  and is enough as it is; not a Vi clone, don't strip features toward Vi
- Capable underneath, plain on the surface: features are found by digging, as in Vim itself. Not
  ideal, but preferred
- File trees (NERDTree, used for years) have their place, but a sidebar eats screen space better
  used for text; no distracting UI elements. Oil (a buffer you edit) fits the file navigation needs
  instead
- Sidebars (aerial) only on demand, never always or for every file
- Floats on demand are fine. which-key as configured (left side, vertical list, category prefixes in
  `desc`) is not disruptive; keep it
- Work session: start nvim in the working folder, open a bunch of tabs; splits only when needed.
  Tabs are simpler to navigate and close

### Workflow

- PHP is the example: a project mixes PHP, HTML, CSS and JavaScript, often a framework (Symfony,
  Laravel; also Drupal, WordPress, custom apps with Behat or other tests). Out of the box On-Screen
  Nvim should lint it, know the project, parse and highlight the JS and CSS, read its tooling
  (Composer, npm/Node, Bun), `.editorconfig` and the like. The config should fit that project, not
  take 3 days of setup
- Real projects mix: a Drupal site, a Symfony app with a React front end, some test framework.
  Nobody ships a configured experience for that mix; On-Screen Nvim aims to
- Debugging comes in too: no IDE or Vim config the user has opened gives it out of the box, and
  every project needs it at some point. It should feel and behave the same in a C or a Go project
- nvim is the interface to the OS for coding work: shell, terminal, PowerShell, Git Bash, git;
  simple tasks shouldn't need leaving nvim. Windows lacks a good setup otherwise (user came from
  Linux)
- Control WSL instances and Docker containers from nvim

### Languages

- PHP is the starting point ("good enough PHP", user has ideas); then the same feel for Go projects
- TypeScript-only projects get the same out of the box (2026-11-10): React, Vue, Angular, plus
  Svelte and Astro; Node tooling (package.json scripts in `<F2>`, vitest/jest, js-debug for Node and
  Chrome). The user doesn't write TypeScript; picture someone who only does
- C: Navigate and explore C projects (user is not a C/C++ developer)
- New languages plug in (e.g. Flutter later): the infrastructure supports adding a language with its
  own rules, without shipping every language. Nobody knows all future projects

### Planned

- Kubernetes YAML: Before 2027: completion and lookup while writing manifests, no browsing the spec.
  Values depend on the components in use (router, ingress, autoscaler); their docs get pulled into
  stdpath('data') and shown through familiar interfaces: generated `:help` files, `K` hover, popups.
  Integrated, not a separate tool
- Next to implement (start before 2027), after cleanup, alongside the LLM chat survey (meta
  `backlog/docs/doc-7 - llm-chat-survey.md`)
- The user is learning Kubernetes; test project `~/es/k8s-minikube-ci` in its own WSL distro
  `minikube` (AlmaLinux 10, bash Makefile), Windows pwsh wrapper `C:/Users/jazzo/es/k8s-minikube-ci`
  (CI in Minikube, Tekton)
- LLM chat: In a buffer, browser-chat style: ask, the answer is appended, follow-ups below it, all
  in one buffer (input buffer optional); questions fold automatically, responses by hand. Any
  provider. Likely extends the genja-ask popup. minuet already covers ghost text. Still an idea, to
  be fleshed out

### Method

Before building a feature, survey what others have built. Use theirs only if its interface fits the
user's mental model; don't adapt to someone else's vision. Otherwise build our own and take the
ideas that work from theirs.

### README

`README.md` explains this to readers; keep it in line with this section. When told to change one of
`README.md` or this file, change the other to match in the same step; don't ask.

The README is not a manual. It says what the config is, why it exists and what it does, in short.

- Not in the README: No keys, commands, options or function names (`<leader>am`,
  `:Minuet change_provider`, `enhance(picker)`)
- No implementation details: how a feature works, which module does what, timeouts, workarounds
- No installation instructions: they go in `install.md` (requirements, lazy.nvim specs); the README
  only points to it
- Where things go: A feature gets a sentence or two about what it gives you; a path to its code or
  guide is fine. Keys go in `readme.cheatsheet.md`; how-tos and details in `doc-wip/`,
  `lua/genja/readme.md` or the plugin's README
- This is for new text only. The manual-like parts already in the README are there on purpose: leave
  them, don't trim or move them, and don't copy them as a pattern

## Main trunk

The main trunk is the branch `enterprise`; this project uses it instead of `main` or `master`. It is
the repo's default branch on origin (GitHub `nvimos/onscreen`); the local `v2026` tracks
`origin/enterprise` (2026-11-08).

Docs and notes say "main trunk", not the branch name, so a rename touches only this section.

The `master` branch is derelict, not likely to become the main trunk.

## Release 2026

### History

2026-11-05: `refactor-2026-sept` merged into `master` (fast-forward at ced1985); branches `develop`
and `v2026` made from it.

`v2026` is the working branch: the release checklist in todo-2026-neovim011.md (## release v2026, 18
items) is done there.

### Branches

Main trunk = stable. `develop` = running branch for ideas beyond the v2026 checklist.

Branch model: OneFlow, develop + main trunk variant (Adam Ruka, endoflineblog.com 2017); git flow is
too much overhead for a single developer; use an established model, not a home-made one. A `v2026`
branch instead of a `v2026` tag was the user's choice.

### Open

When v2026 merges back into the main trunk, and whether worktree branches and `/prish-merge` target
`v2026` or `develop` (today: whatever branch the main checkout is on).

### Spare tokens

Spare tokens before a session reset go to implementing open todos and ideas.

## Ideas and backlog

### Where

The backlog lives in the planning repo github.com/nvimos/meta (public), checkout `~/es/nvimos-meta`
(`vim.g.genja_meta_dir` overrides); moved out of this repo 2026-11-10. New ideas go there as tasks,
not into this repo.

### Structure

Every item is a Backlog.md task; only work that needs a design also gets an OpenSpec change
(`openspec/changes/<id>/`, `proposal.md` names its task, the task a `Change:` line). Never copy an
item into both.

Statuses: `To Do`, `In Progress`, `Needs Test` (built, waiting to be tried by hand), `Done`,
`Dropped`. Build steps and hands-on checks are separate sections (`## Acceptance Criteria` /
`## Verify`, OpenSpec `## 1. Build` / `## 2. Verify`).

### Scanning

`make review` (needs test), `make doing`, `make open` in meta, or `:Morning` (Todo section).

### Legacy

Old todo files are in meta's `legacy/`, read-only: todo-ideas.md, todo-202x.md, squash files,
todo-ideas/ (2026-11-10); todo-2026.md, todo-done/, todo-issue/, todo-test/ in `legacy/nvim-config/`
(2026-11-11). Test session notes are meta `backlog/docs/`.

### Solved issues

`/commit-close-issues` (`.claude/skills/nvim-commit-close-issues/`) writes each as a Backlog.md task
in meta and commits it there; no todo files in this repo.

## Plugins in this repo

Each has its own CLAUDE.md; read it before changing that plugin.

- @plug-wip/genja-ask.nvim/CLAUDE.md: ask popup (`<M-?>`, `<leader>pc`), backends claude -p,
  claudefterm, gemini, copilot, aichat, ollama
- @plug-wip/genja-claudefterm.nvim/CLAUDE.md: claude in a floaterm, one per project: `:ClaudeFterm`,
  session markers, paste context, `send()`
- @plug-wip/genja-commit.nvim/CLAUDE.md: commit popup (oil), gitcommit lint, message generation
- @plug-wip/genja-completion011.nvim/CLAUDE.md: LSP servers, completion, ft/lang modules, dictionary
  words
- @plug-wip/genja-finder.nvim/CLAUDE.md: live grep and live find pickers
- @plug-wip/genja-paste-ai.nvim/CLAUDE.md: paste search in the browser, one current provider:
  `:PasteSearch` (`:Wot`; fixed `:Google`, `:Perplexity`, `:Xty`), `<leader>pl/pw/py/ps`, `<F2>`
  lookup
- @plug-wip/genja-oily.nvim/CLAUDE.md: hide oil entries listed in the nearest `.oily` up the tree
- @plug-wip/genja-startdirs.nvim/CLAUDE.md: start dirs list (text file + spec), oil add/remove,
  jumps, ranking
- @plug-wip/genja-recent.nvim/CLAUDE.md: recent files with own rules, frecency ranking; picker on
  `<C-F1>`
- @plug-wip/genja-splitpad.nvim/CLAUDE.md: padding column next to the split separator in unfocused
  windows
- @plug-wip/genja-statusline.nvim/CLAUDE.md: statusline, tabline, winbar
- @plug-wip/genja-util.nvim/CLAUDE.md: helpers shared by the plug-wip plugins (centred float, uuid,
  code fence, llm backends)

## Working style

### Replies

Terse replies. No anthropomorphising.

Follow-up questions stay on point; no offers to explore unrelated topics.

Say plainly when something was not run or tested that you wanted to run or test. (Hint)

Prompts are often dictated by voice; some words arrive misheard ("deer" = dir, "OAuth" = "followed
by", "whip doc"/"VIP doc" = doc-wip). When a phrase makes no sense, read it as speech-to-text and
pick the likely word; ask only if still unclear.

### Scope

Do only what was asked; list further fixes as suggestions. (inferred)

When asked for a plan, analysis or "don't change anything yet", edit no files.

The tree often has unrelated uncommitted changes; leave them alone.

### Running things

Don't run, test, compile or start sandbox runs unless asked; suggest the command instead. Testing is
done manually to also learn the new features from the user's perspective.

### Commits

- Main checkout: Don't commit unless asked
- Worktrees: In a Claude worktree (`.claude/worktrees/<name>`) or a background session, commit
  finished work without asking; don't merge or push to the main trunk
- Plugin repos: commit in the plugin folder like the main checkout (only when asked); push to its
  GitHub repo only when asked
- Grouping: Group commits by feature; no Claude/Co-Authored-By attribution

### Tools and dependencies

Before patching around a tool's bugs, check upstream issues; check platform support before
recommending a tool.

Prefer built-in vim/nvim functions over new dependencies.

## Files and formatting

### Basics

Unix newlines (LF) everywhere; only `desktop.ini` is CRLF (`.gitattributes`, `.editorconfig`). Don't
mention line endings in replies.

Spaces (4), single quotes (`.editorconfig` `indent_style = space`, since 39fd23c); older files still
have tabs, converted as they are reformatted.

Markdown list items don't end with a period (prose paragraphs do).

Comments: short, explain why. For tricky code, at most one line per callback or function.

Annotate with LuaLS types: `---@type LazySpec` on specs, typed `opts`. `.luarc.json` disables
`missing-fields`.

### Readable Lua

Readable Lua over clever Lua: plain assignments and `if` blocks. A short, non-nested two-way
`(x and y or z)` is fine, wrapped in parentheses; anything longer or nested is an `if` block.

When in doubt, apply the Golang vibe.

- Clear over clever: The boring version anyone reads at once; no metatable tricks, chained `and/or`
  or one-liners that need a second look
- Early returns, flat code: check the bad case and return first; the main path stays at the left
  margin
- Errors are values, handled where they happen: `local ok, err = pcall(...)`, own functions return
  `nil, err`; check at the call; no `error()` for normal control flow, no silent failures
- Except: a failure that is well understood, or doesn't matter to the overall outcome, can stay
  silent (an optional plugin missing, a best-effort cleanup). Say why in a short comment
- Explicit over dynamic: Plain `require` and assignments; no modules built from strings or globbed
  discovery
- No hidden magic: no `__index` inheritance chains, operator overloading or implicit globals; what a
  function does is visible in it
- Size and sharing: A little copying beats a little dependency: three similar lines are fine; a
  helper (in `plug-wip/genja-util.nvim`, shared by the plug-wip plugins) only when it pays off
- Small, single-purpose functions and modules; short local names in small scopes, descriptive names
  for what a module exports
- One formatting, not up for debate (like `gofmt`): `.editorconfig`, 4 spaces, single quotes

## Logging and reporting logical or runtime issues to user

### Source prefix

Notifications name their source: script path relative to the nvim stdpath config folder, e.g.
`after/ftplugin/make.lua: ...`, `lua/genja/map-plugin/init.lua: ...`.

Each file declares the prefix once, near the top: `local SRC = 'lua/genja/auto.lua: '` (path, colon,
space), and calls `vim.notify(SRC .. 'message')`. Always `SRC`, never `src` or an inline path.

### No useless messages

Don't tell the user about things that went fine or that they can't act on. When a problem can be
detected and repaired without harm (e.g. the Hidden attribute that makes a write fail,
`plugin/hidden-write.lua`), repair it at the point of use instead of only warning about it. Keep the
normal path fast (a stat or two) and the repair non-destructive. A repair that works is silent;
notify only when it fails, with the reason and the manual fix.

### plug-wip files

Use only dirname/basename.ext: `SRC = 'genja-commit/popup.lua: '`

## Layout and loading

### Startup

`init.vim` loads `lazy-boot`, then `Safeload('genja')`; if that fails it loads a small fallback
subset.

### Folders

`lua/genja/`: the main profile. `lua/genja/readme.md` describes each file; keep it current when
adding files.

`lua/lazyp/<topic>/`: lazy specs, imported from `lua/genja/lazy-plug-spec.lua`. New plugins and the
plug-wip loaders go in `lua/lazyp/new/`.

Folder names are hyphenated (`util-qol`, `langs-comps`).

Hint: `undodir/`, `state/`, `.claude/` are runtime state; don't edit.

### Specs

Plugins load lazily through `cmd`, `keys` or a late event (`VeryLazy`); a spec without a trigger
never loads.

Unused specs carry `-- not used: 2026-10`; archived upstreams carry `-- archived: YYYY-MM`. Keep
both comments.

When an upstream repo is renamed, use the new name and keep the old one in a comment.

### plug-wip plugins

They live in `plug-wip/<name>`, each its own git repo (github.com/tox2ik/<name>;
genja-completion011.nvim is tox2ik/genja-completion.nvim, abdul-keymaps.nvim is the fork
tox2ik/keymaps.nvim). The nvim repo ignores `/plug-wip/*/`; commit and push inside the plugin
folder.

Specs name the repo and set `dir = Wip.dir('<name>')` (`lua/genja/plug-wip.lua`): the local checkout
when present, else lazy clones the repo. A fresh clone of the config gets the plugins from GitHub
(`tests/startup` clean clone).

A change across a plugin and the config is two commits, one per repo.

## Adding a plugin

### The file

One file per plugin: `lua/lazyp/new/<name>.lua`, returning a `---@type LazySpec` table; the folder
is already imported by `lua/genja/lazy-plug-spec.lua`, so no other registration. Own plugins
(plug-wip) differ, see `## Layout and loading`.

Start the file with a short comment: what it does, the upstream or alternative; not its keys (those
go in `readme.cheatsheet.md`).

Example: `lua/lazyp/new/difftool.lua` (nvim.difftool, commented out).

### The spec

Always give a trigger (`cmd`, `keys`, `event = 'VeryLazy'`); defaults are `lazy = true`, so a spec
without one never loads.

Options go in `opts = {}`; add `-- default` comments for the knobs worth knowing.

Keymaps: follow `## Keymaps` (`desc` starts with the area, add a which-key group in
`lua/lazyp/my/which-key.lua`). Check the key is free before using it.

"Comment out the block" means every spec line is prefixed with `--` inside `return { }`, so the file
still loads and does nothing.

### Built-in optional plugins

`$VIMRUNTIME/pack/dist/opt/` (e.g. `nvim.difftool`, `nvim.undotree`) is not installed: use
`dir = vim.fs.joinpath(vim.env.VIMRUNTIME, 'pack', 'dist', 'opt', '<name>')` in the spec. Read the
plugin's `lua/*.lua` and `plugin/*.lua` there for the real options; the `:help` text may lag.

### Trying it

Without a restart: `:packadd <name>` for a built-in; `:Lazy load <name>` or `:Lazy reload <name>`
for a spec; `:Lazy install` for a new remote plugin.

Dry-run the result headless: `nvim --headless -c "lua print(pcall(require,'lazy'))" -c q`, and note
in the reply what was not run.

## Options (opt.lua)

`vim.opt` values are strings, not tables; use several `:append()` / `+` lines when needed.

Hint: when translating Vimscript, spaces before a `"` comment are not part of the value, and `\` is
one space.

Each `fillchars` item is one character. `opt.lua` sets `fillchars` `fold:` twice and the last (`·`)
wins. (deliberate, ask before changing)

## Right-click menu

### Terms

"Pop-up menu" or "right-click menu" means nvim's `PopUp` menu: the menu that opens on a right mouse
click in the editor (`:h popup-menu`), not a telescope picker, the F2 menu or the completion menu.

A bare "pop-up" or "popup" does not mean that menu: it can be a modal or a float (the commit popup,
the ask popup); ask when it is not clear.

### Code

It is all in `lua/genja/popup.lua`: fixed items, per-buffer entries rebuilt on `MenuPopup`.

- Submenus: The `PopUp` menu does not nest: activating an item that has children fails with E335. A
  "submenu" is a plain item `Name actions` that runs `:popup ]Name\ submenu`, a hidden menu; an
  entry gets there with `submenu = 'Name'`
- Priority: One number per level, dot separated; `PopUp`'s own is unused, so `.9999` puts an item
  last (`:h sub-menu-priority`)

## Highlight colors

### Where

Extra highlight groups are set in `lua/genja/hilite.lua` (`M.setup`), through the `cc(fg, bg)`
helper (`ColorTable`).

### Darker and lighter

Chain `:darken(percent)` or `:lighten(percent)` onto `cc(...)` instead of computing a hex by hand:
`cc('#B5642F'):darken(30):t()`.

Percent is 0 to 100: that many percent towards black (`darken`) or white (`lighten`); default 20.
Both change `fg` and `bg`, whichever are set; the color must be a `'#rrggbb'` string.

### Blend

`:blend('#rrggbb', percent)` moves them that many percent towards another color (100 becomes it).

`:bg_from('Normal')` starts from a highlight group's background, so colors follow the colorscheme.

The diffview red/green fold in the same file uses
`bg_from('Normal'):blend(<very dark red or green>, percent)`; tune its `DARK_*` and `BLEND_*`
constants.

## Alma vimrc split

`lua/genja/vimrc.almalinux.vim` is a one-file config for legacy vim 9+, to use in a pinch.

Portable core on top, then `if has('nvim') | finish | endif`, then vim-only parts: vim-plug, curl
downloads, fzf, plugin config, statusline, colors, options that conflict with genja, clashing
keymaps. So vim-plug plugins are never installed when nvim sources the file.

Today `init.vim` sources it only in the fallback branch.

Don't duplicate alma settings into Lua. A later accidental alma import into `opt.lua`/`auto.lua` was
reverted (9555e32); the fold block in `opt.lua` was added back on request.

## Plugins, extensions

### Finder and start dirs

Live grep and live find live in `plug-wip/genja-finder.nvim`; see its CLAUDE.md.

`Telemap` and the refine decorator live in genja-finder:
`require('genja-finder.telemap').Telemap(map)`, `require('genja-finder').attach_shared_keys(map)` /
`.enhance(picker)`; see its CLAUDE.md.

Start dirs come from `plug-wip/genja-startdirs.nvim` (`require('genja-startdirs').dirs()` /
`.ranked()`); the list is `lua/genja/local/startdirs.txt` (gitignored). The `START_DIRS` global is
gone.

### Telescope

Extensions (`lua/telescope/_extensions/`: finn, mycolors, mydirs, mylunsj, undersort) stay in the
config, unless otherwise instructed.

`file_ignore_patterns` (in `after/plugin/telescope-after.lua`) are anchored, e.g. `"%.a$"`.

## LSP and completion

Everything lives in `plug-wip/genja-completion011.nvim`, loaded by
`lua/lazyp/new/genja-comp011.lua`; see its CLAUDE.md.

### Adding a language

Consider LazyVim's language extras and AstroCommunity's packs as a starting point (their choices,
not their files); see the plugin's CLAUDE.md, "Look at LazyVim and AstroNvim first".

Per-machine language switches go in `lua/genja/lsp/local.lua` (gitignored), not in the spec's
`enabled` table.

### Filetypes and parsers

Filetype specs live in the plugin's `lua/genja/ft/`; personal ones stay in the config's
`lua/genja/ft/` (`yaml.lua`: `yml` -> `yaml.ansible`).

Treesitter parsers are listed in `lua/lazyp/my/load-treesitter.lua`.

## Keymaps

### Files

`map-zero.lua`: essential maps that must not fail. `map-lsp.lua`, `map-telescope.lua`,
`map-convoluted.lua`, `map-jolemak.lua` hold the rest by topic.

Plugin keys and config keymaps go in `lua/genja/map-plugin/<spec file name>.lua`; specs use
`keys = Maps:keys()` and call `Maps:mappings(opts)` in `config`.

### Keyboard

Layout: jolemak, a compiled build of `C:/Users/jazzo/ws/genja-jolemak/opt/jolemak/jolemak.2026.klc`.
For quirky bindings or key issues (which key sends what, dead keys, AltGr layers), check that source
file.

`<leader>?` belongs to keymaps.nvim; cheatsheet.nvim's mapping is commented out.

### Claude and floaterm

Floaterm commands end in `Fterm` (`:LazygitFterm`, `:BashFterm`, `:PythonFterm`, `:RangerFterm`,
`:ClaudeFterm`, in `auto-alias.vim`; `:ClaudeFterm` comes from `plug-wip/genja-claudefterm.nvim`).

`:ClaudeFterm [flags]` passes flags (e.g. `--chrome`) to claude at start; completion list `FLAGS` /
`FLAG_VALUES` in `plug-wip/genja-claudefterm.nvim`.

`<leader>pc` opens the ask popup, `<leader>pC` pastes context into claude, `<leader>mC` lists
running claude terminals (`plugin/claude-fterm.lua`); `<F2>` lists them too
(`lua/genja/f2/collect/claude.lua`).

### PHP

`<leader>cAp` runs `:PhpDocParams` (`map-lsp.lua`, PHP buffers).

### Adding keys

When adding keys, in the config or with a new plugin:

- Documenting: Add them to `readme.cheatsheet.md`, one section per plugin or topic, naming the file
  that sets them
- Don't list a file's keymaps again in its comments; the code (`desc`) is the list
- File headers (ext modules, plugin/ glue, specs, map-plugin files) say what the file does and point
  to the file that sets its keys (`Keys: lua/genja/map-zero.lua`); no key names. Keys may appear
  where they explain a choice, e.g. a collision with an nvim default (`lua/lazyp/new/mini-ai.lua`)
- Main config: keys go only in `readme.cheatsheet.md`, not in `lua/genja/readme.md` or other
  readmes. A plug-wip plugin or module with its own README gets keys there only if it already has a
  keymaps section
- which-key: Write `desc` so it sorts well: which-key sorts by `desc`
  (`lua/lazyp/my/which-key.lua`), so start with the area and then the object, e.g.
  `Git: hunk stage`, `Git: hunk reset`, `UI: git status (Neogit)`
- Add a which-key group (`{ '<leader>x', group = 'Area: topics' }`) in `lua/lazyp/my/which-key.lua`
  for each new prefix, and widen an existing group's label when new keys land under it

## Git

Neogit (UI), gitsigns (hunks), diffview (diffs, history), mini.git (`:Git`); specs in
`lua/lazyp/git/`, keys in `lua/genja/map-plugin/<spec>.lua`. Fugitive is disabled.

diffview comes from the maintained fork `dlyongemallo/diffview.nvim`; sindrets/diffview.nvim had no
updates since 2024-06. (inferred)

Keys: `<leader>mg` Neogit, `<leader>mGl` Neogit log, `<leader>mGc` commit popup,
`<leader>md`/`mh`/`mH` diffview, `<leader>h…` gitsigns hunks, `<leader>hc` mini.git commit at
cursor, `]c` `[c` hunks outside diff mode; gitsigns keys are buffer-local (on_attach).

## Windows environment

Git for Windows plus Windows OpenSSH; `lua/genja/env.lua` sets `GIT_SSH_COMMAND` so lazy clones over
ssh work (gitconfig rewrites https to ssh).

PHP lives at `C:\tools\php83`; phpactor runs in the WSL distro set in `lsp/local.lua`.

undotree uses Git's `diff.exe` through an 8.3 short path; an upstream quoting fix is drafted in
`lua/lazyp/util-qol/undotree.diff`.

Hint: write Windows paths with forward slashes in Lua.

## Small features

Paste search (perplexity and other providers): `plug-wip/genja-paste-ai.nvim`, query encoded with
`vim.uri_encode(q, 'rfc2396')`.

## Tests

`tests/Makefile` runs mini.test through pwsh; `make help` lists targets and variables.

### Writing tests

New test files start from `tests/helpers/child.lua`: `C.fresh(setup)` gives a child per case on
minimal_init, `C.eval`, `C.needs(exe, case)`, `C.installed(...)`, `C.typer` / `C.settle` for
telescope, `C.wait_for`, snippets `C.TMP` and `C.NOTES`. A case shows its intent: setup in `fresh`,
helpers in the file's top, the case itself a few lines.

### Timings

Every case is timed, its weighted average (newest run 30%) kept in
`stdpath('state')/genja-tests/timings.json` (throw-away; `make timings` shows it). Code and details:
header of `tests/helpers/timing.lua`.

- Suites: comps011 and llm cases use `S:case()`: groups, a timeout, a slow cutoff, `requires` (what
  it skips without). Other dirs' cases are timed by `adopt()` with the default timeout (12 s) and
  cutoff (3 s), no groups
- Any dir can: `local S = require('helpers.timing').suite('<dir>')`, then
  `T[name] = S:case({ name, groups, timeout, slow }, function(ctx) ... end)`; `ctx.timeout` is the
  case's timeout for its wait loops (`H.wait(check, ms)`). Call `H.save()` in `post_once`, as
  comps011 does
- The timeout only bounds the case's own waits and caps its recorded time; the slow cutoff only
  sorts it into the slow list. Neither stops a case by itself
- `MiniTest.add_note(msg)` records a warning without failing the case (llm: a `/bin/sh` shebang)
- Hint: `nil` returned by `child.lua()` arrives as `vim.NIL`, which is truthy: a `H.wait()` poll
  would stop at once. Return `false` from the child (tests/llm), or map `vim.NIL` to `nil`
  (`C.selected()` in tests/helpers/completion.lua)
- A case is slow when its average is above its cutoff. The default run (`G=` unset) leaves slow
  cases out and says so after the summary, with the days since the last full `make gather`;
  `make gather` runs everything; `G=slow` only the slow ones; `make slow` lists them. A skip is not
  timed; a timeout counts as its timeout
- `make plan` estimates from the averages: the selected run, the slow ones left out, and every test
  of any group (average capped at today's timeout; never timed: the timeout, or "not timed yet" for
  plain cases)
- Failures: After each run, `genja-tests/failed.json` (next to the timings) gets the cases that
  failed and loses the ones that passed or skipped; cases that didn't run keep their last result.
  `make failed` reruns those, whatever their group, verbose by default
- Timeouts: For a working machine, not padded for worst cases: lua_ls `ready`/`cmp` 10 s, slow at 8
  s. The tests run with `GENJA_LUA_NO_LIB=1` (lua_ls without libraries); they check that servers
  work, not the libraries

### Table output

`make status` (and other table output from `tests/helpers/`) is a neat table.

- Columns: The name column (language, tool, linter) comes first. Then the short, fixed-width columns
  (on/off, ok/MISSING); long or variable ones (commands, paths, notes) go to the right
- Header and legend: Each table has a header row with column names at the same widths as its rows; a
  one-line legend above it when values aren't obvious from the names (`-`, `*`, `enabled`)
- Rows and notes: Row order: on and ok, then on but missing, then off. Within that, the languages
  table sorts by the server column; rows without a server come last
- Notes are terse, no parentheses: `parse errors: ftplugin/gitconfig.lua`

### make help

Text: lowercase, terse; target descriptions don't mention the variables (D=, G=, V=); no
parenthesised asides; don't explain what an unset variable does.

## Quirks

### vim-floaterm

`--autoclose` (and `g:floaterm_autoclose`) takes only `always`, `never`, `smart`; numbers like `0`
give an argument error.

### genja-claudefterm

It starts claude with `--autoclose=never` and closes the window itself on exit (`on_exit`):
floaterm's own close hits E444 when the claude split is the last window. floaterm's
`BufHidden,BufWipeout` autocmd (group `floaterm_enter_insertmode`) also closes the window, so
`on_exit` clears it before `nvim_win_set_buf`.

