# Behat runner (2026-11-05)

auto-todo O. Overseer template: `lua/overseer/template/user/behat.lua`.

## What it does

- In a `.feature` buffer (filetype `cucumber`) under a dir with `behat.yml`, `behat.yml.dist` or
  `behat.dist.yml`, `:OverseerRun` offers **behat: this feature** and **behat: this scenario**
  (`<file>:<cursor line>`). Output with `--format=progress`; failures open the quickfix list.
- DDEV project (`.ddev/` in that root): `ddev exec vendor/bin/behat <path>` in the web container,
  path relative to the project root (= `/var/www/html`). Project inside WSL
  (`\wsl.localhost\<distro>\...`, e.g. norway4u in weasel-ddev): `wsl.exe -d <distro> --cd <linux path>
  --exec ddev exec ...`. Else the project's `vendor/bin/behat` on the host.

## Test (norway4u)

1. In weasel-ddev: `ddev start` in `~/code/norway4u`.
2. Open `features/<some>.feature` in nvim (from `\wsl.localhost\weasel-ddev\home\jazzo\code\norway4u`).
3. `:OverseerRun`, pick **behat: this feature**: the task runs in the container; `:OverseerToggle` shows output.
4. Cursor on a `Scenario:` line, **behat: this scenario**: only that scenario runs.
5. A failing step: the quickfix list opens.
