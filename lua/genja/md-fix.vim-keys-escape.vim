" Very magic (\v) version of md-reformat.vim.
" In \v, < and > are word boundaries, so a literal < > is \< \>.

%s/\v`@<!\c\<leader\>[a-zA-Z0-9]+[a-zA-Z0-9`]@!/`&`/ge

" Vim/Neovim key notation (:h key-notation) -> `code`.
" Matches are wrapped in ^A..^B first, so neighbours like <C-x><C-o>
" still match and get joined into one span at the end.
" Skips keys that already touch a backtick.

" modifiers S C M A D T (+ 2-4 click count): <C-j>, <M-S-F5>, <C-]>, <A-2-LeftMouse>
%s/\v`@<!\c\<%([scmadt]-)+%([2-4]-)?%(\w+|[^ >])\>`@!/\="\x01".submatch(0)."\x02"/ge

" named keys
%s/\v`@<!\c\<%(nul|bs|tab|nl|ff|cr|return|enter|esc|space|lt|bslash|bar|del|csi|xcsi|eol|ignore|nop|help|undo|insert|home|end|pageup|pagedown|up|down|left|right)\>`@!/\="\x01".submatch(0)."\x02"/ge

" function keys <F1>..<F63>
%s/\v`@<!\c\<f\d{1,2}\>`@!/\="\x01".submatch(0)."\x02"/ge

" keypad <kPlus>, <k0>, <kEnter> ...
%s/\v`@<!\c\<k%(up|down|left|right|home|end|origin|pageup|pagedown|del|insert|plus|minus|multiply|divide|point|comma|equal|enter|\d)\>`@!/\="\x01".submatch(0)."\x02"/ge

" mouse <LeftMouse>, <2-LeftMouse>, <RightDrag>, <ScrollWheelUp>, <MouseMove>
%s/\v`@<!\c\<%(%([2-4]-)?%(left|right|middle|x1|x2)%(mouse|drag|release)%(nm)?|scrollwheel%(up|down|left|right)|mousemove)\>`@!/\="\x01".submatch(0)."\x02"/ge

" mapping pseudo-keys and :map args: <leader>, <Plug>, <Cmd>, <SID>, <buffer> ...
%s/\v`@<!\c\<%(leader|localleader|plug|sid|snr|cmd|scriptcmd|buffer|nowait|silent|script|expr|unique|special)\>`@!/\="\x01".submatch(0)."\x02"/ge

" <Char-123>, <Char-0x7f>, <Char-033>
%s/\v`@<!\c\<char-%(\d+|0x\x+)\>`@!/\="\x01".submatch(0)."\x02"/ge

" join adjacent keys, then turn markers into backticks
%s/\v%x02%x01//ge
%s/\v[\x01\x02]/`/ge
