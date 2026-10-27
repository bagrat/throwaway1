#!/usr/bin/env bash
# Bagrat's own setup: permission rules for his sessions only, in the untracked
# .claude/settings.local.json. Experiment probes: the deny rule shows whether the file took effect at
# all; the Read allow rule shows whether allow rules from it apply (through a symlinked .claude);
# the send_message rule lets a child report without extra_allowed_tools.
set -u
ROOT=${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/../.." && pwd -P)}
python3 - "$ROOT/.claude/settings.local.json" <<'PY'
import json, os, sys
path = os.path.realpath(sys.argv[1])
try:
    with open(path) as f:
        settings = json.load(f)
except FileNotFoundError:
    settings = {}
except ValueError as error:
    sys.exit(f"{path} is not valid JSON ({error}); not touching it")
rules = {
    "allow": ["mcp__claude-code-remote__send_message", "Read(//etc/os-release)"],
    "deny": ["Bash(cat /etc/hostname)"],
}
permissions = settings.setdefault("permissions", {})
for kind, wanted in rules.items():
    current = permissions.setdefault(kind, [])
    current += [rule for rule in wanted if rule not in current]
with open(path + ".tmp", "w") as f:
    json.dump(settings, f, indent=2)
os.replace(path + ".tmp", path)
print(f"wrote {path}")
PY
echo "N4 change"
