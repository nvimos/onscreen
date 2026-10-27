# blink.cmp: manual test guide

What the automated tests don't cover: how it looks and feels while typing.
Back to nvim-cmp: `git checkout before-blink-2026-w44 -- plug-wip/genja-completion011.nvim lua/lazyp`.
Config: `plug-wip/genja-completion011.nvim/lua/genja/completion/`.

## 0. Start

- [ ] Restart nvim (nvim-qt and a terminal nvim), open a `.lua` file: no error messages.
- [ ] `:checkhealth blink.cmp`: fuzzy matcher is `rust`, no errors.
- [ ] `:Lazy clean` removes nvim-cmp, cmp-buffer, cmp-cmdline, cmp-nvim-lsp, cmp-path, lspkind.

## 1. Menu and keys (insert mode, a `.lua` file)

- [ ] Type `vim.ap`: the menu opens by itself; the first item is selected.
- [ ] `<CR>` inserts the selected item.
- [ ] `<Tab>` / `<S-Tab>` walk the menu; the item is put in the text as you walk.
- [ ] `<F2>` / `<F3>` walk the menu too.
- [ ] Menu closed, cursor after text (e.g. after `vim`): `<Tab>` opens the menu.
- [ ] Menu closed, cursor after a space or at line start: `<Tab>` inserts a tab/indent.
- [ ] `<C-Space>` opens the menu; again shows the documentation.
- [ ] jolemak `<C-e>` (sends `^K`): closes the menu and puts back what you typed.
- [ ] `<C-y>` accepts, `<C-n>` / `<C-p>` walk (blink's default preset).
- [ ] `<CR>` with the menu closed: a plain newline.

Old behaviour check (optional): uncomment the `config.completion.list` line at the end of
`keymaps.lua`, restart: nothing is preselected and `<CR>` makes a newline until you pick
with `<Tab>`. Comment it again.

## 2. Look

- [ ] Menu colours: StatusLine background, selected row readable.
- [ ] Kind icons show (Nerd Font) in nvim-qt and in the terminal.
- [ ] Documentation window opens next to the menu after a moment, for an LSP item.
- [ ] Long labels don't push the menu off screen.

## 3. Snippets (LSP)

- [ ] In a `.lua` file, accept a function item from lua_ls (e.g. `vim.api.nvim_buf_get_lines`):
      arguments come as placeholders; `<Tab>` jumps to the next, `<S-Tab>` back.

## 4. Sources per filetype

- [ ] `.lua`: inside `require('gen`: lazydev offers module names first.
- [ ] Any file: `./` then a few letters: file names (path source).
- [ ] A file without a language server (e.g. `.ini`): words from the buffer.
- [ ] `.md` / `.txt`: type `Hou`: English words (`Hour`, `House` …), capitalised; at most 20.
- [ ] `.gitignore`: type `pl`: dirs of that folder (`plug-wip/`); after `plug-wip/` the next level.
- [ ] `~/.ssh/config`: at line start `Str`: `StrictHostKeyChecking`; after it and a space the menu
      opens by itself with `yes`, `accept-new`, …; `Ciphers ` lists what `ssh -Q cipher` reports.
- [ ] `hmac-sha2-256@openssh.com` style values (after `MACs `): accepting replaces the whole value,
      not just the part after `@` or `-`.

## 5. Commit message (genja-commit)

- [ ] Oil, stage a file, `ggc`: the commit popup; completion menu works; `<C-CR>` / `<M-CR>` / `<C-s>`
      still commit; `<CR>` with the menu open accepts, with it closed makes a newline.
- [ ] In a repo with Conventional Commits on (`git config --local genja-commit.conventional true`):
      line 1 `fe` → `feat`; `feat(` → scopes from `git log`; line 3+ → `BREAKING CHANGE:` etc.
- [ ] With it off: no types offered, only buffer words.

## 6. Command line

- [ ] `:ech`: the menu opens by itself; `<Tab>` / `<S-Tab>` walk it.
- [ ] `<C-j>` / `<C-k>` walk it while open.
- [ ] `<Down>` / `<Up>`: the menu closes and history is recalled.
- [ ] `:e lua/ge<Tab>`: file names; `:h nvim_buf<Tab>`: help tags.
- [ ] `/` then a few letters: words from the buffer.
- [ ] `:!` and `:w ` don't hang (shell completion on Windows can be slow).

## 7. Places where completion should stay out

- [ ] Ask popup (`<M-?>`): no completion menu; `<C-s>` sends.
- [ ] Telescope prompts: no blink menu.
- [ ] Oil buffers, terminal (`:ClaudeFterm`): no menu.

## 8. Others

- [ ] Copilot ghost text in a gitcommit buffer: `<M-f>` accepts, `<Tab>` still goes to blink.
- [ ] Laravel project only: `.blade.php`, type `<x-`: component names (blade-nav source).
- [ ] Speed: a big file (e.g. `lua/genja/vimrc.almalinux.vim`) — typing doesn't lag.

## Notes

Write what's off here, one line each, with the file and what you typed.
