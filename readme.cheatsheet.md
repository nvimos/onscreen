Always forget

    win pane to new tab     <c-w>T
    send split to a new tab <c-w>T

Indent text objects (vim-indent-object, loads on VeryLazy)

    ii  lines at the same indent              vii  cii  dii  yii
    ai  same, plus the line above             vai  cai  dai
    aI  same, plus the lines above and below  vaI  caI  daI
    repeat in visual mode to grow the selection

Breadcrumbs and outline (dropbar, aerial)

    <leader>;   pick a crumb, open its menu     [;  ];   context start / next context
    <leader>mo  outline sidebar                  <leader>mO  outline nav float
    <leader>ja  telescope symbols (aerial)       [o  ]o   previous / next symbol

Split padding (plug-wip/genja-splitpad.nvim)

    <leader>tp  toggle padding column in unfocused splits   :SplitPadToggle

URLs (urlview.nvim, lua/genja/map-plugin/urlview.lua)

    gx (visual)  pick URLs in the selected lines: <Tab> marks, <CR> opens marked (or current)
    gx (normal)  built-in: open URL under cursor
    <leader>gx   same picker, all URLs in the buffer      [u  ]u   previous / next URL
    :UrlView buffer | lazy

Floaterm commands (lua/genja/auto-alias.vim)

    :LazygitFterm  :BashFterm  :PythonFterm  :RangerFterm  :ClaudeFterm
    :ClaudeFterm --chrome   flags at start, <Tab> completes: --model --effort
                            --permission-mode --add-dir --ide --verbose --no-chrome
    in the claude terminal (lua/genja/claude.lua):
    <C-Left>  window on the left    <C-Right>  next tab    <C-Up>  normal mode
    one claude per project root (marker cwd, git root, else :pwd), named claude-<root>
    :ClaudeFterm!  <leader>pt   running claude terminals: <CR> show, <M-d> kill
    <leader>pc  paste @file / selection     <leader>pC  ask popup, same as <M-?> (plugin/claude-fterm.lua)

Ask popup (lua/genja/ask.lua; <M-?> in plugin/ask.lua, n/i/x; visual sends the selection)

    <C-CR> send   <M-p> send to the claude floaterm (any target)   <S-CR>/<C-j> newline   <C-p>/<C-n> history   <C-b> brief
    <M-t> target: claude-p, floaterm, gemini, copilot, aichat   <M-m> model   <M-e> effort
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

Telescope picker keys (map-telescope.lua, telescope-after.lua; insert and normal mode)

    <Tab>  <S-Tab>  mark entries      <C-/> (insert)  ? (normal)  list the picker's keys
    <M-l>  marked -> loclist    <M-q>  marked -> quickfix
    <M-L>  append marked        <M-Q>  append marked
    <C-l>  all -> loclist       <C-q>  all -> quickfix

Mouse (lua/genja/popup-menu.lua, lua/genja/morning.lua, genja-statusline clicks in lua/lazyp/new/genja-statusline.lua)

    right-click   markdown: toggle checkbox, open link, F2 menu   oil: git add, open in tab
                  LSP buffers: code action, rename, references     everywhere: Morning
    statusline    click file name -> oil   branch -> Neogit   E/W counts -> location list
    :Morning      start dirs, recent files, todo items, untested lines; click or <CR> opens,
                  q closes, R rebuilds

Recent files (plug-wip/genja-recent.nvim, picker lua/genja/recent.lua, key in map-telescope.lua)

    <C-F1>   recent files of this project (git root, else :pwd), frecency order
    <M-a>    in the picker: this project / all files     <leader>jo  telescope oldfiles

Telescope keymaps (lua/genja/telescope-keymaps.lua, keys in map-telescope.lua)

    <leader>jM  <leader>jbk  <leader>jb?   open it
    <M-r>  <M-R>   next / previous desc group (Git:, LSP:, Fold: ...), then all again
    <M-f> filter   <M-x> exclude   <M-n> fuzzy/exact   <BS> on empty prompt: undo

Command-line completion (plug-wip/genja-completion011.nvim/lua/genja/completion/cmdline.lua; : / ?)

    <Tab>   next item (opens the menu)    <S-Tab>  previous item (opens the menu)
    <C-j>   next item                     <C-k>    previous item
    <Down>  history next (closes menu)    <Up>     history previous (closes menu)

Copilot (lua/genja/map-plugin/copilot.lua; first run :Copilot setup)

    starts disabled to save credits: <leader>at or :Copilot enable
    insert:  <M-f>  accept           <M-w>  accept word     <M-j>  accept line
             <M-]>  next             <M-[>  previous        <C-]>  dismiss
             <M-\>  suggest now      (<Tab> stays with cmp)
    normal:  <leader>ap  panel (10 suggestions)   <leader>at  toggle   <leader>as  status
    :Copilot setup | status | enable | disable | panel | signout

Git (lua/lazyp/git/, keys in lua/genja/map-plugin/neogit|diffview|gitsigns|mini-git.lua)

    <leader>mg  Neogit status       <leader>mGl Neogit log
    <leader>md  diffview: changes   <leader>mh  file history   <leader>mH  repo history
    <leader>mxd close diffview
    <leader>mGc commit popup (genja-commit; in oil also ggc, <LocalLeader>c)
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

Fold markers with a title (lua/genja/wrapfold.lua, keys in lua/genja/map-zero.lua)

    zf (visual)        ask a title, wrap selection in  -- {{{ title  /  -- }}}   empty title: built-in zf
    <leader>wwf        same for the paragraph under the cursor (visual: the selection)
    :[range]WrapFold [title]   same as a command; no title asks

Action menu on right-click (lua/genja/fn.vim, menu from lua/genja/actions.lua)

    right-click > Actions (g.)   same menu as g. / <LocalLeader>/
    in telescope: click selects an entry, double-click runs it (mouse=a)

Toggle and increment (lua/genja/tilde.lua in map-zero.lua; dial: lua/genja/map-plugin/dial.lua)

    ~          swap word under cursor: true/false on/off yes/no enable(d)/disable(d) and/or 0/1
               left/right up/down min/max first/last; chars + -  < >; case kept; else plain ~
    <M-~>      plain ~ (case)
    <C-a> <C-x>      dial: numbers, hex, dates, times, semver, weekdays, months, &&/||, bool
                     lua ==/~=, ts let/const, php visibility, css hex colors, md headers and [ ]/[x]
    g<C-a> g<C-x>    same; in visual: progressive (1, 2, 3 …); dot repeats

F2 in markdown (lua/genja/md-checklist.lua, lua/genja/md-glow.lua, from after/ftplugin/markdown.lua; visual <F2> in map-telescope.lua)

    <F2> > markdown: checklist   add `[ ]` to the cursor line; visual <F2>: to the selected lines
                                 all lines boxed already: removes the boxes
    <F2> > markdown: preview     glow on the file in a new pwsh window, any key closes (Windows only)

Window sizes (lua/genja/winsize.lua, keys in lua/genja/map-zero.lua)

    <M-=> <M-->   grow / shrink the window along its split (10% of the screen; <leader>Ws: 8 cols / 4 lines)
    <M-0>         cycle the split share: 50/50 30/70 70/30 60/40 (left/top window; 3+ windows: current)
    <leader>wr    resize mode (which-key loop): h j k l  narrower lower taller wider, = equal, 0 share, s step, <Esc> leaves
    smart-splits.nvim (disabled spec lua/lazyp/new/smart-splits.lua): <M-h/j/k/l>, <leader>wR

Start dirs (plug-wip/genja-startdirs.nvim, keys in lua/genja/map-plugin/genja-startdirs.lua, oil in lua/genja/map-oil.lua)

    <leader>sp  <leader>jD  <S-F3>   picker, most used first; <CR> cd + open
    <leader>sa  <leader>jA           add the current dir (oil dir, file's dir, else cwd) under [added]
    <leader>sr                       remove the current dir
    <leader>se  <leader>je           edit the list (lua/genja/local/startdirs.txt), :StartdirsEdit
    <M-1> ... <M-4>                  cd + open the first four entries
    ,s  ,S  (oil)                    add / remove the dir under the cursor (else oil's dir), [oil] group
    <leader>jd                       find files in all start dirs
    removed: <leader>sp sort paragraph, <leader>sf guifont (use <F7>)
