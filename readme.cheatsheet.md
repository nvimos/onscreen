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

Floaterm commands (lua/genja/auto-alias.vim)

    :LazygitFterm  :BashFterm  :PythonFterm  :RangerFterm
