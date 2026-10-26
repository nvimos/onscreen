" Frameless only when the window is screen-sized; set the threshold to `:echo &lines` of a full-size window.
" Deferred: nvim-qt may still be restoring its geometry when ginit.vim runs.
let g:ginit_frameless_lines = get(g:, 'ginit_frameless_lines', 33)
if exists('*GuiWindowFrameless')
	call timer_start(100, {-> &lines >= g:ginit_frameless_lines ? GuiWindowFrameless(1) : 0})
endif
