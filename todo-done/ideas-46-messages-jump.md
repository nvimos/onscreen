from: todo-ideas.md

- [x] 46. when a lua trace makes it to the :messages list
    - add an <f2> action to go to the relevant file and line
    - can this be done in an efficient way?
    - need to monitor all notifications?
    - explore options. other people must have done something similar before
    - [x] done 2026-10-24: <F2> messages source, :Messages -dump/-quick/-loc (plugin/messages.lua);
      vim.notify recorder in lua/genja/messages-capture.lua, not active; tests/messages 10/10
        - untested, doc-wip/readme.2026-10-24.messages.md
