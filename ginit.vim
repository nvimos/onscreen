" Config for nvim-qt
" vim: fdm=marker

" Dark title bar in Win11 {{{
"                 Windows draws the titlebar, not Qt
"                 cannot be set here or in a .qss.
"
" Windows settings -> use Dark mode
" Stylesheet is for tabline, etc
"
"        nvim-qt.exe -platform windows:darkmode=1
"                    -stylesheet %LOCALAPPDATA%\nvim\nvim-qt.qss
"
" alternatively, for all qt apps:
"
"                setx QT_QPA_PLATFORM windows:darkmode=1
"                     darkmode=2 also makes Qt widgets dark.
"
" lnk {{{
"      "C:\Program Files\neovim-qt 0.2.19\bin\nvim-qt.exe" -platform windows:darkmode=1 -stylesheet "%LOCALAPPDATA%\nvim\nvim-qt.qss"
" }}}
" }}}

" enable mouse in all modes
set mouse=a

" Set font
"if exists(':GuiFont') | call GuiFont("JetBrainsMono NFM:h12") | endif
"if exists(':GuiFont') | silent! call GuiFont("JetBrainsMonoNL NFM Thin:h12") | endif

if exists('*GuiWindowFrameless')  | call GuiWindowFrameless(0)  | endif
if exists(':GuiTabline')          | execute 'GuiTabline 0'      | endif
"if exists('*GuiWindowMaximized')  | call GuiWindowMaximized(0)  | endif
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
