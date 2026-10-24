from: todo-ideas.md

- [x] 38. improve: key maps map-plug
    - idea: calls from spec-files; log missing and detect with healthcheck
    - the error message about no maps for "plugin" should indicate which plugin
    - probably via reflection also
    - this should be logged as a notice, only once per nvim-session. not notify, log
    - there should be a healthcheck for this
        - ok to grep / parse?
        - maybe use treesitter to reverse-lookup references?
        - who calls Maps:mappings()? who comes up empty handed?
        - i guess we can not record this, because the healthcheck should be stateless.
            - but then again, maybe call an api in the plugin to record a missing lookup when it happens?
            - should not be that bad. we already have the caller and his file then
    - [x] done 2026-10-24: misses go to stdpath('log')/genja-map-plugin.log, once per name and session,
      with the caller's file; no notify. :checkhealth genja.map-plugin lists this session's misses,
      keys nobody asked for, mappings not used yet (runtime only, no grep, doesn't read the log)
        - untested, doc-wip/readme.2026-10-24.map-plugin-health.md
        - tested 2026-10-24: steps 1-2 by hand; unit tests tests/map-plugin/test_health.lua, 10 cases (af13aed)
