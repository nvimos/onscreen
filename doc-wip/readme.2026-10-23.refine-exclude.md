# Telescope refine: `<M-x>` exclude (idea 25)

Docs live in the plugin: `plug-wip/genja-finder.nvim/README.md` (key table)
and `doc/genja-finder.txt` (`<M-x>`). Code: `refine.lua` `M.exclude`.

## Short

- Type words, `<M-x>`: entries containing any of them are dropped
  (smartcase), the prompt clears, the prefix shows `!word > `.
- `<BS>` on an empty prompt undoes it, like `<M-f>`.
- Works in every picker with the shared keys (`<C-F1>` oldfiles, f2,
  ui-select, …). Live grep/find: press `<M-f>` first (no fixed list before).

## Test

1. `<C-F1>` (oldfiles), type `.md`, `<M-x>`: no markdown files left,
   prefix `!.md > `.
2. Type `lua`: fuzzy-filters what's left. `<M-x>` again: stacks `!lua > `.
3. `<BS>` on an empty prompt twice: back step by step to the full list.
4. `Test` with a capital: only `Test…` matches are dropped (smartcase).
5. `<F1>` live grep, type something, `<M-x>`: notice "press <M-f> first";
   `<M-f>`, then type a word, `<M-x>`: works.
