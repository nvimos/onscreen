"	https://coolors.co/palettes/trending/orange
"
"	cterm={attr-list}			*attr-list* *highlight-cterm* *E418*
"		attr-list is a comma-separated list (without spaces) of the
"		following items (in any order):
"			bold
"			underline
"			undercurl	curly underline
"			underdouble	double underline
"			underdotted	dotted underline
"			underdashed	dashed underline
"			strikethrough
"			reverse
"			inverse		same as reverse
"			italic
"			standout
"			altfont
"			nocombine	override attributes instead of combining them
"			NONE		no attributes used (used to reset it)

" Heñaral
hi VertSplit  cterm=NONE ctermbg=235 guibg=#111115
hi Split      cterm=NONE ctermbg=235 guibg=#111115

hi Search     guifg=orange guibg=#441111
hi IncSearch  guifg=orange guibg=#441111
hi CurSearch  guifg=cyan   guibg=#441111
hi MatchParen guifg=orange guibg=NONE
hi MatchParen guisp=orange gui=bold,standout,underline
hi Visual     guifg=orange guibg=#332277 gui=bold

" Dashboard

hi DashboardHeader       ctermfg=Yellow guifg=#4793AF
hi DashboardFooter       ctermfg=Yellow guifg=#FFC470
hi DashboardShortCut     ctermfg=Yellow guifg=#FFC470
hi DashboardShortCutIcon ctermfg=Yellow guifg=#FFC470
hi DashboardFiles        ctermfg=Yellow guifg=#4793AF
hi DashboardDesc         ctermfg=Yellow guifg=#FFC470
hi DashboardKey          ctermfg=Yellow guifg=#FFC470

" tabline, statusline

hi TablineFill guibg=#161616
hi TablineSel  gui=none
hi TablineSel  guifg=#AF4805
hi TablineSel  guibg=#0e0707
hi Tabline     gui=none
hi Tabline     guifg=#656565
hi Tabline     guibg=#161616

hi StatusLine     gui=bold
hi StatusLine     gui=none
hi StatusLine     gui=none
hi StatusLine     guibg=#161616
hi StatusLine     guifg=#AF4805
"hi StatusLine    guifg=#fb8500
"hi StatusLine    guifg=#FF6500
hi StatusLineWeak guifg=#383838
hi StatusLineWeak guibg=#161616
" not current?
hi StatusLineNC   gui=NONE
hi StatusLineNC   guibg=#141414
hi StatusLineNC   guifg=#ED9455
"hi StatusLine   cterm=NONE ctermbg=black ctermfg=orange
"hi StatusLineNC cterm=NONE ctermbg=black ctermfg=orange

" spellink

hi SpellBad guisp=#3C1616
hi SpellBad guifg=#A34343
hi SpellBad gui=underline


" messagink

hi ErrorMsg guifg=#ff99c8
hi ErrorMsg guibg=NONE
hi ErrorMsg gui=bold


" OilDir -> Directory

hi Directory guifg=#ffd76a
hi Directory guifg=#ffe9a9
hi Directory guifg=#ffe087

