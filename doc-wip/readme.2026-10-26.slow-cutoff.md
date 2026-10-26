# Tests that leave slow cases out of the next run on their own

To explore later: is cutting off slow tests by measured time a good default, and what does it cost?

## The idea

- Every case is timed; its average is kept in `stdpath('state')/genja-tests/timings.json`.
- A case whose average is above its cutoff (default 3 s, per case `slow`) is "slow".
- The default run (`make test`, `G=` unset) leaves slow cases out, so everyday runs stay snappy.
- The full run is explicit: `make gather` runs everything, slow ones too.
- Around it, in `tests/Makefile`:

```
make slow      list the cases left out as slow, with average and cutoff
make plan      which cases would run, skip (and why) or be left out; time estimates
make failed    rerun the cases that failed last time, verbose
make gather    run everything
```

- The slow list doubles as a list of tests worth a look: it shows where the test time goes.

## Prior art (search, 2026-10-26)

Nothing found that skips tests by their own measured duration. Neighbours:

- pytest-slow-first, pytest-slowest-first: save each test's duration in a file, but only
  reorder (slowest first, for parallel runs); nothing is skipped.
  https://github.com/joaovitorsilvestre/pytest-slow-first
  https://github.com/klimkin/pytest-slowest-first
- pytest-fail-slow: marks a test failed when it took too long; it still runs to the end.
  https://pypi.org/project/pytest-fail-slow/
- Develocity Predictive Test Selection (Gradle/Maven): skips tests before a run, chosen by a
  model trained on code changes and results, not on duration. Profiles Conservative / Standard /
  Fast; flaky tests always run.
  https://docs.gradle.com/develocity/predictive-test-selection
- pytest `--lf` / `--ff`: rerun only last failures / run them first; state kept in a cache
  between runs. The same idea as `make failed`.
  https://docs.pytest.org/en/stable/cache.html
- The usual way elsewhere: mark slow tests by hand (`@pytest.mark.slow`, then `-m "not slow"`).
  Here the cutoff is measured, and a test that got faster comes back by itself.

## Pushback

1. Slow is not bad. A test that boots a child nvim and a language server takes seconds by
   nature. The list says where the time goes, not which test is badly written.
2. A left-out test is not checked. A slow lua_ls test that breaks stays unnoticed until the
   next `make gather`. Someone has to run the full set now and then.
3. A left-out case is never re-timed by default runs. Its average only changes with
   `make gather`, `G=slow` or a named group, so a test made faster stays out until then.
4. Old runs weighed as much as new ones (plain running average), so a fix took many runs to
   show.

## Done about it (2026-10-26)

- After the summary, the default run prints one line when it left cases out, e.g.
  `4 left out as slow (~65 s; make slow lists them); last gather 6 days ago`
  (`never gathered (make gather)` if it never ran). Only a `make gather` over every dir counts
  as a gather (`genja-tests/last-gather`).
- The average is weighted: the newest run counts 30% (`M.WEIGHT` in `tests/helpers/timing.lua`),
  so a faster or slower case shows after a few runs.

## Open questions

- Should a slow case be re-timed now and then by the default run (e.g. one slow case per run,
  in turn), so its average doesn't freeze?
- Should the slow line turn into a warning after N days without a gather?
- Is 30% the right weight? One outlier run moves the average by 30% of the difference.
- Would this be worth a small standalone mini.test helper (or a pytest plugin) for others?
