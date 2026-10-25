# f2: `<F2>` context picker

Sources, task fields and the add_tasks API: header of `init.lua`. Tests: `readme.testing.md`.

## Conventions

- Group names are at most 6 characters: `adhoc`, `diag`, `git`, `make`, `oil`, `claude`, `gui`, `msgs`, `md`.
  `registry.lua` warns when an added task's group is longer.
- The main list right-aligns the group to 6 columns, then two spaces, then the label
  (`picker.display()`), so the labels start in one column:

  ```
   adhoc  go mod init foo
    diag  show all (2 hidden)
  claude  fix the tabline
      md  glow preview
  ```

- No `:` between group and label. Labels are shown lower case, without `« » ' " ! ` [ ]`
  (`picker.clean()`); the registry still matches on the label as written.
- The prompt filters on the line without the left padding.
