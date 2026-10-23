from: todo-ideas.md

- [x] 25. telescope refine decorator in steps
    - reusable decorator that enhances any picker; separate file in lua/genja/ for now
        - [x] moved into genja-finder instead: refine.lua (<M-f> filter, decorate), telemap.lua (Telemap moved there),
              require('genja-finder').attach_shared_keys(map) / .enhance(picker) use both; untested
        - [x] decorate a first picker: <C-F1> oldfiles via enhance() (lua/genja/map-telescope.lua) (f8eacab); untested
        - [x] <BS> on an empty prompt undoes the last <M-f> filter (88e7355)
        - [x] <M-n> switches refine between fuzzy and exact match (9a92404)
        - [x] <M-x> exclude: drops entries with any typed word, <BS> undoes (genja-finder refine.lua); headless-tested, untested by hand
    - see if someone has done it already
    - <m-f> refine
    - <m-x> exclude
    - telescope old files
        - implement <m-f> refinement for it too. reuse code if possible
