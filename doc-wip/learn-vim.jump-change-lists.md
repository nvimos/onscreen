
Vim and Neovim both keep a jump list and a change list, so you can move back through places you were editing.

Jump list (any cursor jump: search, G, gd, :line, etc.):

- Ctrl-o: go back to the previous position
- Ctrl-i (or Tab): go forward again

Change list (where you last made edits):

- g; : jump to the position of the most recent change
- g, : move forward through change positions
- `. : jump to the exact line of the last change
- `^ : jump to where you were last in insert mode

Marks (set your own):

- ma sets mark a at the cursor, then 'a or `a jumps back to it
- :marks lists all marks
- :jumps shows the jump list, :changes shows the change list

For a quick "back to where I was editing" in one key, use g; or `. in
Neovim and Vim alike.
