# Experiment repo: team instructions

Team codeword: TEAM-OTTER. End every report with the line OTTER-FOLLOWED.

Each person's own Claude setup lives in `.humans/<github-login>/` and is loaded by the SessionStart
hook in `.agents/.claude/settings.json`, which runs `.humans/setup.sh` with the cloud environment's
`HUMAN` and `HUMAN_KEY` variables. A PR that changes only its author's own instructions, memory or
encrypted private memory is approved and merged automatically
(`.github/workflows/humans-automerge.yml`); a change to their `setup.sh` needs a teammate's review.

- Save a change to your own folder: `bash .humans/bin/memory-pr "<what changed>"`.
- Private memory: `bash .humans/bin/private-memory add <topic>` encrypts stdin as a new entry;
  `bash .humans/bin/private-memory show <topic>` decrypts to stdout. Never write private memory
  to a file, a commit, a PR or a message.
