# Experiment: per-person Claude setup in the repo

Throwaway repo testing whether core can carry each developer's Claude setup in `.humans/<login>/`:
loaded by a committed SessionStart hook in a single-repo cloud session, with `HUMAN` and `HUMAN_KEY`
as cloud environment variables, private memory encrypted in the folder, and PRs that change only the
author's own memory files approved and merged automatically. The layout mirrors core:
`.agents/.claude/` holds the settings, and `.claude` and `CLAUDE.md` are committed symlinks into it.

## Branches

- `main`: the design.
- `control`: `.humans/bagrat/setup.sh` writes no permission rules.
- `realdir`: `.claude/` is a real directory instead of a symlink (tells a symlink problem from a
  settings.local.json problem).

## Stage 1: session start

Child sessions in the "Test" environment (`HUMAN`, `HUMAN_KEY` set; no setup script), auto mode,
no `extra_allowed_tools`: E1 on `main`, C1 on `control`, R1 on `realdir`. Each, in order:

1. Before any tool: quote every line in its context containing "codeword" or "FOLLOWED", with the
   source it appears under. (The prompt names no codeword.)
2. Bash, exactly: `cat /etc/hostname`; report the result verbatim, don't retry another way.
3. Bash: `cat .experiment/status.log .experiment/events.log`.
4. send_message the report to the coordinating session.
5. Read tool on `/etc/os-release`, last, since in C1 it may stop on a prompt.

The coordinator also reads each child with `get_session` and `list_events`.

| Question | Evidence |
| --- | --- |
| Committed hooks run through the `.claude` symlink | status.log, PreToolUse lines in events.log |
| Environment variables reach the hook | `HUMAN=bagrat HUMAN_KEY=set` |
| Hook context reaches the session and is followed | STDOUT-FALCON-<run>, FALCON-FOLLOWED |
| CLAUDE.local.md written by the hook is loaded and followed | LOCAL-HERON-<run>, HERON-FOLLOWED; InstructionsLoaded lines |
| Its import of `.humans/bagrat/instructions.md` | IMPORT-LYNX, LYNX-FOLLOWED; `load_reason=include` |
| ~/.claude/CLAUDE.md written by the hook | USER-WALRUS-<run>, WALRUS-FOLLOWED |
| Hook-written settings.local.json: deny applies | E1 and R1: `cat /etc/hostname` denied; C1: printed |
| Its allow rules apply (through the symlink) | E1 and R1 read `/etc/os-release` without a prompt; C1 prompts or is blocked |
| send_message needs an allow rule in auto mode | whether C1's report arrives |
| Hook cost | `hook end: N ms` |

## Stage 2: write path (E1)

E1 runs `private-memory init`, adds a private entry with a codeword it generates without echoing,
adds a line to `.humans/bagrat/memory/notes.md`, and runs `memory-pr`. Checks: a session can push a
branch other than its own; humans-automerge approves the exact head commit; the approval satisfies
the ruleset; `ci` takes the fast path; the PR merges; which commit author GitHub records.

Negative PRs, opened by the coordinator; none may be approved or merged:
- N1: `.humans/bagrat/memory/notes.md` plus `README.md`
- N2: `.humans/alice/instructions.md`
- N3: a symlink in `.humans/bagrat/memory/`
- N4: `.humans/bagrat/setup.sh` (needs a human review by design)
- N5: a branch whose `on: push` workflow approves a code PR with GITHUB_TOKEN. This shows why core
  must not turn on "Allow GitHub Actions to create and approve pull requests".

## Stage 3: read path

- E2, a fresh child on `main` after the merge: the private topic is listed at start;
  `private-memory show` prints the entry; the coordinator checks with `list_events` whether the
  plaintext appears in E2's transcript only after `show`.
- E1 after its VM has paused, sent one more message: a `source=resume` run in status.log, which
  run's codewords it now sees, and whether hook context was injected twice.

## Not covered here

- Merge queue: personal repos have none. Core needs the App token for queueing, and a fast path in
  back-end.yml and front-end.yml for `.humans/`-only groups.
- A second account pushing to someone's memory PR (checked by the activity API, not tested).
