# Commit and ask popups: submit keys that work in Windows Terminal

## What it does

`<C-CR>` doesn't reach nvim through Windows Terminal, so the popups couldn't be submitted there.
Both popups now take three keys, in normal and insert mode:

| key      | where it works                                             |
|----------|------------------------------------------------------------|
| `<C-CR>` | nvim-qt and other GUIs                                     |
| `<M-CR>` | Windows Terminal, once Alt+Enter is unbound from fullscreen |
| `<C-s>`  | everywhere                                                 |

- Commit popup (genja-commit): `keys.commit` is now a list, default
  `{ '<C-CR>', '<M-CR>', '<C-s>' }`; the title shows them as `<C-CR>/<M-CR>/<C-s> commit`.
- Ask popup compose window (genja-ask, `<M-?>`, `<leader>pc`): the three keys send; the footer shows
  `<C-s> send`. `<M-s>` still saves the session.
- `<C-s>` is aerial's outline toggle in normal mode elsewhere; inside the popups the popup's key wins.

## Windows Terminal: free Alt+Enter

Settings (Ctrl+,) -> Actions -> "Toggle fullscreen" -> remove `Alt+Enter` (keep `F11`).
Or in `settings.json`, under `"actions"`: `{ "command": "unbound", "keys": "alt+enter" }`.

## Try it

1. In Windows Terminal: oil in a repo with staged changes, `<leader>mGc` (or `ggc` in oil).
2. Type a title, press `<C-s>`: the commit goes through.
3. Again with `<M-CR>` (after unbinding Alt+Enter).
4. `<M-?>`, type a question, `<C-s>`: the answer shows in the float.
5. In nvim-qt, `<C-CR>` still works in both.
