Partly, yes. Staging from oil was cheap and fits how you browse. A diff 
preview with jump-to-line and a commit popup with its own key handling is 
rebuilding what fugitive, lazygit and neogit already do, and you already have 
two of those:

- **fugitive** (`lua/lazyp/git/fugitive.lua`): in the `:Git` status window, 
  `s` stages, `u` unstages, `=` shows an inline diff, `<CR>` opens the file, 
  `dv` gives a split diff, and `cc` opens a commit message buffer. Leaving the 
  message empty aborts the commit.
- **lazygit** (`:LazygitFterm`): the same features in a floating terminal.

What the custom version costs:
- **Diff preview with jump to line:** the most expensive part. It means 
  parsing hunks, mapping a diff line back to a file line, and handling new, 
  deleted, binary and renamed files. It would also depend on oil's preview 
  internals, which have already surprised us with the re-sort and #762.
- **Commit popup:** cheap, around 60 lines. But `<C-CR>` only reaches nvim if 
  your terminal sends it as its own key. Windows Terminal may send a plain 
  Enter, so it needs testing first.
- **Upkeep:** every oil update can break these, and each one is another thing 
  you'll debug on Windows.

A middle ground that gets most of the value:
1. Keep the oil staging keys (`gga`, `ggr`, `,a`, `,r`) and the jump to the 
   next unstaged file. They're done and small.
2. Make `ggc` / `,c` in oil open fugitive's commit buffer (`:Git commit`) 
   instead of a custom popup. `:wq` commits and an empty message aborts, built 
   in.
3. Get your "Update {{filename}}" idea from a small 
   `after/ftplugin/gitcommit.lua` that pre-fills the message from the staged 
   files: summary `Update <file>`, a blank line, then the other files in the 
   body. That's about 20 lines and works however you commit.
4. For diffs, use fugitive's `:Gdiffsplit` on the file, or gitsigns preview 
   once #9 is done, instead of a custom oil preview.

If you'd still prefer everything inside oil, build the commit popup first, 
since it's cheap, and skip or postpone the diff preview, which is the main 
cost.

Ask in the main conversation to have any of this built.
