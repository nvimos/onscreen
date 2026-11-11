---
name: auto-todo
description: Work down the nvim config's backlog (Backlog.md tasks in the planning repo nvimos/meta) in one session - rank tasks and sub-tasks by the user's answer time and estimated tokens, update the task statuses, tag the session in git, show an overview of the questions and then ask them one at a time, then implement the easiest items first with a guide per item (in meta's backlog/docs/), a progress line per commit and a list of untested features. Use when the user types /auto-todo, or says "auto todo", "squash todos", "hammer out the todo list" or "work down the todo list" (for these phrases, ask before starting).
---

# auto-todo

Session for the nvim config (`%LOCALAPPDATA%/nvim`): shrink the backlog by doing the cheapest items first. The goal is fewer open tasks.
The backlog lives in the planning repo github.com/nvimos/meta (the checkout is the planning repo named by `tracking` in the `.nvimos` file at the config root), moved out of the config on 2026-11-10.

When started from a phrase instead of `/auto-todo`, ask "Run /auto-todo?" first and wait for a yes.

## Files

- meta `backlog/tasks/task-<n> - <Title>.md`: the backlog (Backlog.md). Status in the YAML header: `To Do`, `In Progress`, `Needs Test` (built, waiting to be tried by hand), `Done`, `Dropped`. Build steps are `## Acceptance Criteria`, hands-on checks `## Verify`.
- meta `backlog/archive/tasks/`: `Done` and `Dropped` tasks (move the file there).
- meta `openspec/changes/<id>/` (`proposal.md`, `tasks.md` with `## 1. Build` and `## 2. Verify`): only for work that needs a design; Every item is a Backlog.md task; only work that needs a design also gets an OpenSpec change (`openspec/changes/<id>/`, `proposal.md` names its task, the task a `Change:` line). Never copy an item into both. `index.tsv` lists every task with its change.
- meta `tools/scan.py` / `make review`, `make doing`, `make open`: list tasks by status with their open steps.
- meta `legacy/`: the old todo files and squash files, read-only reference.
- meta `backlog/docs/`: test sessions and longer notes; meta `legacy/nvim-config/`: the config's old todo-issue/, todo-done/, todo-test/.
- meta `backlog/docs/doc-<n> - guide-<topic>.md` (front matter `id`, `title`, `type: guide`, `created_date`): one guide per implemented item, linked from its task's Description.
- meta `backlog/docs/doc-<n> - untested-<yyyy-mm-dd>.md`: everything not tried by hand, for a later tutorial/discovery session (`:Morning` shows the newest).

## Defaults

Apply these without asking; mention them once in the overview so the user can override them.

- Tasks: the open ones in meta `backlog/tasks/` (`make open`); ranking goes into each task as `ask:` / `tokens:` lines under `## Ranking`, and the round's table in the reply.
- Built but not tried: status `Needs Test`; tried and fine: `Done` and the file to `backlog/archive/tasks/`.
- Items the code proves done (spec exists, keys mapped) are closed without asking. Items only the user's notes call good enough go to an approval list.
- Tag: commit pending todo edits first (`todo: ...`), then a lightweight tag on that commit.
- Commits: one per finished item, as you go.
- Fast checks are allowed (see Rules).

## Steps

1. **Evaluate.** Read the open tasks in meta (`python tools/scan.py --details`), the PR-* branches of the config (work may already be done there: `git log v2026..PR-<name>`), and the code each task points to. Check whether an item is already done in the code or obsolete.
2. **Rank.** Per task and sub-task, estimate two things; wall-clock size depends on the project, so don't use it:
   - **Ask**: the user's answer time, as the number of questions (about 1 min each), or `spec` when it needs a design session first.
   - **Tokens**: rough Claude cost to implement, e.g. `~5k`.
   Easiest first = least Ask, then fewest tokens. Show the ranking in the reply as a table (#, idea, Ask, Tokens).
3. **Overview, then questions one at a time.** No AskUserQuestion popup, unless the user asks for the audible-wizard skill (then follow it: all questions prepared, read aloud, answered with keys).
   - Overview first: the defaults above, then a numbered list of every planned question, one line each, so the user sees the whole round.
   - Then ask them one at a time: a short context, options `a)`, `b)`, `c)` …, one marked *(recommended)* with a reason. Wait for each answer.
   - After each answer: one `**Noted:**` line saying what was decided, then the next question.
   - Cover: per item, the design choices that change the code (keys, step sizes, fallbacks, paths outside the repo, repro steps for bugs); where to stop (which `spec` items get only a spec or questions); and anything the defaults don't cover.
   - When an answer grows an item (more features, more files), re-rank it and say so in the `Noted` line.
4. **Update the tasks.** Per task: `## Ranking` (Ask, Tokens), the decisions from step 3 under `## Decisions <date>`, and its status. Mirror status and steps in the OpenSpec change. Commit and push meta (`tasks: ...`).
5. **Tag.** `git tag auto-todo-<yyyymmdd>-<hhmm>` (local time) to mark the session start. Don't push it.
6. **Hammer them out, easiest first.** For each item:
   - read the CLAUDE.md of any plug-wip plugin it touches;
   - implement it, following CLAUDE.md (SRC notify prefix, LuaLS types, keymaps in `map-plugin/`, cheatsheet entry, which-key group and desc);
   - tick its steps in the meta task and the OpenSpec `tasks.md`, set the status (`Needs Test` until tried by hand), note the config commit hash;
   - run the mechanical checks yourself (unit tests, headless loads, `make test D=<dir>`) and record passed/failing in the untested file; checks that teach the feature stay open for the user;
   - a key, command name or picker key chosen from a default answer: add it to one `review the keys added in auto-todo <date>` task, so the user can rethink them later;
   - write meta's `backlog/docs/doc-<n> - guide-<topic>.md`: what it does, keys and commands, how to use it, how to test it step by step;
   - add a line to meta's `backlog/docs/doc-<n> - untested-<yyyy-mm-dd>.md`;
   - commit (no Claude attribution, one commit per feature);
   - print a progress line: `done <n>/<total>, ~<k>k tokens left, next: #<id> <idea>`. No minute estimates.
7. **Untested list.** meta's `backlog/docs/doc-<n> - untested-<yyyy-mm-dd>.md`: one checklist line per feature: `- [ ] <feature>: <key or command to try> (<file>) -> doc-wip/readme.<...>.md`. Include earlier features with status `Needs Test` in meta. Order it so one feature can be tried per question in the later guided session.
8. **Run log.** Add one row to `runs.md` next to this SKILL.md (`.claude/skills/nvim-auto-todo/runs.md`): date, project, project type, languages / frameworks, items built, items closed, questions asked, estimated tokens, question time, build time (from the session start, the tag and the commit times). Insert it above the two summary rows, which stay last; then recompute them over all runs:
   - **total**: sums of built, closed, questions, tokens, question time, build time.
   - **avg per built item**: the totals of questions, tokens, question time and build time divided by the total built; closed left empty.

   Read it in step 2 only as a loose reference for similar projects; don't turn it into minute estimates.

## Rules

- Token budget: the weekly quota resets on Tuesday. A run on Monday evening or in the first hours of Tuesday night (Mon 17:00 - Tue 06:00 local) is there to use up what is left of the week: don't stop or wrap up at a usage mark (95% or any other), keep building until the work or the quota runs out; going up to 5% into next week's quota is fine. Outside that window, stop at 95% usage, commit what is done and list the rest.
- With the user away (gone to bed, "go ahead with everything"): pick the recommended answer for open questions, say which in the final reply, and keep irreversible or public steps on the safe side (new repos private, nothing deleted, no push to the main trunk).
- Fast checks are allowed in this skill, overriding CLAUDE.md's "don't run": headless load (`nvim --headless -c 'qa'`), `luac -p`, small unit tests. When unsure whether something is fast, run it with a 6–9 s timeout. Features still go on the untested list; say plainly what was not run.
- Leave unrelated uncommitted changes alone.
- Keep the user's wording in the tasks (`## Description`, `## Original notes`); add steps and sections, don't rewrite theirs.
- Stop at the line the user set in step 3; list the rest as suggestions.

## Output

Final reply: items done (with commit hashes), items closed as already done or obsolete, items left with their Ask and Tokens, the tag name, elapsed time (question time and build time, measured, not estimated), the run log row, and the paths of the guides and the untested list.
