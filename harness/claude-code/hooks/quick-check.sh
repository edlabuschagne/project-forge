#!/usr/bin/env bash
# Forge mid-build quick check — PostToolUse, REPORT-ONLY.
# Fast static checks only: no full test suite, no browser, no network.
# jq-free by design (a stock Git Bash has no jq; a hook that crashes on missing
# jq fails open on every call). It does not parse stdin at all.
#
# Exit contract (PostToolUse): the tool has ALREADY run, so nothing here can
# block it. Exit 2 = surface stderr to the model as feedback ("fix as you go");
# exit 0 = silence. Verified on Claude Code 2.1.193 (Win + Git Bash) — see
# harness/README.md; re-confirm on your version.

set -u
cat > /dev/null 2>&1 || true   # drain stdin; never stall the harness

TYPECHECK_CMD=""   # e.g. "npx tsc --noEmit" or "mypy src" — empty = skip
LINT_CMD=""        # e.g. "npx eslint . --quiet" or "ruff check" — empty = skip

failed=0
run_check() {
  label="$1"; cmd="$2"
  [ -z "$cmd" ] && return 0
  if ! out=$($cmd 2>&1); then
    failed=1
    printf 'forge-quick-check: %s FAILED — fix as you go:\n' "$label" >&2
    printf '%s\n' "$out" | tail -n 20 >&2
  fi
}

run_check "typecheck" "$TYPECHECK_CMD"
run_check "lint" "$LINT_CMD"

# Feedback-only murmur: exit 2 surfaces the message; it cannot and must not gate.
[ "$failed" -eq 1 ] && exit 2
exit 0
