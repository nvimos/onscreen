from: todo-ideas.md

- [x] f2 context: show git staged files and hunks
  - [x] done 2026-10-26: F2 in oil, group git: `staged (N files)` next to `add (N files)`;
      preview `git diff --cached` per file (hunks only in the preview, decided), <CR> unstages
      (git restore --staged), <Tab> marks (lua/genja/f2/collect/git.lua)
      - unit test tests/f2/test_git.lua; guide doc-wip/readme.2026-10-26.f2-git-staged.md; untested by hand
