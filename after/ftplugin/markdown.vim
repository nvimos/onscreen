lua << EOF
-- <F2> tasks:
local buf = vim.api.nvim_get_current_buf()
require('genja.ext.md-checklist').register(buf)
require('genja.ext.md-glow').register(buf)
require('genja.ext.md-fix').register(buf)
require('genja.ext.md-abbrev').apply(buf)
EOF

" :map has no desc; which-key shows the rhs instead
nnoremap <buffer> <leader>mfx <Cmd>call v:lua.require'genja.ext.md-fix'.fix(bufnr(), v:true)<CR>

" j/k move by screen line through wrapped text; with a count (5j, relative numbers) by real line
nnoremap <buffer> <expr> j v:count ? 'j' : 'gj'
nnoremap <buffer> <expr> k v:count ? 'k' : 'gk'
xnoremap <buffer> <expr> j v:count ? 'j' : 'gj'
xnoremap <buffer> <expr> k v:count ? 'k' : 'gk'
noremap <buffer> <Down> gj
noremap <buffer> <Up> gk

" Soft limit: lines wrap on screen, gq formats to 120; typing never hard-wraps.
setlocal textwidth=120
setlocal formatoptions-=t formatoptions-=c formatoptions+=n formatoptions+=q
setlocal colorcolumn=+1
setlocal wrap linebreak
" wrapped list items line up under the item text
setlocal breakindent breakindentopt=list:-1

" Spaces, 2 per level: markdownlint MD007 (list indent 2) and MD010 (no hard tabs);
" tabstop 4 is the CommonMark tab width, for files that do contain tabs.
setlocal expandtab shiftwidth=2 softtabstop=2 tabstop=4

setlocal conceallevel=1
setlocal showbreak=NONE
setlocal nospell
" no listchars in markdown
setlocal nolist
