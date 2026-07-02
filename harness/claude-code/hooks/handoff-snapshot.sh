#!/usr/bin/env bash
# Forge handoff snapshot — writes HANDOFF.snapshot.md (mechanical git state).
# Auto-written: never hand-edit the output. If its git facts contradict the
# HANDOFF.md narrative, the git facts win (PROJECT_FORGE.md, Context & Handoff).
set -u
cat > /dev/null 2>&1 || true

OUT="HANDOFF.snapshot.md"
git rev-parse --is-inside-work-tree > /dev/null 2>&1 || exit 0

{
  printf '# HANDOFF.snapshot.md — auto-generated, do not edit\n\n'
  printf 'Generated: %s\n\n' "$(date -u +'%Y-%m-%dT%H:%M:%SZ')"
  printf '## Branch\n\n%s\n\n' "$(git branch --show-current 2>/dev/null)"
  printf '## Last 5 commits\n\n```\n%s\n```\n\n' "$(git log --oneline -5 2>/dev/null)"
  printf '## Working tree status\n\n```\n%s\n```\n\n' "$(git status --short 2>/dev/null)"
  printf '## Changed since last commit\n\n```\n%s\n```\n' "$(git diff --stat HEAD 2>/dev/null)"
} > "$OUT" 2>/dev/null || true

exit 0
