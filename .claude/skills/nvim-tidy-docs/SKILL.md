---
name: tidy-docs
description: Tidy the nvim config's markdown docs (README.md, CLAUDE.md, readme.*.md, doc-wip/, todo files, plug-wip READMEs) - rewrap lines to the file's width, split long sentences, cut filler words, make lists and terms consistent, without changing what they say. Use when the user types /tidy-docs, or asks to tidy, clean up, rewrap or proofread documentation.
---

# tidy-docs

Makes the docs in the nvim config (`%LOCALAPPDATA%/nvim`) easier to read. Form only: the content, decisions
and the user's voice stay. Edits the files named in the args, else the docs changed since the last commit
(`git status --short -- '*.md'`); with neither, ask which files. Commits nothing.

Draft rules, filled in from the repo's existing style; the user will review them.

## 1. Line width, per kind of file

Measure first (`awk '{print length}' <file> | sort -n | uniq -c`) and keep a file's own width when it has a
clear one; the values below are what the repo uses today.

- `README.md` and plug-wip `README.md`: prose wrapped at about 74 columns. List items continue with a 2-space
  indent under the text.
- `CLAUDE.md` (config and plugins): one bullet per line, not wrapped. A bullet that runs past about 250
  characters is split into sub-bullets (4-space indent), one point each.
- todo files (`todo-*.md`, `todo-issue/`, `todo-done/`), `doc-wip/`, `readme.*.md`: wrap at 120
  (`after/ftplugin/markdown.vim` sets `textwidth=120`); sub-items indented 4 spaces; continuation lines line
  up under the item text.
- Rewrap a whole paragraph, not single lines, so no short ragged line is left in the middle.
- Never wrap or reflow: code blocks, tables, headings, URLs, link targets, command lines, paths, a line that is
  a key list or a table-like alignment.

## 2. Sentences

- One idea per sentence. Split a sentence over about 25 words, or one with two `;` or more than one aside.
- Lead with the point: what it does, then how or why.
- Prefer plain words and the active voice. Present tense for how things are; past tense only for history.
- Cut filler that adds nothing: really, actually, basically, just, simply, genuine, honest, real, very,
  "in order to" (to), "it is worth noting".
- Parenthesised asides: keep when short and useful (a path, a key, an example); otherwise make them their own
  sentence or drop them if they repeat.
- No conversational text in docs ("as discussed", "we", "let's"). The README is in the user's voice (first
  person "I") and keeps it, including their word choices; tidy around them, don't polish them away.

## 3. Lists and structure

- Bullets use `-`; checklists `- [ ]`, `- [x]`, `- [~]` (tried), `- [n]` (no) as in `todo-ideas.md`.
- A list item that holds several steps (`Topic: step, step; step`) becomes a topic line with one step per
  sub-item (see the `md-reformat` skill).
- CLAUDE.md keeps its own markers: one `##` heading per feature, one bullet per decision, `Hint:` and
  `(inferred)` as they are. Don't merge, reorder or drop bullets; moving one under a better heading is fine
  when it plainly belongs there, say so in the output.
- List items don't end with a period, also when an item holds a full sentence. Remove a trailing period on
  items; periods between sentences inside one item stay. Prose paragraphs keep theirs.
- Headings: short, no trailing colon, sentence case unless the file uses another.

## 4. Terms and names

- The project is "On-Screen Nvim" in prose; `genja` stays only as the code name (`lua/genja/`, the `genja`
  profile, `genja-*.nvim` plugins).
- Neovim's own spelling: "Neovim" in full, "Nvim" as the short name (as in `:help`), `nvim` only for the
  command or binary. Plugin names keep their `.nvim` (`lazy.nvim`, `genja-*.nvim`).
- The main branch is the "main trunk" (`enterprise`), never `master` or `main`; `master` only in history notes.
- Code, paths, commands, keys, options and filetypes in backticks: `:EnableLang`, `<leader>mGc`,
  `lua/genja/ext/lint.lua`. Keys written as nvim writes them (`<C-p>`, `<M-g>`, `<leader>`).
- Notification sources as in CLAUDE.md (`SRC = 'lua/genja/auto.lua: '`), when a doc quotes one.
- One spelling per word in a file; US spelling when the file has no clear choice.
- Dates `yyyy-mm-dd`; short commit hashes in backticks or plain as the file already does.

## 5. Files and format

- LF newlines, no trailing spaces, one blank line between blocks, one newline at the end.
- Spaces, not tabs, in markdown.
- `README.md` and `CLAUDE.md` stay in sync (CLAUDE.md, Goal): a change of meaning in one goes into the other.
  Tidying form alone needs no sync.

## 6. Don't

- Don't change meaning, decisions, numbers, keys, paths or hashes. When a sentence is unclear and two readings
  are possible, leave it and list it in the output.
- Don't delete content. Duplicates and stale lines go in the output as suggestions.
- Don't touch generated files (`doc/tags`, lock files) or `.claude/` runtime state, `undodir/`, `state/`.
- Leave unrelated uncommitted changes in the same file as they are.

## Output

- Per file: what was tidied, in a few words (rewrapped, sentences split, terms fixed).
- Unclear sentences and suggested removals, one line each, with `file:line`.
- Nothing committed.
