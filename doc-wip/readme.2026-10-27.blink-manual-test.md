# blink.cmp: manual test guide

Automated (`make test D=completion` and `make test D=comps011 G=cmp` in `tests/`):
which items each source gives (path, buffer, lazydev, dictionary, gitignore, sshconfig,
gitcommit, LSP), the keys (`<CR>`, `<Tab>`, `<S-Tab>`, `<F2>`/`<F3>`, `<C-k>`, snippet
jumps), the command line (`:` commands, files, help, `/`, `<C-j>`/`<C-k>`, `<Down>`),
the matcher, the setup values, and where completion is off (prompt buffers, ask popup).

Left for you: how it looks and feels in a real window. One step at a time.
Back to nvim-cmp: `git checkout before-blink-2026-w44 -- plug-wip/genja-completion011.nvim lua/lazyp`.

## 1. Start

- [ ] Restart nvim-qt: no error messages.
- [ ] `:checkhealth blink.cmp`: no errors.
- [ ] `:Lazy clean` removes nvim-cmp, cmp-buffer, cmp-cmdline, cmp-nvim-lsp, cmp-path, lspkind.

## 2. Look (nvim-qt, then a terminal nvim)

- [ ] Menu colours (StatusLine background), selected row readable.
- [ ] Kind icons render.
- [ ] Documentation window next to the menu for an LSP item (a `.lua` file, `vim.ap`).
- [ ] Long labels don't push the menu off screen.

## 3. Feel while typing

- [ ] The menu opening on every keystroke isn't in the way (prose in markdown, code in lua).
- [ ] `<CR>` taking the first item doesn't eat newlines you meant to type.
      If it does: uncomment the `config.completion.list` line in `keymaps.lua`.
- [ ] jolemak `<C-e>` closes the menu.
- [ ] Snippet from lua_ls (accept `vim.api.nvim_buf_get_lines`): fields as placeholders, `<Tab>` jumps.
- [ ] A big file (`lua/genja/vimrc.almalinux.vim`): no lag.

## 4. Commit popup (oil, stage a file, `ggc`)

- [ ] Menu works; `<C-CR>` / `<M-CR>` / `<C-s>` commit; `<CR>` with the menu closed is a newline.

## 5. Command line

- [ ] `:` menu look and `<Tab>` feel; `:!` and `:w ` don't hang.

## 6. Others

- [ ] Copilot ghost text in a gitcommit buffer: `<M-f>` accepts, `<Tab>` still goes to blink.
- [ ] Laravel project only: `.blade.php`, `<x-` → component names (blade-nav).

## Notes

What's off, one line each: file, what you typed, what happened.
