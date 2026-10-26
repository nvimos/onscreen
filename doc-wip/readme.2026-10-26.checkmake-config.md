# checkmake: no warnings about missing all / clean / test targets

## What it does

checkmake's `minphony` rule ("minimum phony targets") warns when a Makefile lacks the `.PHONY`
targets `all`, `clean` and `test`. Most Makefiles here are task runners, so that is noise.

- `lint/checkmake.ini` (in the config) turns the rule off:

```ini
[minphony]
disabled = true
```

- `lua/genja/lint.lua` passes it with `--config` when the Makefile's project has no
  `checkmake.ini` of its own. A project's own `checkmake.ini` wins: checkmake then runs in that
  folder and reads it.
- The other rules stay on: `maxbodylength` (body over 5 lines), `phonydeclared`,
  `timestampexpanded`, `uniquetargets`.

## Try it

1. Open `Makefile.lazy.mk` or `tests/Makefile`.
2. Save it (checkmake reads the file, so it runs on `:w`).
3. No `minphony` warnings; `:lua =vim.diagnostic.get(0)` lists none with `code = 'minphony'`.
4. Add a target with 6 body lines and save: a `maxbodylength` warning shows.
5. In a scratch folder, put a `checkmake.ini` with `[minphony]` and nothing else next to a
   Makefile: the warnings for `all`, `clean`, `test` come back.

## Test

`make test D=comps011 G=checkmake` (sample `tests/comps011/samples/lint-checkmake/Makefile`).
