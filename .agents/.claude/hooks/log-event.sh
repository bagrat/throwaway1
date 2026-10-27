#!/usr/bin/env bash
# Experiment only. Stands in for core's team hooks (proves repo hooks run in the session) and logs
# when Claude Code loads instruction files and notices settings changes. Never blocks anything.
log_dir="${CLAUDE_PROJECT_DIR:-.}/.experiment"
mkdir -p "$log_dir"
python3 -c '
import json, sys, time
try:
    event = json.load(sys.stdin)
except ValueError:
    event = {}
fields = ("hook_event_name", "source", "tool_name", "file_path", "memory_type", "load_reason",
          "parent_file_path", "config_source")
line = " ".join(f"{k}={event[k]}" for k in fields if event.get(k) is not None)
print(f"{time.time():.3f} {line}")
' >> "$log_dir/events.log" 2>/dev/null
exit 0
