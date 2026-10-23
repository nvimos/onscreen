from: todo-ideas.md

- [x] 36. add keys in oil to auto-add a location (item) from the list to the startdirs
    - it can take some usability / features from harpoon - ask if they seem relevant
    - it should save new locations to NVIM/local/startdirs.json
        - or some lua-native format. maybe a plain text file will do
    - startdirs should become a plugin in plug-wip/
    - done: plug-wip/genja-startdirs.nvim; START_DIRS global removed; untested by hand
        - list: lua/genja/local/startdirs.txt (gitignored), CONFIG/ DATA/ HOME/ at line start, [group] switches in the spec
        - oil ,s / ,S; <leader>sa/sr/se/sp, <leader>jA/je/jD; <M-1>..<M-4>; mydirs ranked by use
        - <leader>sp sort paragraph and <leader>sf guifont commented out
