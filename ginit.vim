" Config for nvim-qt

" enable mouse in all modes
set mouse=a

" " Set Editor Font
" if exists(':GuiFont')
" 	" Use GuiFont! to ignore font errors
" 	GuiFont {font_name}:h{size}
" endif

if exists('*GuiWindowFrameless')  | call GuiWindowFrameless(0)  | endif
if exists(':GuiTabline')          | execute 'GuiTabline 0'      | endif
if exists('*GuiWindowMaximized')  | call GuiWindowMaximized(0)  | endif
if exists('*GuiWindowFullScreen') | call GuiWindowFullScreen(0) | endif
if exists('*GuiMousehide')        | call GuiMousehide(1)        | endif


" Gui* commands lack -bar: without execute, '| endif' becomes part of the argument
if exists(':GuiAdaptiveColor')   | execute 'GuiAdaptiveColor 1'      | endif " widgets follow colorscheme
if exists(':GuiAdaptiveFont')    | execute 'GuiAdaptiveFont 0'       | endif " widgets use GuiFont
if exists(':GuiLinespace')       | execute 'GuiLinespace 0'          | endif
if exists(':GuiPopupmenu')       | execute 'GuiPopupmenu 0'          | endif " Disable GUI Popupmenu
if exists(':GuiRenderFontAttr')  | execute 'GuiRenderFontAttr 1'     | endif " bold, italic
if exists(':GuiRenderLigatures') | execute 'GuiRenderLigatures 0'    | endif
if exists(':GuiScrollBar')       | execute 'GuiScrollBar 0'          | endif " Enable GUI ScrollBar
if exists(':GuiTablineBuffers')  | execute 'GuiTablineBuffers 0'     | endif " tabs, not buffers
if exists(':GuiWindowOpacity')   | execute 'GuiWindowOpacity 1.0'    | endif
if exists(':GuiAdaptiveStyle')   | execute 'GuiAdaptiveStyle Fusion' | endif " Qt style, see :GuiAdaptiveStyleList

" " Right Click Context Menu (Copy-Cut-Paste)
" nnoremap <silent><RightMouse> :call GuiShowContextMenu()<CR>
" inoremap <silent><RightMouse> <Esc>:call GuiShowContextMenu()<CR>
" xnoremap <silent><RightMouse> :call GuiShowContextMenu()<CR>gv
" snoremap <silent><RightMouse> <C-G>:call GuiShowContextMenu()<CR>gv
"claude-session: 76dc1051-17df-4cf7-b97d-75c551affb4e guifuncz
