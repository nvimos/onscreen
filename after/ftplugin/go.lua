-- iferr: expands to an `if err != nil` block returning err
vim.keymap.set('ia', 'iferr:', [[if err != nil {<cr>return err<cr>}<cr><esc>kk==]], { buffer = true, desc = 'Go: if err block' })
