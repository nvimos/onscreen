from: todo-ideas.md

- [x] 10. cmp: delay popup by 500 ms if it starts with :w
    - the popup flashes annoyingly when auto-saving
    - done instead: no delay; normal-mode :w<CR> mapped to <Cmd>write<CR> (map-zero.lua), so no cmdline and no popup
    - which-key filter keeps ':' mappings out, so ':' still opens the cmdline; nothing typed :w automatically
