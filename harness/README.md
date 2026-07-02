# Forge harness — reference implementation (Claude Code)

The methodology (PROJECT_FORGE.md, Milestone 0) requires a harness: a gate command, a
mid-build quick check, a handoff snapshot, and a deny baseline. This folder is the
canonical Claude Code implementation — copy it in during Milestone 0 instead of
re-deriving it from prose, so projects don't drift from the spec.

Model-agnostic note: this is ONE implementation of the harness contract. Another
harness implements the same contract its own way; the methodology never depends on
anything in this folder.

## Copy-in (Milestone 0)

1. Copy `claude-code/commands/forge-verify.md` → `<project>/.claude/commands/forge-verify.md`
2. Copy `claude-code/hooks/*.sh` → `<project>/.claude/hooks/`
3. Merge `claude-code/settings.json` into `<project>/.claude/settings.json`
   (deny baseline + hook wiring). Add the project's own `ask` lines — spend / deploy /
   destructive-DB (FORGE_AUTONOMOUS_MODE.md appendix, Layer 1b).
4. Fill the two command placeholders in `hooks/quick-check.sh` (typecheck, lint).
5. **Prove the canary** in a fresh session: `mkdir __forge_canary__` must be BLOCKED.
   If it runs, the config did not load — you are UNGUARDED; stop and fix before building.

## What's here

| File | Role | Spec it implements |
|---|---|---|
| `claude-code/commands/forge-verify.md` | The gate: battery → outcome capture → fresh-context Verifier → Gate Report | VERIFICATION.md |
| `claude-code/hooks/quick-check.sh` | Mid-build static check — report-only, never blocks | PROJECT_FORGE.md, CLAUDE.md template |
| `claude-code/hooks/handoff-snapshot.sh` | Writes HANDOFF.snapshot.md (mechanical git state) | PROJECT_FORGE.md, Context & Handoff |
| `claude-code/settings.json` | Deny baseline + canary target + hook wiring | FORGE_AUTONOMOUS_MODE.md appendix |

Line endings: the `.sh` files must stay LF (`.gitattributes` at the repo root enforces
this) — a CRLF shebang breaks bash on the Windows + Git Bash setup these target.

Hook events and permission syntax shift between Claude Code versions — re-confirm
behaviourally on yours (the canary is the test). Verification status of the wiring in
this folder is recorded at the bottom of this file.

## Verification status

Verified behaviourally on **Claude Code 2.1.193** (Windows + Git Bash, 2026-07-02), via a
headless `claude -p` run in a throwaway project wired with this folder's settings:

- **`quick-check.sh` standalone:** exits 0 with empty/passing commands; exits 2 with the
  `forge-quick-check: ... FAILED` message on stderr when a check fails.
- **PostToolUse wiring (`Edit|Write`):** fired after a Write; the exit-2 stderr was fed
  back to the model verbatim, and the Write itself was NOT undone — feedback-only in
  effect, exactly as intended. (The harness labels the message a "blocking error," but
  the tool has already run; nothing is gated.)
- **Stop wiring:** fired at end of the run; `HANDOFF.snapshot.md` was written with
  branch, log, status, and diffstat. Standalone, the script is a silent no-op outside a
  git repo.
- **Deny baseline:** `mkdir __forge_canary__` was blocked under `acceptEdits`; an
  unlisted `mkdir` executed silently — re-confirming the appendix's finding that under
  `acceptEdits`, silence is the default and only an explicit deny stops the irreversible set.

Not verified (flagged, not assumed): **PreCompact** (cannot be cheaply triggered
headless; it uses the identical handler as the verified Stop hook), and deny-vs-allow
*precedence* specifically (see next paragraph).

**Untrusted-workspace gotcha found during verification:** in a workspace that has never
been trusted interactively, Claude Code **ignores `permissions.allow` entries from
project settings** (with a warning) while still honouring `deny`. So after copy-in, run
one interactive session and accept the trust dialog before relying on any `allow` rules —
and note the canary still protects you either way, because deny survives.
