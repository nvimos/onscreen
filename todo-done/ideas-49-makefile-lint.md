from: todo-ideas.md

- [x] linter for makefile: disable "required" target all and clean
  - [x] done 2026-10-26: shared lint/checkmake.ini turns checkmake's minphony rule off (required
      .PHONY targets all, clean, test); used when a project has no checkmake.ini of its own
      (lua/genja/lint.lua, prepare_checkmake); test sample now triggers maxbodylength
      - guide: doc-wip/readme.2026-10-26.checkmake-config.md; untested by hand
