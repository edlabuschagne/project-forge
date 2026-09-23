#!/usr/bin/env bash
#
# forge-drift-check.sh — version-sync tripwire for the Forge repo.
#
# FORGE-REPO TOOLING ONLY. This is not part of the harness and is never copied
# into a project. It answers one question: does every place that states the
# current methodology version agree with the canonical line in PROJECT_FORGE.md?
#
# Locations are listed EXPLICITLY below, never discovered by a repo-wide grep.
# That is deliberate: evals/verifier/README.md names v1.13 as the version that
# INTRODUCED the deployed-surface requirement. That is a provenance marker, not
# a statement of the current version, and it must never be synced.
#
# Files are read with carriage returns stripped, so a CRLF working copy on
# Windows (core.autocrlf=true) and an LF checkout on a Linux runner give
# identical results.
#
# Usage: scripts/forge-drift-check.sh
# Exit:  0 = every location agrees; 1 = drift (one plain-English line each).

set -u

root="$(cd "$(dirname "$0")/.." && pwd)"
failures=0

fail() {
  printf 'FAIL  %s\n' "$1"
  failures=$((failures + 1))
}

# Print a file with CRLF normalised to LF.
read_lf() {
  tr -d '\r' < "$1"
}

# --- the canonical version -------------------------------------------------
# PROJECT_FORGE.md is the single source of truth (CLAUDE.md, "Canonical version").

canon_path="PROJECT_FORGE.md"
if [ ! -f "$root/$canon_path" ]; then
  printf 'FAIL  version-sync: %s not found. Run this script from inside the Forge repo.\n' "$canon_path"
  exit 1
fi

canon_hit="$(read_lf "$root/$canon_path" | grep -nE '^\*\*Forge v[0-9]+\.[0-9]+\*\*[[:space:]]*$' || true)"
if [ -z "$canon_hit" ]; then
  printf 'FAIL  version-sync: %s has no canonical version line. Expected a line reading exactly "**Forge vX.Y**".\n' "$canon_path"
  exit 1
fi
if [ "$(printf '%s\n' "$canon_hit" | wc -l)" -ne 1 ]; then
  printf 'FAIL  version-sync: %s has more than one "**Forge vX.Y**" line. There must be exactly one canonical version.\n' "$canon_path"
  exit 1
fi

canon_line="${canon_hit%%:*}"
canon_ver="$(printf '%s\n' "$canon_hit" | sed -E 's/.*\*\*Forge v([0-9]+\.[0-9]+)\*\*.*/\1/')"

# --- location 1: CLAUDE.md, the "currently at" line ------------------------

path="CLAUDE.md"
hit="$(read_lf "$root/$path" | grep -nE '\*\*v[0-9]+\.[0-9]+\*\*' || true)"
if [ -z "$hit" ]; then
  fail "version-sync: $path no longer states a version. The Canonical version section should read \"currently at **v$canon_ver**\" — restore it, or remove this location from $(basename "$0")."
elif [ "$(printf '%s\n' "$hit" | wc -l)" -ne 1 ]; then
  fail "version-sync: $path states a version in more than one place. Keep exactly one, in the Canonical version section."
else
  ver="$(printf '%s\n' "$hit" | sed -E 's/.*\*\*v([0-9]+\.[0-9]+)\*\*.*/\1/')"
  if [ "$ver" != "$canon_ver" ]; then
    fail "version-sync: $path:${hit%%:*} says v$ver but the canonical version in $canon_path:$canon_line is v$canon_ver. Edit $path to say v$canon_ver (or fix $canon_path if the bump itself is wrong)."
  fi
fi

# --- location 2: CHANGELOG.md, the top entry only --------------------------
# Older entries are history and are SUPPOSED to name older versions.

path="CHANGELOG.md"
hit="$(read_lf "$root/$path" | grep -nE '^## [0-9]+\.[0-9]+([[:space:]]|$)' | head -n 1 || true)"
if [ -z "$hit" ]; then
  fail "version-sync: $path has no version entry. The top entry should be a heading reading \"## $canon_ver — <date>\"."
else
  ver="$(printf '%s\n' "$hit" | sed -E 's/^[0-9]+:## ([0-9]+\.[0-9]+).*/\1/')"
  if [ "$ver" != "$canon_ver" ]; then
    fail "version-sync: the top $path entry (line ${hit%%:*}) is $ver but the canonical version in $canon_path:$canon_line is v$canon_ver. Add a \"## $canon_ver\" entry at the top of $path describing this release."
  fi
fi

# --- verdict ---------------------------------------------------------------

if [ "$failures" -ne 0 ]; then
  printf '\n%d drift failure(s). Canonical version is v%s (%s:%s).\n' "$failures" "$canon_ver" "$canon_path" "$canon_line"
  exit 1
fi

printf 'OK  version-sync: v%s consistent across %s, CLAUDE.md, CHANGELOG.md (top entry).\n' "$canon_ver" "$canon_path"
exit 0
