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
    <C-Left>  window on the left    <C-Right>  next tab
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
