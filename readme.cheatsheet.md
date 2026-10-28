Always forget

    win pane to new tab     <c-w>T
    send split to a new tab <c-w>T

Paste (lua/genja/map-zero.lua)

    <S-Insert>  clipboard ("+) in insert, cmdline and terminal mode

Terminal cursor (lua/genja/ext/term.lua)

    :TermCursorShape block | bar   steady cursor in the StatusLine orange while typing in a terminal

Indent text objects (vim-indent-object, loads on VeryLazy)

    ii  lines at the same indent              vii  cii  dii  yii
    ai  same, plus the line above             vai  cai  dai
    aI  same, plus the lines above and below  vaI  caI  daI
    repeat in visual mode to grow the selection

Breadcrumbs and outline (dropbar, aerial)

    <leader>;   pick a crumb, open its menu     [;  ];   context start / next context
    <leader>mo  outline sidebar                  <leader>mO  outline nav float (<Esc> closes)
    <leader>oo  outline sidebar                  <leader>oO  outline nav float (same as mo / mO)
    <leader>ja  telescope symbols (aerial)       [o  ]o   previous / next symbol

Zen mode (zen-mode.nvim, lua/genja/map-plugin/zenmode.lua)

    <leader>mz  toggle zen mode (spec defaults)
    <leader>z1  zen, width 120, no numbers, diag limit 2
    <leader>z2  zen, width 80, relnum, colorcolumn 4,8,80, maximized
    <leader>z0  close zen, framed again, window size and diag limit as before z1/z2
    z1 <-> z2 while zen is open: reopens with the new width

Split padding (plug-wip/genja-splitpad.nvim)

    <leader>tp  toggle padding column in unfocused splits   :SplitPadToggle

URLs (urlview.nvim, lua/genja/map-plugin/urlview.lua)

    gx (visual)  pick URLs in the selected lines: <Tab> marks, <CR> opens marked (or current)
    gx (normal)  built-in: open URL under cursor
    <leader>gx   same picker, all URLs in the buffer      [u  ]u   previous / next URL
    :UrlView buffer | lazy

Floaterm commands (lua/genja/auto-alias.vim; :ClaudeFterm from plug-wip/genja-claudefterm.nvim)

    :LazygitFterm  :BashFterm  :PythonFterm  :RangerFterm  :ClaudeFterm
    :ClaudeFterm --chrome   flags at start, <Tab> completes: --model --effort
                            --permission-mode --add-dir --ide --verbose --no-chrome
    in the claude terminal (plug-wip/genja-claudefterm.nvim):
    <C-Left>  window on the left    <C-Right>  next tab    <C-Up>  normal mode
    one claude per project root (marker cwd, git root, else :pwd), named claude-<root>
    :ClaudeFterm!  <leader>mC   running claude terminals: <CR> show, <M-d> kill; also in <F2> (group claude)
    :ClaudeFtermMarkerToggle    session marker off (enabled:false, start new sessions) or on (resume)
    <leader>pc  ask popup, same as <M-?>     <leader>pC  paste @file / selection (plugin/claude-fterm.lua)

Ask popup (plug-wip/genja-ask.nvim; <M-?> in plugin/ask.lua, n/i/x; visual sends the selection)

    <C-CR>/<M-CR>/<C-s> send   <M-p> send to the claudefterm (any target)   <S-CR>/<C-j> newline   <C-p>/<C-n> history   <C-b> brief
    <M-t> target: claude-p, claudefterm, gemini, copilot, aichat   <M-m> model   <M-e> effort
    <M-s> save session (nvim yyyy.ww.d-ddd.hhmm)   <M-r> resume a saved one   <C-c> cancel
    answer: <CR> follow-up   y yank   q/<Esc> close     log: ~/.claude/p-logs/nvim.log
    <M-[>     previous tab          <M-]>      next tab
    <M-{>     previous window, like <C-q> (typed as Alt+Shift+[)

Code actions by kind (map-lsp.lua; visual mode sends the selection)

    <leader>ca  all              <leader>cq  quickfix
    <leader>ce  extract (select first: statements, or one expression)
    <leader>cr  rewrite: fill struct/switch, invert if, split/join lines
    <leader>cs  source: organize imports, doc, add test
    <leader>cl  run the code lens on this line (Go: run test, go.mod tidy/upgrade)
    Go saves run organize imports + format; :let b:go_format_on_save = v:false

LSP rename (grn, <leader>c2; lua/genja/ext/rename-inline.lua): float over the word, in insert mode

    <CR>  rename   <C-j>  accept completion   <Esc>  normal mode, then <Esc>/q cancel   <C-c>  cancel

Telescope picker keys (map-telescope.lua, telescope-after.lua; insert and normal mode)

    <Tab>  <S-Tab>  mark entries      <C-/> (insert)  ? (normal)  list the picker's keys
    <M-l>  marked -> loclist    <M-q>  marked -> quickfix
    <M-L>  append marked        <M-Q>  append marked
    <C-l>  all -> loclist       <C-q>  all -> quickfix

Mouse (lua/genja/ext/popup-menu.lua, lua/genja/ext/morning.lua, genja-statusline clicks in lua/lazyp/new/genja-statusline.lua)

    right-click   markdown: toggle checkbox, open link, F2 menu   oil: git add, open in tab
                  LSP buffers: code action, rename, references     everywhere: Morning   nvim-qt: frameless
    statusline    click file name -> oil   branch -> Neogit   E/W counts -> location list
    :Morning      start dirs, recent files, todo items, untested lines; click or <CR> opens,
                  q closes, R rebuilds

Live grep / find (plug-wip/genja-finder.nvim/lua/genja-finder/scope.lua; <F1> <S-F1> <leader>jj)

    <M-r>  cycle root (pwd, .git, bufdir, home)   <M-Up>  parent dir, one-off   <M-i>  skip set
    <F1>   grep <-> find   <M-c>  command   <C-p>  preview   <M-f>  filter   <BS>  undo filter

Recent files (plug-wip/genja-recent.nvim, picker lua/genja/ext/recent.lua, key in map-telescope.lua)

    <C-F1>   recent files of this project (git root, else :pwd), frecency order
    <M-a>    in the picker: this project / all files     <leader>jo  telescope oldfiles

Telescope keymaps (lua/genja/ext/telescope-keymaps.lua, keys in map-telescope.lua)

    <leader>jM  <leader>jbk  <leader>jb?   open it
    <M-r>  <M-R>   next / previous desc group (Git:, LSP:, Fold: ...), then all again
    <M-f> filter   <M-x> exclude   <M-n> fuzzy/exact   <BS> on empty prompt: undo

Command-line completion (plug-wip/genja-completion011.nvim/lua/genja/completion/cmdline.lua; : / ?)

    <Tab>   next item (opens the menu)    <S-Tab>  previous item (opens the menu)
    <C-j>   next item                     <C-k>    previous item
    <Down>  next item; no menu: history   <Up>     previous item; no menu: history
    <M-x>   close the menu (as <C-e>)

Copilot (lua/genja/map-plugin/copilot.lua; first run :Copilot setup)

    starts disabled to save credits: <leader>at or :Copilot enable
    insert:  <M-f>  accept           <M-w>  accept word     <M-j>  accept line
             <M-]>  next             <M-[>  previous        <C-]>  dismiss
             <M-\>  suggest now      (<Tab> stays with blink)
    normal:  <leader>ap  panel (10 suggestions)   <leader>at  toggle   <leader>as  status
    :Copilot setup | status | enable | disable | panel | signout

Git (lua/lazyp/git/, keys in lua/genja/map-plugin/neogit|diffview|gitsigns|mini-git.lua)

    <leader>mg  Neogit status       <leader>mGl Neogit log
    <leader>md  diffview: changes   <leader>mh  file history   <leader>mH  repo history
    <leader>mxd close diffview
    <leader>mGc commit popup (genja-commit; in oil also ggc, <LocalLeader>c)
    <leader>mGs git signs on/off in this buffer (markdown starts off: vim.g.gitsigns_skip_ft)
    hunks, only in buffers gitsigns tracks:
    ]c  [c      next / previous hunk (in diff mode: nvim's change jumps)
    <leader>hs  stage/unstage hunk (visual: lines)   <leader>hS  stage buffer
    <leader>hr  reset hunk (visual: lines)           <leader>hR  reset buffer
    <leader>hp  preview float    <leader>hi  preview inline   ih  hunk text object
    <leader>hb  blame line       <leader>hB  toggle line blame   <leader>hw  word diff
    <leader>hd  diff vs index    <leader>hD  diff vs last commit
    <leader>hq  buffer hunks -> quickfix   <leader>hQ  repo hunks -> quickfix
    <leader>hc  commit at cursor, visual: log of the lines (mini.git)
    :Git <args>  mini.git, output in a split (fugitive is off)

Fold markers with a title (lua/genja/ext/wrapfold.lua, keys in lua/genja/map-zero.lua)

    zf (visual)        ask a title, wrap selection in  -- {{{ title  /  -- }}}   empty title: built-in zf
    <leader>wwf        same for the paragraph under the cursor (visual: the selection)
    :[range]WrapFold [title]   same as a command; no title asks

Wrap and quote lines (lua/genja/map-convoluted.lua)

    <leader>w, (visual)  each line -> "line",  keeps indent, skips empty lines, any visual mode
    <leader>w" (visual)  same idea via $A / I, block selection
    <leader>w" (normal)  replace " with ' on the current line

Action menu on right-click (lua/genja/fn.vim, menu from lua/genja/ext/actions.lua)

    right-click > Actions (g.)   same menu as g. / <LocalLeader>/
    in telescope: click selects an entry, double-click runs it (mouse=a)

Toggle and increment (lua/genja/ext/tilde.lua in map-zero.lua; dial: lua/genja/map-plugin/dial.lua)

    ~          swap word under cursor: true/false on/off yes/no enable(d)/disable(d) and/or 0/1
               left/right up/down min/max first/last; chars + -  < >; case kept; else plain ~
    <M-~>      plain ~ (case)
    <C-a> <C-x>      dial: numbers, hex, dates, times, semver, weekdays, months, &&/||, bool
                     lua ==/~=, ts let/const, php visibility, css hex colors, md headers and [ ]/[x]
    g<C-a> g<C-x>    same; in visual: progressive (1, 2, 3 …); dot repeats

F2 in markdown (lua/genja/ext/md-checklist.lua, lua/genja/ext/md-glow.lua, from after/ftplugin/markdown.vim; visual <F2> in map-telescope.lua)

    <F2> > markdown: checklist toggle   add `[ ]` to the cursor line; visual <F2>: to the selected lines
                                 all lines boxed already: removes the boxes
    <F2> > markdown: glow preview  glow on the file in a new pwsh window, any key closes (Windows only)
    <leader>mfx  fix the file: typos --write-changes, markdownlint-cli2 --fix (also on :w; off: vim.g.md_fix_on_save = false)
    insert mode: abbreviations from lua/genja/ext/md-abbrev.txt (teh -> the …)

    j k          screen line through wrapped text; with a count, real line (after/ftplugin/markdown.vim)
    gq           format to 120 columns (textwidth); typing doesn't hard-wrap
    insert mode: abbreviations from lua/genja/ext/md-abbrev.txt (teh -> the …)

F2 in oil, git add picker (lua/genja/f2/collect/git.lua)

    <CR>    git add (marked or current), closes    <M-a>   git add current, stays; row shows the new status
    <Tab>   mark    <C-p> preview    <M-t> tabedit, stays    <M-e> edit

F2 in oil, git staged picker (same file): `git diff --cached` preview, same keys except

    <CR>    unstage (git restore --staged; marked or current), closes    no <M-a>

nvim-qt GUI toggles (neovim-gui-shim, keys in lua/genja/map-plugin/neovim-gui-shim.lua)

    <leader>mQt  tabline           <leader>mQb  tabline buffers    <leader>mQp  popupmenu
    <leader>mQs  scrollbar         <leader>mQe  treeview           <leader>mQl  ligatures
    <leader>mQa  bold/italic       <leader>mQc  adaptive color     <leader>mQf  adaptive font
    <leader>mQF  fullscreen        <leader>mQm  maximized          <leader>mQw  frameless
    <leader>mQh  mouse hide

nvim-qt GuiFuncs picker (<F3> mylunsj > GuiFuncs, or <F2> group gui in a GUI; lua/telescope/_extensions/mylunsj/gui-funcs/)

    <CR>         flip on/off, next style (list from :GuiAdaptiveStyleList), next number (wraps); GuiFont opens the font dialog; stays open
    state shared with <leader>mQ and right-click (lua/genja/ui/gui-func-state.lua); linespace 0-5, opacity 0-1 by 0.05
    <M-0> <M-1>  set GuiLinespace / GuiWindowOpacity to 0 or 1

Window sizes (lua/genja/ext/winsize.lua, keys in lua/genja/map-zero.lua)

    <M-=> <M-->   grow / shrink the window along its split (10% of the screen; <leader>Ws: 8 cols / 4 lines)
    <M-0>         cycle the split share: 50/50 30/70 70/30 60/40 (left/top window; 3+ windows: current)
    <leader>wr    resize mode (which-key loop): h j k l  narrower lower taller wider, = equal, 0 share, s step, <Esc> leaves
    smart-splits.nvim (disabled spec lua/lazyp/new/smart-splits.lua): <M-h/j/k/l>, <leader>wR

Start dirs (plug-wip/genja-startdirs.nvim, keys in lua/genja/map-plugin/genja-startdirs.lua, oil in lua/genja/map-oil.lua)

    <leader>sp  <leader>jD  <S-F3>   picker, most used first; <CR> cd + open; also :Mydirs
    :Mydirs reset                    delete the usage counts (stdpath('data')/startdirs.usage)
    <leader>sa  <leader>jA           add the current dir (oil dir, file's dir, else cwd) under [added]
    <leader>sr                       remove the current dir
    <leader>se  <leader>je           edit the list (lua/genja/local/startdirs.txt), :StartdirsEdit
    <M-1> ... <M-4>                  cd + open the four most used entries
    ,s  ,S  (oil)                    add / remove the dir under the cursor (else oil's dir), [oil] group
    <leader>jd                       find files in all start dirs
    removed: <leader>sp sort paragraph, <leader>sf guifont (use <F7>)

Diagnostics limit (lua/genja/ext/diag-limit.lua, key in plugin/diag-limit.lua)

    <leader>tt3  first 3 per severity drawn (virtual text, signs, underline) / all; default on
    <F2>         diagnostics: show all (N hidden), this buffer only
    vim.g.diag_limit = n   b:diag_limit = n   (0: all; zen <leader>z1 sets 2)

Messages (lua/genja/ext/messages.lua, command in plugin/messages.lua)

    :Messages / :Messages -dump   :messages in a scratch buffer; <CR> opens file:line, q closes
    :Messages -quick              append the file:line locations to the quickfix list
    :Messages -loc                append them to this window's location list
    <F2> > messages: <file>:<n>   newest 10 locations from :messages

Languages on the fly (plug-wip/genja-completion011.nvim, lua/genja/lsp/init.lua; F2 item in lua/genja/f2/collect/lang.lua)

    :EnableLang [-on] <lang>      turn a language on, this session only (-on is the default)
    :EnableLang -off <lang>       turn it off: servers stop unless another language uses them
    :EnableLang -save <lang>      also save it in lua/genja/lsp/local.lua (with -off: saved as false)
    <F2> > lsp: EnableLang <lang>   when the buffer's filetype belongs to an off language
