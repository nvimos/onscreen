# Drupal projects (2026-11-05)

auto-todo I. Code: `plug-wip/genja-completion011.nvim/lua/genja/lang/php.lua` (`is_drupal`),
`plug-wip/genja-completion011.nvim/lua/genja/ft/drupal.lua`, `lua/genja/ext/lint.lua` (`drupal_check`).

## What it does

- A Drupal 8+ root (`core/lib/Drupal.php` in it, or in `web/` or `docroot/`): phpactor indexes
  `.module`, `.inc`, `.install`, `.theme`, `.profile`, `.engine` too, so hooks and procedural code
  get completion and go-to-definition.
- Those extensions are filetype `php` inside a Drupal tree only (a parent dir has `core/lib/Drupal.php`);
  outside Drupal they keep their usual meaning.
- drupal-check lints PHP files where the project has `vendor/bin/drupal-check` (on save, JSON output).
  phpstan-drupal needs nothing extra: phpstan runs when the project's `phpstan.neon` exists, and that
  file loads the extension.
- drupal-check runs PHP on the host; for a DDEV project in WSL it needs PHP where nvim runs (not handled).

## Test

1. A Drupal project (`composer create-project drupal/recommended-project`), open
   `web/modules/contrib/<m>/<m>.module`: `:set ft?` says php; phpactor attaches; `gd` on a function works.
2. A `.inc` file outside Drupal: filetype unchanged.
3. `composer require --dev mglaman/drupal-check`, save a `.module` file with a deprecated call:
   a `drupal-check` diagnostic.
