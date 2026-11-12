" vim: fdm=marker 
"	https://coolors.co/palettes/trending/orange

" {{{ primer
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
" }}}

" Heñaral
hi VertSplit  cterm=NONE ctermbg=235 guibg=#111115
hi Split      cterm=NONE ctermbg=235 guibg=#111115

hi Search     guifg=orange guibg=#330B08
hi IncSearch  guifg=orange guibg=#330B08
hi CurSearch  guifg=cyan   guibg=#330B08


" Darkened by 20%: #360e0e
" Darkened by 30%: #300c0c
" Darkened by 40%: #330B08




hi MatchParen guifg=orange guibg=NONE
hi MatchParen guisp=orange gui=bold,standout,underline
hi Visual     guifg=#111111 guibg=#eb831e gui=bold


hi Folded     guifg=#a38652 guibg=#141409
hi FoldColumn guifg=#493423
hi! link CursorLineFold FoldColumn

" Markdown headings, pale indigo. Fallback: lua/genja/hilite.lua (markdown_headings) sets the same
" and re-applies it on ColorScheme. Only markdown's own groups: the syntax ones and the .markdown captures.
"hi MdHeading guifg=#a5b4fc gui=bold " pale indigo, to go back to
hi MdHeading guifg=#AF4805 gui=bold
" Markdown <!-- --> comments: gray, no background; the markdown windows use it through winhighlight
" (after/ftplugin/markdown.lua), same color as M.markdown_comment in lua/genja/hilite.lua.
hi MdComment guifg=#6a717a
" Markdown inline `code`: the StatusLine orange (M.markdown_code in lua/genja/hilite.lua follows StatusLine).
hi @markup.raw.markdown_inline guifg=#AF4805
hi markdownCode guifg=#AF4805
hi! link markdownHeadingDelimiter MdHeading

hi! link markdownH1 MdHeading
hi! link markdownH2 MdHeading
hi! link markdownH3 MdHeading
hi! link markdownH4 MdHeading
hi! link markdownH5 MdHeading
hi! link markdownH6 MdHeading
hi! link @markup.heading.1.markdown MdHeading
hi! link @markup.heading.2.markdown MdHeading
hi! link @markup.heading.3.markdown MdHeading
hi! link @markup.heading.4.markdown MdHeading
hi! link @markup.heading.5.markdown MdHeading
hi! link @markup.heading.6.markdown MdHeading
hi! link @markup.heading.1.marker.markdown MdHeading
hi! link @markup.heading.2.marker.markdown MdHeading
hi! link @markup.heading.3.marker.markdown MdHeading
hi! link @markup.heading.4.marker.markdown MdHeading
hi! link @markup.heading.5.marker.markdown MdHeading
hi! link @markup.heading.6.marker.markdown MdHeading

" Dash-eboard
hi DashboardHeader       ctermfg=Yellow guifg=#4793AF
hi DashboardFooter       ctermfg=Yellow guifg=#FFC470
hi DashboardShortCut     ctermfg=Yellow guifg=#FFC470
hi DashboardShortCutIcon ctermfg=Yellow guifg=#FFC470
hi DashboardFiles        ctermfg=Yellow guifg=#4793AF
hi DashboardDesc         ctermfg=Yellow guifg=#FFC470
hi DashboardKey          ctermfg=Yellow guifg=#FFC470

" Tabolino, eStatuslino, Winebar
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
hi WinBarModified guibg=#010101
hi WinBarModified guifg=#fb8500
hi WinBarPath     guibg=#010101
hi WinBarPath     guibg=#0E0707
hi WinBarPath     guifg=#363636
hi WinBarPath     guifg=#545454

" Spellink
hi SpellBad guisp=#3C1616
hi SpellBad guifg=#A34343
hi SpellBad gui=underline

" Messagink
hi ErrorMsg guifg=#ff99c8
hi ErrorMsg guibg=NONE
hi ErrorMsg gui=bold

" Diagnosticz {{{


hi DiagnosticError guifg=#b844b0 ctermfg=1 gui=NONE
hi DiagnosticWarn  guifg=#7e4c6c ctermfg=3 gui=NONE
hi DiagnosticInfo  guifg=#6a5864 ctermfg=4 guibg=NONE gui=NONE
hi DiagnosticHint  guifg=#969696 ctermfg=7 gui=NONE
hi DiagnosticOk    guifg=#90ee90 ctermfg=10 gui=NONE

hi DiagnosticUnderlineError guisp=#7d3138 gui=underline cterm=underline
hi DiagnosticUnderlineWarn  guisp=#836c4a gui=underline cterm=underline
hi DiagnosticUnderlineInfo  guisp=#553333 gui=underline cterm=underline
hi DiagnosticUnderlineHint  guisp=#707070 gui=underline cterm=underline
hi DiagnosticUnderlineOk    guisp=#90ee90 gui=underline cterm=underline


hi clear DiagnosticVirtualTextError
hi clear DiagnosticVirtualTextWarn
hi clear DiagnosticVirtualTextInfo
hi clear DiagnosticVirtualTextHint
hi DiagnosticVirtualTextError guifg=#E06C75 guibg=#251c1e ctermbg=Black
hi DiagnosticVirtualTextWarn  guifg=#E5C07B guibg=#24221c ctermbg=Black
hi DiagnosticVirtualTextInfo  guifg=#61AFEF guibg=#1c2229 ctermbg=Black
hi DiagnosticVirtualTextHint  guifg=#98C379 guibg=#1c241e ctermbg=Black

hi DiagnosticVirtualTextError guifg=#E06C75 guibg=NONE ctermbg=Black
hi DiagnosticVirtualTextError guifg=#825483 guibg=NONE ctermbg=Black
hi DiagnosticVirtualTextWarn  guifg=#94775c guibg=NONE ctermbg=Black
hi DiagnosticVirtualTextInfo  guifg=#61AFEF guibg=NONE ctermbg=Black
hi DiagnosticVirtualTextHint  guifg=#98C379 guibg=NONE ctermbg=Black

" The diagnostic float (vim.diagnostic.open_float, the jump float) colors each line like the document's virtual text.
hi! link DiagnosticFloatingError DiagnosticVirtualTextError
hi! link DiagnosticFloatingWarn  DiagnosticVirtualTextWarn
hi! link DiagnosticFloatingInfo  DiagnosticVirtualTextInfo
hi! link DiagnosticFloatingHint  DiagnosticVirtualTextHint
hi! link DiagnosticFloatingOk    DiagnosticVirtualTextOk

"" NOWORK. todo fixme: hi @nvim.diagnostic.float guifg=orange

" }}}

hi DiagnosticDeprecated guisp=#ff0000 gui=strikethrough cterm=strikethrough
hi! link DiagnosticUnnecessary Comment


" OilDir -> Directory
hi Directory guifg=#ffd76a
hi Directory guifg=#ffe9a9
hi Directory guifg=#ffe087

" Markdown links: soft blue link, muted grey-blue url so long urls recede.
hi @markup.link     guifg=#61AFEF gui=underline guisp=#4a4a4a ctermfg=75 cterm=underline
hi @markup.link.url guifg=#5c7083 gui=underline guisp=#4a4a4a ctermfg=66 cterm=underline
hi @markup.link.label guifg=#ED9455 ctermfg=209
