# Ask popup: `<M-p>` sends to the claude floaterm (idea 19)

`<leader>pC` / `<M-?>` open the ask popup (`lua/genja/ask.lua`). Its default
target is claude-p, so pasting into the running claude terminal needed
`<M-t>` first. `<M-p>` sends there directly, whatever target is picked.

## Keys

- `<M-p>` (compose, insert or normal): send the text, plus the visual selection
  the popup was opened with, to this project's claude floaterm and submit it.
  The popup closes; the answer shows in the terminal. The picked target stays.
- `<C-CR>`: unchanged, sends to the picked target.
- `<leader>pc`: unchanged, pastes `@file` / `path:lines` + code into the terminal
  without submitting.

## Test

1. Open a file in a git repo, `:ClaudeFterm`, wait for claude, `<C-q>` back.
2. `<leader>pC`, type `say hi`, `<M-p>`: the popup closes, claude gets `say hi`.
3. Select a few lines, `<M-?>`, type `explain`, `<M-p>`: claude gets the code and the question.
4. Without a running claude: `<M-p>` starts it in the project root and sends once it's ready.
5. `<leader>pC` again: the footer shows `<M-p> to floaterm`, the title still shows claude-p.
6. `<leader>pc` in normal and visual mode: `@file` / the selection lands in claude, not submitted.
