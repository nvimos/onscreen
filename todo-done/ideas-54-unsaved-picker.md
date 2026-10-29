from: todo-ideas.md

- [x] set up a pre-write handler for this:
  - when exiting...
      E37: No write since last change
      E162: No write since last change for buffer "C:/Users/jazzo/foo.txt"
      Press ENTER or type command to continue
  - im trying to simplify the act of closing unsaved buffers
  - show a telescope picker with all unsaved buffers and files like that
    - each file is a line in the picker (an item)
    - one of several actions are possible for each file
      - <m-x> discard without saving and close
      - <m-w> write the buffer and keep open
    - non-file buffers (like the one that is made by DumpMessages)
      - <m-w> does : start :cmd mode and feed keys :w ~/tmp/bufw-«WW»-«first-3-words»
        - «WW» is the burrent week number
        - «first-3-words» are the fist word-like patters from the buffer
          - these should be treated:
                      remove non-ascii, replace space with -, join by -, replace several -- by -
                      essentially make the firs 3-word like text bolbs from the buffer safe for a filename
      - <m-x> close the buffer and wipe it or whatever. throw it away
    - real-file buffers
      - <m-w> write out the file
      - <m-x> reset the buffer i.e replace with on-disk contents
  - after taking an action for the file the line in the picker disappears
    - if the triggering action was to save a session and exit, that should be done
    - if the triggering action was quit, that should be done
  - [x] done 2026-10-29: :Unsaved [cmd] (lua/genja/ext/unsaved.lua, plugin/unsaved.lua); a bare :qa, jj and s:
      go through it (lua/genja/abbreviations.vim), :qa! does not; picker reopens after each action
      and runs cmd when empty; <CR> goes to the buffer; no-file name gets .txt
    - guide: doc-wip/readme.2026-10-29.unsaved-picker.md; untested by hand
